//
//  URLSessionOpenAIProvider.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import SwiftUI
/// `URLSession` based provider to be used as a starting point,
/// not intended for production since it requires that the API key be included Client-Side
public actor URLSessionOpenAIProvider: OpenAIProviderProtocol {

    /// Contains the scheme and host for OpenAPI
    let urlComponents: URLComponents = {
        var comp = URLComponents()
        comp.scheme = "https"
        comp.host = "api.openai.com"
        return comp
    }()
    public var encoder: JSONEncoder
    private let apiKey: String
    private let orgId: String?
    public var decoder: JSONDecoder
    var urlSession: URLSession
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    public init(apiKey: String,
                orgId: String?,
                urlSession: URLSession = .shared,
                decoder: (@Sendable () -> JSONDecoder)? = nil) {
        self.apiKey = apiKey
        self.orgId = orgId
        self.urlSession = urlSession
        self.decoder = decoder?() ?? .init()
        self.encoder = .init()
        Task {
            await prepareEncodeDecode()
        }
    }

    // MARK: Moderation
    public func checkModeration(input: String,
                                model: ModerationModels = .textModerationLatest) async throws ->
    ModerationResponseModel {
        var comp = urlComponents
        comp.path.append(OpenAIEndpoints.moderations.rawValue)

        let url = comp.url!
        var request = getBasicRequest(url: url)
        request.httpBody = """
            {
                "input": "\(input)",
                "model": "\(model.rawValue)"
            }
        """.data(using: .utf8)
        var object: ModerationResponseModel = try await makeCall(request: request)
        object.prompt = input

        return try object.check()
    }

    // MARK: Helpers
    ///
    /// - Returns:
    ///         A `URLRequest` with headers
    ///                         "Content-Type" = "application/json",
    ///                         "Authorization" = "Bearer \(apiKey)",
    ///                         "OpenAI-Organization" = `orgId`
    ///
    ///                         httpMethod = "POST"
    ///
    internal func getBasicRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        addAuthorization(request: &request)
        return request
    }
    internal func addAuthorization(request: inout URLRequest) {
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        if let org = orgId {
            request.setValue(org, forHTTPHeaderField: "OpenAI-Organization")
        }
    }

    private func processResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProviderErrors.invalidResponseType
        }

        guard httpResponse.statusCode == 200 else {
            if let error = checkForOpenAIError(data: data) {
                throw error
            } else {
                if let string = String(data: data, encoding: .utf8) as? AnyObject {
                    print("🛑 \(type(of: self)) :: \(#function) ::\n\tERROR: \(string)")
                }
                print("⚠️ get to know response to make a better error \n\t\(response)")
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }
    }

    // MARK: Aux
    enum ProviderErrors: String, LocalizedError {
        case invalidResponseType
        case unableToRetreiveImagePngData
        case unableToRetreiveMaskPngData
        public var errorDescription: String? {
            rawValue.localizedCapitalized.camelCaseToWords()
        }
    }
    private enum ResponseStream {
        case progress(Progress)
        case result(Data)
    }

}
public enum DecodedResponse<D> {
    case progress(Progress)
    case result(D)
}

extension URLSessionOpenAIProvider {
    // MARK: WITH progress
    internal func makeCallWithProgress<D, E>(_ obj: E,
                                             endpoint: OpenAIEndpoints) throws ->
    AsyncThrowingStream<DecodedResponse<D>, Error> where D: Decodable, E: Encodable {
        var comp = urlComponents
        comp.path.append(endpoint.rawValue)

        let url = comp.url!

        var request = getBasicRequest(url: url)

        let json = try encoder.encode(obj)

        request.httpBody = json

        return makeCall(request: request)
    }

    internal func makeCall<D>(request: URLRequest) ->
    AsyncThrowingStream<DecodedResponse<D>, Error> where D: Decodable {
        return AsyncThrowingStream { continuation in
            let task = Task.detached { [weak self] in
                guard let self = self else {
                    continuation.finish(throwing: PackageErrors.custom("somethingWentWrong"))
                    return
                }

                let stream: AsyncThrowingStream<ResponseStream, Error> = await makeCall(request: request)
                do {
                    for try await step in stream {
                        switch step {
                        case .progress(let progress):
                            continuation.yield(.progress(progress))
                        case .result(let data):
                            do {
                                let obj: D = try await decode(data: data)
                                continuation.yield(.result(obj))
                                continuation.finish()
                            } catch {
                                continuation.finish(throwing: error)
                            }
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    private func makeCall(request: URLRequest) -> AsyncThrowingStream <ResponseStream, Error> {
        return AsyncThrowingStream { continuation in
            let task = urlSession.dataTask(with: request) { [weak self]  data, response, error in

                if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data {
                    continuation.yield(.result(data))
                    continuation.finish()
                } else if let error = error, let data = data {
                    guard let self = self else {
                        continuation.finish(throwing: error)
                        return
                    }
                    Task {
                        if let oaierror = await self.checkForOpenAIError(data: data) {
                            continuation.finish(throwing: oaierror)
                        } else {
                            let nsError = error as NSError
                            continuation.finish(throwing: nsError)
                        }
                    }
                } else if let error = error {
                    continuation.finish(throwing: error)
                } else if let response = response as? HTTPURLResponse {
                    print("⚠️ get to know response to make a better error \n\t\(response)")
                    continuation.finish(throwing: URLError(URLError.Code(rawValue: response.statusCode)))
                } else {
                    continuation.finish(throwing: ProviderErrors.invalidResponseType)
                }
            }

            let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                print(progress)
                continuation.yield(.progress(progress))
            }

            task.resume()

            continuation.onTermination = { _ in
                observation.invalidate()
                task.cancel()
            }
        }
    }
    // MARK: Codable Helpers
    /// Call this on init or any time encoder and decoder changes
    /// This function adds OpenAI required settings such as `dateEncodingStrategy` and `keyEncodingStrategy`
    internal func prepareEncodeDecode() {
        self.encoder = Self.encoder(encoder)
        self.decoder = Self.decoder(decoder)
    }

    internal func decode<D>(data: Data) throws -> D where D: Decodable {
        do {
            let obj = try decoder.decode(D.self, from: data)
            return obj
        } catch {
            if let error = checkForOpenAIError(data: data) {
                throw error
            }
            throw error
        }
    }

    internal func encode<E: Encodable>(model: E) throws -> Data {
        return try encoder.encode(model)
    }
    internal func checkForOpenAIError(data: Data) -> OpenAIError? {
        if let openAIError = try? decoder.decode(OpenAIErrorResponse.self, from: data) {
            return openAIError.error
        } else if let error = try? decoder.decode(OpenAIError.self, from: data) {
            return error
        } else if let string = String(data: data, encoding: .utf8) as? AnyObject {
            print("🛑 \(type(of: self)) :: \(#function) :: \n\tERROR: \(string)")
        }
        return nil
    }
}

extension URLSessionOpenAIProvider {
    // MARK: NO progress
    internal func makeCall<D>(request: URLRequest) async throws -> D where D: Decodable {
        let data = try await makeCall(request: request)
        let obj: D = try decode(data: data)
        return obj
    }

    internal func makeCall<D, E>(_ obj: E,
                                 endpoint: OpenAIEndpoints) async throws ->
    D where D: Decodable, E: Encodable {
        var comp = urlComponents
        comp.path.append(endpoint.rawValue)

        let url = comp.url!

        var request = getBasicRequest(url: url)

        let json = try encoder.encode(obj)

        request.httpBody = json

        return try await makeCall(request: request)
    }
    private func makeCall(request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)

        try processResponse(data: data, response: response)

        return data
    }
}

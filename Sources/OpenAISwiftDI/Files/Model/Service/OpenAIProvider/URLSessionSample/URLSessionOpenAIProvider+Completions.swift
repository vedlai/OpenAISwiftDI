//
//  URLSessionOpenAIProvider+Completions.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
extension URLSessionOpenAIProvider {
    // MARK: Completions
    public func makeCompletionsCall(parameters: CompletionsRequest) async throws -> CompletionsResponse {
        var parameters = parameters

        parameters.stream = false

        return try await makeCall(parameters, endpoint: .completions)

    }

    public func makeCompletionsCallStream(parameters: CompletionsRequest) async ->
    AsyncThrowingStream<DecodedResponse<CompletionsResponse>, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var parameters = parameters

                    parameters.stream = true

                    var comp = urlComponents
                    comp.path.append(OpenAIEndpoints.completions.rawValue)

                    let url = comp.url!

                    var request = getBasicRequest(url: url)

                    let encoder = JSONEncoder()

                    let json = try encoder.encode(parameters)

                    request.httpBody = json

                    guard #available(iOS 15.0, *), #available(macOS 12.0, *) else {
                        throw PackageErrors.streamingIsNotSupportedForThisOS
                    }
                        let (bytes, response) = try await urlSession.bytes(for: request)

                        guard let httpResponse = response as? HTTPURLResponse else {
                            throw ProviderErrors.invalidResponseType
                        }
                        guard httpResponse.statusCode == 200 else {
                            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
                        }

                    let length = response.expectedContentLength
                    var count = 0

                        for try await byte in bytes.lines {
                            count += byte.count
                            let progress = Progress()
                            progress.completedUnitCount = Int64(count)
                            progress.totalUnitCount = length
                            continuation.yield(.progress(progress))

                            let line = byte
                                .replacingOccurrences(of: "data: ", with: "")
                                .replacingOccurrences(of: "[DONE]", with: "")
                            if !line.isEmpty,
                                let data = line.data(using: .utf8) {
                                let obj: CompletionsResponse = try decode(data: data)
                                continuation.yield(.result(obj))

                            }
                        }
                        continuation.finish()

                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    public func makeCompletionsCallStream(parameters: CompletionsRequest) ->
    AsyncThrowingStream<CompletionsResponse, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var parameters = parameters

                    parameters.stream = true

                    var comp = urlComponents
                    comp.path.append(OpenAIEndpoints.completions.rawValue)

                    let url = comp.url!

                    var request = getBasicRequest(url: url)

                    let encoder = JSONEncoder()

                    let json = try encoder.encode(parameters)

                    request.httpBody = json

                    guard #available(iOS 15.0, *), #available(macOS 12.0, *) else {
                        throw PackageErrors.streamingIsNotSupportedForThisOS
                    }
                        let (bytes, response) = try await urlSession.bytes(for: request)

                        guard let httpResponse = response as? HTTPURLResponse else {
                            throw ProviderErrors.invalidResponseType
                        }
                        guard httpResponse.statusCode == 200 else {
                            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
                        }

                        for try await byte in bytes.lines {
                            let line = byte
                                .replacingOccurrences(of: "data: ", with: "")
                                .replacingOccurrences(of: "[DONE]", with: "")
                            if !line.isEmpty,
                                let data = line.data(using: .utf8) {
                                let obj: CompletionsResponse = try decode(data: data)
                                continuation.yield(obj)

                            }
                        }
                        continuation.finish()

                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

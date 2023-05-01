//
//  URLSessionOpenAIProvider.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import SwiftUI
public struct URLSessionOpenAIProvider: OpenAIProviderProtocol {
    ///Contains the scheme and host for OpenAPI
    let urlComponents: URLComponents = {
        var c = URLComponents()
        c.scheme = "https"
        c.host = "api.openai.com"
        return c
    }()
    
    private let apiKey: String
    private let orgId: String?
    let decoder: JSONDecoder
    let urlSession: URLSession
    ///A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    public init(apiKey: String, orgId: String?, urlSession: URLSession = .shared, decoder: (() -> JSONDecoder)? = nil) {
        self.apiKey = apiKey
        self.orgId = orgId
        self.urlSession = urlSession
        self.decoder = decoder?() ?? .init()
    }
    
    //MARK: Moderation
    public func checkModeration(input: String, model: ModerationModels = .textModerationLatest) async throws -> ModerationResponseModel {
        print("\(type(of: self)) :: \(#function)")
        var c = urlComponents
        c.path.append(OpenAIEndpoints.moderations.rawValue)
        
        let url = c.url!
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

    //MARK: Helpers
    ///
    /// - Returns:
    ///         A `URLRequest` with headers
    ///                         "Content-Type" = "application/json",
    ///                         "Authorization" = "Bearer \(apiKey)",
    ///                         "OpenAI-Organization" = `orgId`
    ///
    ///                         httpMethod = "POST"
    ///
    internal func getBasicRequest(url: URL) -> URLRequest{
        print("\(type(of: self)) :: \(#function)")
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        addAuthorization(request: &request)
        return request
    }
    internal func addAuthorization(request: inout URLRequest) {
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        if let org = orgId{
            request.setValue(org, forHTTPHeaderField: "OpenAI-Organization")
        }
    }
    private func makeCall(request: URLRequest) async throws -> Data{
        let (data, response) = try await urlSession.data(for: request)
        
        try processResponse(data: data, response: response)
        
        return data
    }
    private func processResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProviderErrors.invalidResponseType
        }
        
        guard httpResponse.statusCode == 200 else{
            if let openAIError: OpenAIErrorResponse = try? decode(data: data) {
                throw openAIError.error
            }else{
                if let string = String(data: data, encoding: .utf8) as? AnyObject{
                    print("🛑 \(type(of: self)) :: \n\tERROR: \(string)")
                }
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }
    }

    internal func makeCall<D>(request: URLRequest) async throws -> D where D: Decodable{
        print("\(type(of: self)) :: \(#function)")
        let data = try await makeCall(request: request)
        let obj: D = try decode(data: data)
        return obj
    }
    
    internal func decode<D>(data: Data) throws -> D where D: Decodable{
        print("\(type(of: self)) :: \(#function)")
        let decoder = self.decoder
        
        if let error = try? decoder.decode(OpenAIErrorResponse.self, from: data){
            throw error.error
        }
        
        let obj = try decoder.decode(D.self, from: data)
        return obj
    }
    internal func encode<E: Encodable>(model: E) throws -> Data{
        let encoder: JSONEncoder = .init()
        return try encoder.encode(model)
    }
    enum ProviderErrors: LocalizedError{
        case invalidResponseType
        case unableToRetreiveImagePNGData
        case unableToRetreiveMaskPNGData
    }
}

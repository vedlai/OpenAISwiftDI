//
//  File.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import Foundation
extension URLSessionOpenAIProvider{
    //MARK: Chat Completions
    public func makeChatCompletionsCall(parameters: ChatCompletionRequest) async throws -> ChatCompletionsResponse {
        var parameters = parameters
        
        parameters.stream = false
        
        return try await makeCall(parameters, endpoint: .chatCompletions)
    }
    
    public func makeChatCompletionsCallStream(parameters: ChatCompletionRequest) -> AsyncThrowingStream<ChatCompletionsResponse, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                do{
                    var parameters = parameters
                    
                    parameters.stream = true
                    
                    var c = urlComponents
                    c.path.append(OpenAIEndpoints.chatCompletions.rawValue)
                    
                    let url = c.url!
                    
                    var request = getBasicRequest(url: url)
                    
                    let encoder = JSONEncoder()
                    
                    let json = try encoder.encode(parameters)
                    
                    request.httpBody = json
                    
                    guard #available(iOS 15.0, *), #available(macOS 12.0, *) else {
                        throw PackageErrors.custom("Streaming isnt supported in this version of operating system.")
                    }
                        let (bytes, response) = try await urlSession.bytes(for: request)
                        
                        guard let httpResponse = response as? HTTPURLResponse else{
                            throw ProviderErrors.invalidResponseType
                        }
                        guard httpResponse.statusCode == 200 else {
                            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
                        }
                        
                        for try await byte in bytes.lines {
                            let line = byte.replacingOccurrences(of: "data: ", with: "").replacingOccurrences(of: "[DONE]", with: "")
                            if !line.isEmpty, let data = line.data(using: .utf8){
                                let obj : ChatCompletionsResponse = try decode(data: data)
                                
                                continuation.yield(obj)
                                
                            }
                        }
                        continuation.finish()
             
                }catch{
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}



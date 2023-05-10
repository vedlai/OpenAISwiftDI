//
//  File.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import Foundation
extension URLSessionOpenAIProvider {
    // MARK: Chat Completions
    public func makeChatCompletionsCall(parameters: ChatCompletionRequest) async throws -> ChatCompletionsResponse {
        var parameters = parameters

        parameters.stream = false

        return try await makeCall(parameters, endpoint: .chatCompletions)
    }
    public func makeChatCompletionsCall2(parameters: ChatCompletionRequest) throws ->
    AsyncThrowingStream<DecodedResponse<ChatCompletionsResponse>, Error> {
        var parameters = parameters

        parameters.stream = false

        return try makeCallWithProgress(parameters, endpoint: .chatCompletions)
    }

    public func makeChatCompletionsCallStream(parameters: ChatCompletionRequest) ->
    AsyncThrowingStream<ChatCompletionsResponse, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var parameters = parameters

                    parameters.stream = true

                    var comp = urlComponents
                    comp.path.append(OpenAIEndpoints.chatCompletions.rawValue)

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
                            .replacingOccurrences(of: "data: ",
                                                  with: "")
                            .replacingOccurrences(of: "[DONE]",
                                                  with: "")
                        if !line.isEmpty,
                           let data = line.data(using: .utf8) {
                            let obj: ChatCompletionsResponse = try decode(data: data)

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

    public func makeChatCompletionsCallStream2(parameters: ChatCompletionRequest) ->
    AsyncThrowingStream<DecodedResponse<ChatCompletionsResponse>, Error> {

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var parameters = parameters

                    parameters.stream = true

                    var comp = urlComponents
                    comp.path.append(OpenAIEndpoints.chatCompletions.rawValue)

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
                        progress.totalUnitCount = length// max(length, Int64(count))
                        continuation.yield(.progress(progress))
                        let line = byte
                            .replacingOccurrences(of: "data: ",
                                                  with: "")
                            .replacingOccurrences(of: "[DONE]",
                                                  with: "")

                        if !line.isEmpty,
                           let data = line.data(using: .utf8) {
                            let obj: ChatCompletionsResponse = try decode(data: data)

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
}

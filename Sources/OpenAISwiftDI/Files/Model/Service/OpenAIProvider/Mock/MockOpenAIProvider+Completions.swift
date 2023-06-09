//
//  MockOpenAIProvider+Completions.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import Foundation
extension MockOpenAIProvider {
    public func makeCompletionsCallStream(parameters: CompletionsRequest) ->
    AsyncThrowingStream<CompletionsResponse, Error> {
        .init { continuation in
            let task = Task.detached {
                let text = ["This", " is", " a", " mock", " stream."]
                do {
                    for text in text {
                        continuation.yield(.init(id: UUID().uuidString,
                                                 object: "Mock",
                                                 created: Date(),
                                                 model: parameters.model,
                                                 choices: [.init(text: text,
                                                                 index: 0,
                                                                 finishReason: "stop",
                                                                 logprobs: nil)]))
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = {  _ in
                task.cancel()
            }
        }

    }

    public func makeCompletionsCall(parameters: CompletionsRequest) async throws -> CompletionsResponse {
        return .init(id: UUID().uuidString,
                     object: "Mock object",
                     created: Date(),
                     model: parameters.model,
                     choices: (0..<parameters.number)
            .map({ index in
                .init(text: "Mock response \(index + 1)", index: index, finishReason: "stop", logprobs: nil)
        }))
    }
}

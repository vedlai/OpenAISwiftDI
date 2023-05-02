//
//  MockOpenAIProvider+ChatCompletions.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import Foundation
extension MockOpenAIProvider{
    func makeChatCompletionsCall(parameters: ChatCompletionRequest) async throws -> ChatCompletionsResponse {
        
        ChatCompletionsResponse(id: UUID().uuidString, object: "", created: Date(), model: parameters.model, choices: [.init(index: 0, message: .init(role: .assistant,content: "This is a mock message about \(parameters.messages.count) messages, the last one being \"\(parameters.messages.last?.content ?? "Empty content")\"."), finish_reason: "stop")])
    }
    
    func makeChatCompletionsCallStream(parameters: ChatCompletionRequest) -> AsyncThrowingStream<ChatCompletionsResponse, Error> {
        .init { continuation in
            let task = Task.detached {
                let text = ["This", " is", " a", " mock", " stream.", " about \(parameters.messages.count) messages", ", the last one being", " \" \(parameters.messages.last?.content ?? "Empty content")\""]
                do{
                    let id = UUID().uuidString
                    for (_, t) in text.enumerated(){
                        continuation.yield(ChatCompletionsResponse(id: id, object: "", created: Date(), model: parameters.model, choices: [.init(index: 0, delta: .init(role: .assistant,content: t, name: nil), message: nil, finish_reason: "stop")])
)
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                    }
                    continuation.finish()
                }catch{
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = {  _ in
                task.cancel()
            }
        }
    }
}
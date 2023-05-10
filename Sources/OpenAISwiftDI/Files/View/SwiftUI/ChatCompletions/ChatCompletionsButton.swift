//
//  ChatCompletionsButton.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI

@available(macOS 12.0, *)
@available(iOS 15.0, *)
/// https://platform.openai.com/docs/api-reference/chat
public struct ChatCompletionsButton: View {
    @Binding var latestMessage: ChatMessage
    @Binding var request: ChatCompletionRequest
    @Binding var responses: [ChatCompletionsResponse]
    @Injected(\.openAICompletionsMgr) private var manager
    public init(latestMessage: Binding<ChatMessage>,
                request: Binding<ChatCompletionRequest>,
                responses: Binding<[ChatCompletionsResponse]>) {
        self._latestMessage = latestMessage
        self._request = request
        self._responses = responses
    }
    public var body: some View {
        CatchingButton(label: {
                Text(.getString(.submit))
        }, action: {
            do {
                responses
                    .append(.init(id: UUID().uuidString,
                                  object: "user.created",
                                  created: Date(),
                                  model: request.model,
                                  choices: [.init(index: 0, message: latestMessage, finishReason: "stop")]
                                 )
                    )

                request.messages = responses.messages

                let response = try await manager
                    .makeChatCompletionsCall(parameters: request,
                                             latestMessage: latestMessage)

                latestMessage = .init(content: "")
                responses.mergeChunks(newResponse: response)

            } catch {
                responses
                    .append(.init(id: UUID().uuidString,
                                  object: "error",
                                  created: Date(),
                                  model: request.model,
                                  choices: [.init(index: 0,
                                                  message: .init(role: .system,
                                                                 content: error.localizedDescription),
                                                  finishReason: "stop")]))

                throw error
            }
                request.messages = []
        })
    }
}

@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct ChatCompletionsButton_Previews: PreviewProvider {
    static var previews: some View {
        ChatCompletionsButton(latestMessage: .constant(.init(content: "")),
                              request: .constant(.init()),
                              responses: .constant([]))
    }
}

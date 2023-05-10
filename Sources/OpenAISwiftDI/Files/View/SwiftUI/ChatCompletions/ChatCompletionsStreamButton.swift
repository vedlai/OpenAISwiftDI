//
//  ChatCompletionsStreamButton.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI

@available(macOS 12.0, *)
@available(iOS 15.0, *)
/// https://platform.openai.com/docs/api-reference/chat
public struct ChatCompletionsStreamButton: View {
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
            Text(.getString(.stream))
        }, action: {
            do {
                // Add the user's message
                responses.append(.init(id: UUID().uuidString,
                                       object: "user.created",
                                       created: Date(),
                                       model: request.model,
                                       choices: [.init(index: 0,
                                                       message: latestMessage,
                                                       finishReason: "stop")]))
                // Include all messages
                request.messages = responses.messages
                // Create the stream
                let stream = try await manager
                    .makeChatCompletionsCallStream(parameters: request,
                                                   latestMessage: latestMessage)
                // clear the latest message
                latestMessage = .init(content: "")
                // Listen for the stream
                for try await response in stream {
                    // Merge the chuncks
                    $responses.wrappedValue.mergeChunks(newResponse: response)
                }
            } catch {
                // Add an error as part of the conversation
                responses
                    .append(.init(id: UUID().uuidString,
                                  object: "error",
                                  created: Date(),
                                  model: request.model,
                                  choices: [.init(index: 0,
                                                  message: .init(role: .system,
                                                                 content: error.localizedDescription),
                                                  finishReason: "stop")
                                  ]
                                 )
                    )
                throw error
            }
            request.messages = []
        })
    }
}

@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct ChatCompletionsStreamButton_Previews: PreviewProvider {
    static var previews: some View {
        ChatCompletionsStreamButton(latestMessage: .constant(.init(content: "")),
                                    request: .constant(.init()),
                                    responses: .constant([]))
    }
}

//
//  ChatCompletionsSampleView.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI
@available(watchOS, unavailable)
@available(iOS 15.0, macOS 12.0, *)
/// https://platform.openai.com/docs/api-reference/chat
public struct ChatCompletionsSampleView: View {
    @State private var request: ChatCompletionRequest = .init()
    @State private var responses: [ChatCompletionsResponse] = []
    @State private var latestMessage: ChatMessage = .init(content: "")
    public init() { }
   
    public var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(Array(responses.messages.enumerated()), id: \.offset) { (idx, message) in
                        HStack {
                            Text(message.role.rawValue.capitalized) + Text(":")
                            Spacer()
                            Text(message.content)
                                .textSelection(.enabled)
                        }.id(idx)
                    }
                }
                .onChange(of: responses) { _ in
                    proxy.scrollTo(responses.messages.indices.last)
                }
            }

            TextField(String.enterPromptHere, text: $latestMessage.content)
            HStack {
                ChatCompletionsButton(latestMessage: $latestMessage, request: $request, responses: $responses)
                ChatCompletionsStreamButton(latestMessage: $latestMessage, request: $request, responses: $responses)
            }.buttonStyle(.borderedProminent)
        }
    }
}
@available(watchOS, unavailable)
@available(iOS 15.0, macOS 12.0, *)
struct ChatCompletionsSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ChatCompletionsSampleView()
    }
}

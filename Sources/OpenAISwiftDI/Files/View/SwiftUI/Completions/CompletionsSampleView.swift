//
//  CompletionsSampleView.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI
@available(macOS 12.0, *)
@available(iOS 15.0, *)
/// https://platform.openai.com/docs/api-reference/completions
public struct CompletionsSampleView: View {
    @State private var request: CompletionsRequest = .init(prompt: "")
    @State private var response: CompletionsResponse?
    public init() { }
    public var body: some View {
        List {
            Section(.getString(.request)) {
                TextField(String.enterPromptHere, text: $request.prompt)

                CompletionsButtonView(request: request, response: $response)

                CompletionsStreamButtonView(request: $request, response: $response)
            }
            Section(.getString(.response)) {
                if let firstChoice = response?.choices.first {
                    Text(firstChoice.text)
                        .textSelection(.enabled)
                } else {
                    Text(String.submitARequestToSeeAResponse)
                }
            }
        }.textFieldStyle(.roundedBorder)
            .buttonStyle(.borderedProminent)
    }
}
@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct CompletionsSampleView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionsSampleView()
    }
}

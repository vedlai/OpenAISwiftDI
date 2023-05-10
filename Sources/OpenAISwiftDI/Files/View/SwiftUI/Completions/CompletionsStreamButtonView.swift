//
//  CompletionsStreamButtonView.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI

@available(macOS 12.0, *)
@available(iOS 15.0, *)
/// https://platform.openai.com/docs/api-reference/completions
struct CompletionsStreamButtonView: View {
    @Binding var request: CompletionsRequest
    @Binding var response: CompletionsResponse?
    @Injected(\.openAICompletionsMgr) private var manager

    var body: some View {
        CatchingButton(titleKey: .getString(.stream)) {
            response = nil
            let stream = try await manager.makeCompletionsCallStream(parameters: request)
            for try await response in stream {
                if self.response == nil {
                    self.response = response
                } else {
                    for choice in response.choices {
                        // merge
                        if let idx = self.response?.choices.firstIndex(where: { innerChoice in
                            innerChoice.id == choice.id
                        }) {
                            self.response?.choices[idx].text.append(choice.text)
                        } else { // append
                            self.response?.choices.append(choice)
                        }
                    }
                }
            }
        }
    }
}

@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct CompletionsStreamButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionsStreamButtonView(request: .constant(.init(prompt: "test")), response: .constant(nil))
    }
}

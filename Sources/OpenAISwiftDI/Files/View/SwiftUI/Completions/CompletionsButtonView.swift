//
//  CompletionsButtonView.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI

@available(macOS 12.0, *)
@available(iOS 15.0, *)
///https://platform.openai.com/docs/api-reference/completions
public struct CompletionsButtonView: View {
    let request: CompletionsRequest
    @Binding var response: CompletionsResponse?
    @Injected(\.openAICompletionsMgr) private var manager
    public init(request: CompletionsRequest, response: Binding<CompletionsResponse?>) {
        self.request = request
        self._response = response
    }
    public var body: some View {
        CatchingButton(titleKey: "Submit") {
            response = try await manager.makeCompletionsCall(parameters: request)
        }
    }
}

@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct ComletionsButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionsButtonView(request: .init(prompt: "test"), response: .constant(nil))
    }
}

//
//  SwiftUIView.swift
//  
//
//  Created by vedlai on 5/4/23.
//

import SwiftUI

@available(macOS 12.0, *)
@available(iOS 15.0, *)
public struct EditsButtonView: View {
    let request: EditRequest
    @Binding var response: EditResponse?
    @Injected(\.openAICompletionsMgr) private var manager
    public init(request: EditRequest, response: Binding<EditResponse?>) {
        self.request = request
        self._response = response
    }
    public var body: some View {
        CatchingButton(titleKey: String.edit.key) {
            response = try await manager.makeEditsCall(parameters: request)
        }
    }
}
@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct EditsButtonView_Previews: PreviewProvider {
    static var previews: some View {
        EditsButtonView(request: .init(instruction: "test"), response: .constant(nil))
    }
}

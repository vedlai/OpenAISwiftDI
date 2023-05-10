//
//  ImageCreateButtonView.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI
#if canImport(UIKit)
@available(iOS 15.0, *)
/// https://platform.openai.com/docs/api-reference/images/create
public struct ImageCreateButtonView: View {
    let request: ImageCreateRequestModel
    @Binding var response: ImageResponseModel?
    @Injected(\.openAIImageMgr) private var manager

    init(request: ImageCreateRequestModel, response: Binding<ImageResponseModel?> ) {
        self.request = request
        self._response = response
    }
    public var body: some View {
        CatchingButton(titleKey: .getString(.generate)) {
            response = try await manager.generateImage(request: request)
        }
    }
}

@available(iOS 15.0, *)
struct ImageCreateButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCreateButtonView(request: .init(prompt: ""), response: .constant(nil))
    }
}
#endif

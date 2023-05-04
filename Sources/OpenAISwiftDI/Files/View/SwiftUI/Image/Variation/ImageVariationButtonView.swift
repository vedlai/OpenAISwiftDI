//
//  ImageVariationButtonView.swift
//  
//
//  Created by vedlai on 5/1/23.
//
#if canImport(UIKit)
import SwiftUI

@available(iOS 15.0, *)
///https://platform.openai.com/docs/api-reference/images/create-variation
public struct ImageVariationButtonView: View {
    let request: ImageVariationRequestModel
    @Binding var response: ImageResponseModel?
    @Injected(\.openAIImageMgr) var manager
    @State private var progressLabel: String = ""
    public init(request: ImageVariationRequestModel, response: Binding<ImageResponseModel?>) {
        self.request = request
        self._response = response
    }
    public var body: some View {
        ZStack{
            CatchingButton(titleKey: "Create variation") {
                let stream  = await manager.generateImageVariation(request: request, type: ImageResponseModel.self)
                
                for try await step in stream{
                    switch step{
                    case .image(let image):
                        response = image
                    case .progress(let progress):
                        progressLabel = progress.description
                    }
                }
                progressLabel = ""
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            if !progressLabel.isEmpty{
                ZStack{
                    Color.white.opacity(0.8)
                    ProgressView {
                        Text(progressLabel)
                    }
                }.border(Color.black)
                .fixedSize()
            }
        }
    }
}
@available(iOS 15.0, *)
struct ImageVariationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ImageVariationButtonView(request: .init(image: .checkmark, n: 1, size: .large), response: .constant(nil))
    }
}
#endif

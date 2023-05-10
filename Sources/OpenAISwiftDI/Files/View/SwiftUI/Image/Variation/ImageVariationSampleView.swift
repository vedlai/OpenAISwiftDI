//
//  ImageVariationSampleView.swift
//  
//
//  Created by vedlai on 5/1/23.
//
#if canImport(UIKit)
import SwiftUI

@available(iOS 15.0, *)
/// https://platform.openai.com/docs/api-reference/images/create-variation
public struct ImageVariationSampleView: View {
    @State private var request: ImageVariationRequestModel = .init(image: .init(), number: 1, size: .medium)
    @State private var response: ImageResponseModel?
    public init() { }
    public var body: some View {
        Form {
            Section(.getString(.request)) {
                if request.image.pngData() == nil { // Check to create a sample - this mimicks picking an image.
                    ImageCreateButtonView(request: .init(prompt: .generateSample, size: request.size),
                                          response: $response)

                } else {
                    ImageVariationButtonView(request: request, response: $response)
                }
            }
            Section(.getString(.response)) {
                if let image = response?.data.first?.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text(.getString(.pressSubmitToGenerateSample))
                }
            }.onChange(of: response) { newValue in
                // Pass the new image to the request.
                if let new = newValue?.data.first?.image {
                    request.image = new
                }
            }
        }.buttonStyle(.borderedProminent)
    }
}

@available(iOS 15.0, *)
struct ImageVariationSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ImageVariationSampleView()
    }
}
#endif

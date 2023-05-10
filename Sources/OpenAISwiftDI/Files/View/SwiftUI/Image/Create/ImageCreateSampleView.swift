//
//  ImageCreateSampleView.swift
//  
//
//  Created by vedlai on 5/1/23.
//
#if canImport(UIKit)
import SwiftUI

@available(iOS 15.0, *)
/// https://platform.openai.com/docs/api-reference/images/create
public struct ImageCreateSampleView: View {
    @State private var request: ImageCreateRequestModel = .init(prompt: "")
    @State private var response: ImageResponseModel?
    public init() {}
    public var body: some View {
        Form {
            Section(.getString(.request)) {
                TextField(.getString(.enterPromptHere), text: $request.prompt)
                    .textFieldStyle(.roundedBorder)
                ImageSizePicker(size: $request.size)
                ImageCreateButtonView(request: request, response: $response)
                    .buttonStyle(.borderedProminent)
            }
            Section(.getString(.response)) {
                if let response = response, let image = response.data.first?.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text(.getString(.enterPromptAndGenerateImage))
                }
            }
        }
    }
}
@available(iOS 15.0, *)
struct ImageCreateSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCreateSampleView()
    }
}
#endif

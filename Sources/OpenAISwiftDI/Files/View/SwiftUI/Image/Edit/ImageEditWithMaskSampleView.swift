//
//  SwiftUIView.swift
//  
//
//  Created by vedlai on 5/2/23.
//

import SwiftUI
#if canImport(UIKit)
@available(iOS 15.0, *)
public struct ImageEditWithMaskSampleView: View {
    @State private var request: ImageEditRequestModel = .init(image: .init(), prompt: "", number: 1, size: .medium)
    @State private var response: ImageResponseModel?
    @Namespace private var responseNamespace
    @Namespace var requestNamespace
    public init() { }
    public var body: some View {
        ScrollViewReader { proxy in
            Form {
                Section(.getString(.request)) {
                    TextField(.getString(.enterPromptHere), text: $request.prompt)
                    NavigationLink(.getString(.showMask),
                                   destination: MaskEditView(image: request.image, mask: $request.mask))

                    Image(uiImage: request.image)
                        .resizable()
                        .scaledToFit()
                        .task {
                            // Mimicks picking an image.
                            if request.image.pngData() == nil,
                               let image = try? MaskEditParentView.sample(size: request.size).copy() {
                                request.image = image
                            }
                        }

                    ImageEditButtonView(request: request, response: $response)
                        .buttonStyle(.borderedProminent)
                        .disabled(request.prompt.isEmpty || request.mask == nil)
                    VStack(alignment: .leading) {
                        if request.prompt.isEmpty {
                            Text(.getString(.addPrompt))
                        }
                        if request.mask == nil {
                            Text(.getString(.addMaskWithTransparentArea))
                        }
                    }.font(.caption)
                        .foregroundColor(.red)

                }
                .id(requestNamespace)
                Section(.getString(.response)) {
                    if let image = response?.data.first?.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        CatchingButton(titleKey: .getString(.addImageToRequest)) {
                            request.image = try image.copy()
                            request.mask = nil
                        }
                    } else {
                        Text(.getString(.editImageAndSubmitRequest))
                    }
                }
                .id(responseNamespace)
                .onChange(of: response) { _ in
                    proxy.scrollTo(responseNamespace)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct ImageEditWithMaskSampleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImageEditWithMaskSampleView()
        }
    }
}
#endif

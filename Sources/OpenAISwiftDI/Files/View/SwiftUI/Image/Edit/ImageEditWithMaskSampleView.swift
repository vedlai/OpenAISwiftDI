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
    @State private var request: ImageEditRequestModel = .init(image: .init(), prompt: "", n: 1, size: .medium)
    @State private var response: ImageResponseModel?
    @Namespace private var responseNamespace
    @Namespace var requestNamespace
    public init(){}
    public var body: some View {
        ScrollViewReader{ proxy in
            Form{
                Section("Request"){
                    TextField("Enter Prompt Here", text: $request.prompt)
                    NavigationLink("ShowMask", destination: MaskEditView(image: request.image, mask: $request.mask))
                    
                    Image(uiImage: request.image)
                        .resizable()
                        .scaledToFit()
                        .task {
                            //Mimicks picking an image.
                            if request.image.pngData() == nil{
                                request.image = try! MaskEditParentView.sample(size: request.size).copy()
                            }
                        }
                    
                    ImageEditButtonView(request: request, response: $response)
                        .buttonStyle(.borderedProminent)
                        .disabled(request.prompt.isEmpty || request.mask == nil)
                    VStack(alignment: .leading){
                        if request.prompt.isEmpty{
                            Text("Add a prompt")
                        }
                        if request.mask == nil{
                            Text("Add a mask with a transparent area.")
                        }
                    }.font(.caption)
                        .foregroundColor(.red)
                    
                }
                .id(requestNamespace)
                Section("Response") {
                    if let image = response?.data.first?.image{
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        CatchingButton(titleKey: "Add Image to Request") {
                            request.image = try image.copy()
                            request.mask = nil
                        }
                    }else{
                        Text("Edit Image and submit Response")
                    }
                }
                .id(responseNamespace)
                .onChange(of: response) { newValue in
                    proxy.scrollTo(responseNamespace)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct ImageEditWithMaskSampleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ImageEditWithMaskSampleView()
        }
    }
}
#endif

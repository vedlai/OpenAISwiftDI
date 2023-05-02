//
//  URLSessionOpenAIProvider+Image.swift
//  
//
//  Created by vedlai on 4/30/23.
//
#if canImport(UIKit)
import Foundation
extension URLSessionOpenAIProvider{
    //MARK: Image Generation
    public func generateImage<O>(request: ImageCreateRequestModel) async throws -> O where O : OAIImageProtocol {
        
        return try await makeCall(request, endpoint: .imagesGenerations)
    }
    
    public func generateImageEditWMask<O>(request: ImageEditRequestModel) async throws -> O where O : OAIImageProtocol {

        try request.validate()
        var c = urlComponents
        c.path.append(OpenAIEndpoints.imagesEdits.rawValue)
        
        let url = c.url!
                
        let formFields: [String: String] = [
            "prompt": request.prompt,
            "size": request.size.rawValue,
            "n": "\(request.n)",
            "response_format": request.response_format.rawValue,
            "user": request.user ?? ""
        ]
        
        guard let image = request.image.pngData() else {
            throw PackageErrors.custom("Image must be valid PNG.")
        }
        guard let mask = request.mask?.pngData() else {
            throw PackageErrors.custom("Mask must be valid PNG.")
        }

        let multipart = MultipartFormDataRequest(url: url)
        multipart.addDataField(fieldName:  "image", fileName: "image.png", data: image, mimeType: "image/png")
        multipart.addDataField(fieldName:  "mask", fileName: "mask.png", data: mask, mimeType: "image/png")
        
        for (key, value) in formFields {
            multipart.addTextField(named: key, value: value)
        }
        
        var request = multipart.asURLRequest()
        addAuthorization(request: &request)
        
        return try await makeCall(request: request)
    }
    
    public func generateImageEdit<O>(request: ImageEditRequestModel) async throws -> O where O : OAIImageProtocol {
        
        guard request.mask == nil else {
            throw PackageErrors.custom("Use generateImageEditWMask")
        }
        
        try request.validate()
        var c = urlComponents
        c.path.append(OpenAIEndpoints.imagesEdits.rawValue)
        
        let url = c.url!
                
        let formFields: [String: String] = [
            "prompt": request.prompt,
            "size": request.size.rawValue,
            "n": "\(request.n)",
            "response_format": request.response_format.rawValue,
            "user": request.user ?? ""
        ]
        
        guard let image = request.image.pngData() else {
            throw PackageErrors.custom("Image must be valid PNG.")
        }

        let multipart = MultipartFormDataRequest(url: url)
        multipart.addDataField(fieldName:  "image", fileName: "image.png", data: image, mimeType: "image/png")
        
        for (key, value) in formFields {
            multipart.addTextField(named: key, value: value)
        }
        
        var request = multipart.asURLRequest()
        addAuthorization(request: &request)
        
        return try await makeCall(request: request)
    }
    
    public func generateImageVariation<O>(request: ImageVariationRequestModel) async throws -> O where O : OAIImageProtocol {


        var c = urlComponents
        c.path.append(OpenAIEndpoints.imagesVariations.rawValue)
        
        let url = c.url!
                
        let formFields: [String: String] = [
            "size": request.size.rawValue,
            "n": "\(request.n)",
            "response_format": request.response_format.rawValue,
            "user": request.user ?? ""
        ]

        guard let image = request.image.pngData() else {
            throw PackageErrors.custom("Image must be valod PNG.")
        }
        let multipart = MultipartFormDataRequest(url: url)
        multipart.addDataField(fieldName: "image", fileName: "image.png", data: image, mimeType: "image/png")
        
        for (key, value) in formFields {
            multipart.addTextField(named: key, value: value)
        }
        
        var request = multipart.asURLRequest()
        addAuthorization(request: &request)
        
        return try await makeCall(request: request)
    }
}
#endif

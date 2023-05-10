//
//  URLSessionOpenAIProvider+Image.swift
//  
//
//  Created by vedlai on 4/30/23.
//
#if canImport(UIKit)
import Foundation
extension URLSessionOpenAIProvider {

    // MARK: Image Generation
    public func generateImage<O>(request: ImageCreateRequestModel) async throws -> O where O: OAIImageProtocol {

        return try await makeCall(request, endpoint: .imagesGenerations)
    }

    public func generateImageEditWMask<O>(request: ImageEditRequestUniModel) async throws ->
    O where O: OAIImageProtocol {
        try request.validate()
        var comp = urlComponents
        comp.path.append(OpenAIEndpoints.imagesEdits.rawValue)

        let url = comp.url!

        let formFields: [String: String] = [
            ImageEditRequestUniModel.CodingKeys.prompt.rawValue: request.prompt,
            ImageEditRequestUniModel.CodingKeys.size.rawValue: request.size.rawValue,
            ImageEditRequestUniModel.CodingKeys.number.rawValue: "\(request.number)",
            ImageEditRequestUniModel.CodingKeys.responseFormat.rawValue: request.responseFormat.rawValue,
            ImageEditRequestUniModel.CodingKeys.user.rawValue: request.user ?? ""
        ]

        guard let mask = request.mask else {
            throw PackageErrors.maskMustBeValidPng
        }

        let multipart = MultipartFormDataRequest(url: url)
        multipart.addDataField(fieldName: ImageEditRequestUniModel.CodingKeys.image.rawValue,
                               fileName: "image.png",
                               data: request.image,
                               mimeType: "image/png")
        multipart.addDataField(fieldName: ImageEditRequestUniModel.CodingKeys.mask.rawValue,
                               fileName: "mask.png",
                               data: mask,
                               mimeType: "image/png")

        for (key, value) in formFields {
            multipart.addTextField(named: key, value: value)
        }

        var request = multipart.asURLRequest()
        addAuthorization(request: &request)

        return try await makeCall(request: request)
    }

    public func generateImageEdit<O>(request: ImageEditRequestUniModel) async throws ->
    O where O: OAIImageProtocol {

        guard request.mask == nil else {
            throw PackageErrors.custom("Use generateImageEditWMask")
        }

        try request.validate()
        var comp = urlComponents
        comp.path.append(OpenAIEndpoints.imagesEdits.rawValue)

        let url = comp.url!

        let formFields: [String: String] = [
            ImageEditRequestUniModel.CodingKeys.prompt.rawValue: request.prompt,
            ImageEditRequestUniModel.CodingKeys.size.rawValue: request.size.rawValue,
            ImageEditRequestUniModel.CodingKeys.number.rawValue: "\(request.number)",
            ImageEditRequestUniModel.CodingKeys.responseFormat.rawValue: request.responseFormat.rawValue,
            ImageEditRequestUniModel.CodingKeys.user.rawValue: request.user ?? ""
        ]

        let multipart = MultipartFormDataRequest(url: url)
        multipart.addDataField(fieldName: ImageEditRequestUniModel.CodingKeys.image.rawValue,
                               fileName: "image.png",
                               data: request.image,
                               mimeType: "image/png")

        for (key, value) in formFields {
            multipart.addTextField(named: key, value: value)
        }

        var request = multipart.asURLRequest()
        addAuthorization(request: &request)

        return try await makeCall(request: request)
    }
    public func generateImageVariation<O>(request: ImageVariationRequestModel) async throws ->
    O where O: OAIImageProtocol {

        var comp = urlComponents
        comp.path.append(OpenAIEndpoints.imagesVariations.rawValue)

        let url = comp.url!

        let formFields: [String: String] = [
            ImageEditRequestUniModel.CodingKeys.size.rawValue: request.size.rawValue,
            ImageEditRequestUniModel.CodingKeys.number.rawValue: "\(request.number)",
            ImageEditRequestUniModel.CodingKeys.responseFormat.rawValue: request.responseFormat.rawValue,
            ImageEditRequestUniModel.CodingKeys.user.rawValue: request.user ?? ""
        ]

        guard let image = request.image.pngData() else {
            throw PackageErrors.imageMustBeValidPng
        }
        let multipart = MultipartFormDataRequest(url: url)
        multipart.addDataField(fieldName: ImageEditRequestUniModel.CodingKeys.image.rawValue,
                               fileName: "image.png", data: image, mimeType: "image/png")

        for (key, value) in formFields {
            multipart.addTextField(named: key, value: value)
        }

        var request = multipart.asURLRequest()
        addAuthorization(request: &request)

        return try await makeCall(request: request)
    }
}
#endif

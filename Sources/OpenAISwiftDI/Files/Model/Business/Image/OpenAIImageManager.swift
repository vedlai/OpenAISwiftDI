//
//  OpenAIImageManager.swift
//  
//
//  Created by vedlai on 4/30/23.
//
#if canImport(UIKit)
import SwiftUI

public actor OpenAIImageManager: InjectionKey{
    public static var currentValue: OpenAIImageManager = OpenAIImageManager()
    
    @Injected(\.openAIProvider) var service
    //MARK: Moderation
    ///Throws error if the `string` was flagged.
    ///https://platform.openai.com/docs/api-reference/moderations
    func checkModeration(string: String, model: ModerationModels = .textModerationLatest) async throws -> ModerationResponseModel{
        var object = try await service.checkModeration(input: string, model: model)
        
        object.prompt = string
        
        return try object.check()
    }
    
    //MARK: Creation
    ///https://platform.openai.com/docs/api-reference/images/create
    public func generateImage<O>(request: ImageCreateRequestModel) async throws -> O  where O : OAIImageProtocol{
        let stream = generateImage(request: request, type: O.self)
        var image: O? = nil
        for try await step in stream {
            switch step {
            case .image(let i):
                image = i
            case .progress(_):
                break
            }
        }
        if let image = image{
            return image
        }else{
            throw ServiceError.invalidResponseType
        }
    }
    
    ///https://platform.openai.com/docs/api-reference/images/create
    public func generateImage<O>(request: ImageCreateRequestModel, type of : O.Type) -> AsyncThrowingStream<Steps<O>, Error> where O : OAIImageProtocol {
        return .init { continuation in
            let task = Task.detached { [weak self] in
                do{
                    continuation.yield(.progress(.validating))
                    
                    try request.validate()
                    guard let self = self else{
                        throw ServiceError.unknownError
                    }
                    continuation.yield(.progress(.checkingPrompt))
                    
                    let _ = try await self.checkModeration(string: request.prompt)
                    
                    continuation.yield(.progress(.requestingImage))
                    
                    var object: O = try await self.service.generateImage(request: request)
                    object.prompt = request.prompt
                    object.childType = .top
                    
                    continuation.yield(.progress(.downloadImage))
                    
                    for (idx, data) in object.data.enumerated() {
                        if let url = data.url{
                            object.data[idx].image = try await Self.downloadImage(url: url)
                        }
                    }
                    
                    try await object.save()
                    
                    continuation.yield(.progress(.finished))
                    continuation.yield(.image(image: object))
                    continuation.finish()
                }catch{
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    
    public enum Steps<O: OAIImageProtocol & Sendable>: Sendable{
        case image(image: O)
        case progress(ServiceProgress)
    }
    public enum ServiceProgress:Int, CustomStringConvertible, Sendable{
        case checkingPrompt = 0
        case requestingImage
        case decodingResponse
        case finished
        case transformingToData
        case checkingAlpha
        case modifyingAlpha
        case downloadImage
        case validating
        public var description: String{
            switch self{
            case .checkingPrompt:
                return "Checking Prompt"
            case .requestingImage:
                return "Requesting Image"
            case .decodingResponse:
                return "Decoding Response"
            case .finished:
                return "Finished"
            case .transformingToData:
                return "Transforming To Data"
            case .checkingAlpha:
                return "Checking Alpha"
            case .modifyingAlpha:
                return "Modifying Alpha"
            case .downloadImage:
                return "Downloading Image"
            case .validating:
                return "Validating Request"
            }
        }
    }
    public enum ServiceError: String, LocalizedError, Sendable{
        case invalidResponseType
        case unknownError
        case unableToGetData
        case imageShouldBeLessThan4MB
        case unableToGetImageFromURL
        case imageMustBeSquare
        case maskMustHaveTransparentAreas
        case imageAndMaskSizeMustMatch
        case imageMustMatchMaskSize
        
        public var errorDescription: String?{
            rawValue.localizedCapitalized.camelCaseToWords()
        }
    }
}
extension OpenAIImageManager{
    //MARK: Edit API Methods
    ///https://platform.openai.com/docs/api-reference/images/create-edit
    public func generateImageEdit<O>(request: ImageEditRequestModel, type of : O.Type) -> AsyncThrowingStream<Steps<O>, Error> where O : OAIImageProtocol {
        
        return AsyncThrowingStream { continuation in
            let task = Task.detached { [weak self] in
                do{
                    try request.validate()
                    
                    guard let self = self else{
                        throw ServiceError.unknownError
                    }
                    
                    continuation.yield(.progress(.checkingPrompt))
                    
                    let _ = try await self.checkModeration(string: request.prompt)
                    
                    continuation.yield(.progress(.requestingImage))
                    
                    
                    var object: O
                    
                    if request.mask == nil{
                        object = try await self.service.generateImageEdit(request: request)
                    }else{
                        object = try await self.service.generateImageEditWMask(request: request)
                    }
                    object.prompt = request.prompt
                    object.childType = .edit
                    
                    continuation.yield(.progress(.downloadImage))
                    
                    for (idx, data) in object.data.enumerated() {
                        if let url = data.url{
                            object.data[idx].image = try await Self.downloadImage(url: url)
                        }
                    }
                    try await object.save()
                    
                    continuation.yield(.progress(.finished))
                    continuation.yield(.image(image: object))
                    continuation.finish()
                }catch{
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    //MARK: Variation
    ///https://platform.openai.com/docs/api-reference/images/create-variation
    public func generateImageVariation<O>(request: ImageVariationRequestModel, type of : O.Type) -> AsyncThrowingStream<Steps<O>, Error> where O : OAIImageProtocol {
        
        return .init { continuation in
            let task = Task.detached { [weak self] in
                do{
                    continuation.yield(.progress(.validating))
                    
                    try request.validate()
                    
                    guard let self = self else{
                        throw ServiceError.unknownError
                    }
                    
                    continuation.yield(.progress(.requestingImage))
                    
                    
                    var object: O = try await self.service.generateImageVariation(request: request)
                    
                    object.prompt = "variation"
                    object.childType = .variation
                    
                    continuation.yield(.progress(.downloadImage))
                    
                    for (idx, data) in object.data.enumerated() {
                        if let url = data.url{
                            object.data[idx].image = try await Self.downloadImage(url: url)
                        }
                    }
                    try await object.save()
                    continuation.yield(.progress(.finished))
                    continuation.yield(.image(image: object))
                    continuation.finish()
                }catch{
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
extension OpenAIImageManager{
    public static func downloadImage(url: URL) async throws -> UIImage{
        
        return try await url.downloadImage()
    }
}
#endif

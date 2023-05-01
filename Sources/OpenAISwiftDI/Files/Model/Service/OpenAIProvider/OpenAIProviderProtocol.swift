//
//  OpenAIProviderProtocol.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import SwiftUI

public protocol OpenAIProviderProtocol {
    ///Classifies if text violates OpenAI's Content Policy
    /// - Parameters
    ///    - input : string or array - The input text to classify
    ///    - model :  string - Defaults to text-moderation-latest
    /// - Discussion
    /// Two content moderations models are available: text-moderation-stable and text-moderation-latest.
    /// The default is text-moderation-latest which will be automatically upgraded over time. This ensures you are always using our most accurate model. If you use text-moderation-stable, we will provide advanced notice before updating the model. Accuracy of text-moderation-stable may be slightly lower than for text-moderation-latest.
    ///
    func checkModeration(input: String, model: ModerationModels) async throws -> ModerationResponseModel
    
    
    //MARK: Image
    /// Creates an image given a prompt.
    func generateImage<O>(request: ImageCreateRequestModel) async throws -> O where O: OAIImageProtocol
    /// Creates an edited or extended image given an original image and a prompt.
    func generateImageEditWMask<O>(request: ImageEditRequestModel) async throws -> O where O : OAIImageProtocol
    /// Creates an edited or extended image given an original image and a prompt.
    func generateImageEdit<O>(request: ImageEditRequestModel) async throws -> O where O : OAIImageProtocol
    /// Creates a variation of a given image.
    func generateImageVariation<O>(request: ImageVariationRequestModel) async throws -> O where O : OAIImageProtocol
    
    
    //MARK: Completions
    func makeCompletionsCallStream(parameters: CompletionsRequest) async ->  AsyncThrowingStream<CompletionsResponse, Error>
    func makeCompletionsCall(parameters: CompletionsRequest) async throws -> CompletionsResponse

}

public struct OpenAIProviderKey: InjectionKey {
    public static var currentValue: OpenAIProviderProtocol = MockOpenAIService()
}

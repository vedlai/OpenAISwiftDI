//
//  OpenAIProviderProtocol.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import SwiftUI
/// Serves as the interface between iOS and  OpenAI
public protocol OpenAIProviderProtocol {
    // MARK: Moderation

    /// Classifies if text violates OpenAI's Content Policy
    /// Throws error if the `string` was flagged.
    func checkModeration(input: String, model: ModerationModels) async throws -> ModerationResponseModel

#if canImport(UIKit)
    // MARK: Image

    /// Creates an image given a prompt.
    func generateImage<O>(request: ImageCreateRequestModel) async throws -> O where O: OAIImageProtocol

    /// Creates an edited or extended image given an original image and a prompt.
    func generateImageEditWMask<O>(request: ImageEditRequestUniModel) async throws -> O where O: OAIImageProtocol

    /// Creates an edited or extended image given an original image and a prompt.
    func generateImageEdit<O>(request: ImageEditRequestUniModel) async throws -> O where O: OAIImageProtocol

    /// Creates a variation of a given image.
    func generateImageVariation<O>(request: ImageVariationRequestModel) async throws -> O where O: OAIImageProtocol
#endif

    // MARK: Completions

    /// Creates a completion for the provided prompt and parameters.
    func makeCompletionsCallStream(parameters: CompletionsRequest) async ->
    AsyncThrowingStream<CompletionsResponse, Error>
    /// Creates a completion for the provided prompt and parameters.
    func makeCompletionsCall(parameters: CompletionsRequest) async throws -> CompletionsResponse

    // MARK: Chat-Completions

    /// Given a list of messages describing a conversation, the model will return a response.
    func makeChatCompletionsCall(parameters: ChatCompletionRequest) async throws -> ChatCompletionsResponse
    /// Given a list of messages describing a conversation, the model will return a response.
    func makeChatCompletionsCallStream(parameters: ChatCompletionRequest) ->
    AsyncThrowingStream<ChatCompletionsResponse, Error>

    // MARK: Edits

    func makeEditCall(parameters: EditRequest) async throws -> EditResponse

}

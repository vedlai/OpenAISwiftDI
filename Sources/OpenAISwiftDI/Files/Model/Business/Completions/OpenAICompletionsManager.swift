//
//  OpenAICompletionsManager.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import SwiftUI
public actor OpenAICompletionsManager: InjectionKey{
    public static var currentValue: OpenAICompletionsManager = OpenAICompletionsManager()

    @Injected(\.openAIProvider) var provider
    
    //MARK: Moderation
    /// Throws error if the `string` was flagged.
    ///https://platform.openai.com/docs/api-reference/moderations
    func checkModeration(string: String, model: ModerationModels = .textModerationLatest) async throws -> ModerationResponseModel{
        var object = try await provider.checkModeration(input: string, model: model)
        
        object.prompt = string

        return try object.check()
    }
    //MARK: Completions
    ///https://platform.openai.com/docs/api-reference/completions
    public func makeCompletionsCall(parameters: CompletionsRequest) async throws -> CompletionsResponse {
        try parameters.validate()
        _ = try await checkModeration(string: parameters.prompt)
        return try await provider.makeCompletionsCall(parameters: parameters)
    }
    ///https://platform.openai.com/docs/api-reference/completions
    public func makeCompletionsCallStream(parameters: CompletionsRequest, array: Binding<[CompletionsResponse]>) async throws  {
        let stream = try await makeCompletionsCallStream(parameters: parameters)

        for try await obj in stream {
            let index = array.wrappedValue.merge(obj)
            if array.wrappedValue[index].parameters == nil{
                array.wrappedValue[index].parameters = parameters
            }
        }
    }
    ///https://platform.openai.com/docs/api-reference/completions
    public func makeCompletionsCallStream(parameters: CompletionsRequest) async throws -> AsyncThrowingStream<CompletionsResponse, Error> {
        try parameters.validate()
        _ = try await checkModeration(string: parameters.prompt)
        return await provider.makeCompletionsCallStream(parameters: parameters)
    }
    ///Checks moderation for the latest message
    ///Validates and makes request
    ///https://platform.openai.com/docs/api-reference/chat
    func makeChatCompletionsCall(parameters: ChatCompletionRequest, latestMessage: ChatMessage) async throws -> ChatCompletionsResponse{
        _ = try await checkModeration(string: latestMessage.content)
        return try await makeChatCompletionsCall(parameters: parameters)
    }
    //MARK: Chat Completions
    ///Checks moderation for the latest message
    ///Validates and makes request
    ///https://platform.openai.com/docs/api-reference/chat
    public func makeChatCompletionsCallStream(parameters: ChatCompletionRequest, latestMessage: ChatMessage) async throws -> AsyncThrowingStream<ChatCompletionsResponse, Error> {
        try parameters.validate()
        _ = try await checkModeration(string: latestMessage.content)
        return provider.makeChatCompletionsCallStream(parameters: parameters)
    }
    ///Validates and makes request
    ///https://platform.openai.com/docs/api-reference/chat
    func makeChatCompletionsCall(parameters: ChatCompletionRequest) async throws -> ChatCompletionsResponse{
        try parameters.validate()
        return try await provider.makeChatCompletionsCall(parameters: parameters)
    }
    ///Validates and makes request
    ///https://platform.openai.com/docs/api-reference/chat
    public func makeChatCompletionsCallStream(parameters: ChatCompletionRequest) async throws -> AsyncThrowingStream<ChatCompletionsResponse, Error> {
        try parameters.validate()
        return provider.makeChatCompletionsCallStream(parameters: parameters)
    }

}


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
    func checkModeration(string: String, model: ModerationModels = .textModerationLatest) async throws -> ModerationResponseModel{
        var object = try await provider.checkModeration(input: string, model: model)
        
        object.prompt = string

        return try object.check()
    }
    
    /*
     curl https://api.openai.com/v1/completions \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -d '{
     "model": "text-davinci-003",
     "prompt": "Say this is a test",
     "max_tokens": 7,
     "temperature": 0
     }'
     
     https://platform.openai.com/docs/api-reference/completions/create
     */
    public func makeCompletionsCall(parameters: CompletionsRequest) async throws -> CompletionsResponse {
        _ = try await checkModeration(string: parameters.prompt)
        return try await provider.makeCompletionsCall(parameters: parameters)
    }
    
    public func makeCompletionsCallStream(parameters: CompletionsRequest, array: Binding<[CompletionsResponse]>) async throws  {
        let stream = try await makeCompletionsCallStream(parameters: parameters)

        for try await obj in stream {
            let index = array.wrappedValue.merge(obj)
            if array.wrappedValue[index].parameters == nil{
                array.wrappedValue[index].parameters = parameters
            }
        }
    }
    
    public func makeCompletionsCallStream(parameters: CompletionsRequest) async throws -> AsyncThrowingStream<CompletionsResponse, Error> {
        _ = try await checkModeration(string: parameters.prompt)
        return await provider.makeCompletionsCallStream(parameters: parameters)
    }
}


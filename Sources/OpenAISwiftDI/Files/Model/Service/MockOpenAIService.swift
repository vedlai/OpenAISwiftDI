//
//  MockOpenAIService.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
import Foundation
struct MockOpenAIService: OpenAIProviderProtocol{
    
    func checkModeration(input: String, model: ModerationModels) async throws -> ModerationResponseModel {
        .init(id: UUID().uuidString, model: UUID().uuidString, results: [.init(flagged: true, categories: .init(sexual: true, hate: true, violence: false, selfHarm: true, sexualMinors: false, hateThreatening: false, violenceGraphic: true), categoryScores: .init(sexual: 0, hate: 0, violence: 0, selfHarm: 0, sexualMinors: 0, hateThreatening: 0, violenceGraphic: 0))])
    }
    //TODO: implement mock
    func generateImage<O>(request: ImageCreateRequestModel) async throws -> O where O : OAIImageProtocol {
        try request.validate()
        fatalError("Yet to be implemented - Use URLSessionOpenAIProvider")
    }
    //TODO: implement mock
    func generateImageEditWMask<O>(request: ImageEditRequestModel) async throws -> O where O : OAIImageProtocol {
        try request.validate()
        
        fatalError("Yet to be implemented - Use URLSessionOpenAIProvider")
    }
    //TODO: implement mock
    func generateImageEdit<O>(request: ImageEditRequestModel) async throws -> O where O : OAIImageProtocol {
        try request.validate()
        fatalError("Yet to be implemented - Use URLSessionOpenAIProvider")
    }
    //TODO: implement mock
    func generateImageVariation<O>(request: ImageVariationRequestModel) async throws -> O where O : OAIImageProtocol {
        try request.validate()
        fatalError("Yet to be implemented - Use URLSessionOpenAIProvider")
    }
    //TODO: implement mock
    func makeCompletionsCallStream(parameters: CompletionsRequest) -> AsyncThrowingStream<CompletionsResponse, Error> {
        fatalError("Yet to be implemented - Use URLSessionOpenAIProvider")

    }
    //TODO: implement mock
    func makeCompletionsCall(parameters: CompletionsRequest) async throws -> CompletionsResponse {
        fatalError("Yet to be implemented - Use URLSessionOpenAIProvider")
    }
}

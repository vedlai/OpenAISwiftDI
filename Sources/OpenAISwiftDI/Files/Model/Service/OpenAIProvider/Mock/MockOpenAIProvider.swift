//
//  MockOpenAIService.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
///Mock Provider that returns basic examples with minimal processing. Useful for `Previews`.
struct MockOpenAIProvider: OpenAIProviderProtocol{    
    var fail: Bool = false
    //
    func checkModeration(input: String, model: ModerationModels) async throws -> ModerationResponseModel {
        
        return .init(id: UUID().uuidString, model: UUID().uuidString, results: [.init(flagged: input.lowercased().contains("violence"), categories: .init(sexual: false, hate: false, violence: true, selfHarm: false, sexualMinors: false, hateThreatening: false, violenceGraphic: false), categoryScores: .init(sexual: 0, hate: 0, violence: 0, selfHarm: 0, sexualMinors: 0, hateThreatening: 0, violenceGraphic: 0))], prompt: input)
    }    
}

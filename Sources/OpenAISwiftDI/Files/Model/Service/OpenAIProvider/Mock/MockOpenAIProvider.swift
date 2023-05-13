//
//  MockOpenAIService.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
/// Mock Provider that returns basic examples with minimal processing. Useful for `Previews`.
public actor MockOpenAIProvider: OpenAIProviderProtocol {
    var decoder: JSONDecoder

    var encoder: JSONEncoder

    var fail: Bool

    init() {
        self.decoder = .init()
        self.encoder = .init()
        self.fail = false

    }
    //
    public func checkModeration(input: String, model: ModerationModels) async throws -> ModerationResponseModel {
        let flagged = input.lowercased().contains("violence") ||
        input.lowercased().contains("sexual")
        return .init(id: UUID().uuidString,
                     model: UUID().uuidString,
                     results: [.init(flagged: flagged,
                                     categories: .init(sexual: input.lowercased()
                                        .contains("sexual"),
                                                       hate: input.lowercased()
                                        .contains("hate"),
                                                       violence: input.lowercased()
                                        .contains("violence"),
                                                       selfHarm: input.lowercased()
                                        .contains("self-harm"),
                                                       sexualMinors: input.lowercased()
                                        .contains("sexual minor"),
                                                       hateThreatening: input.lowercased()
                                        .contains("hate/threatening"),
                                                       violenceGraphic: input.lowercased()
                                        .contains("violence/graphic")),
                                     categoryScores: .init(sexual: 0,
                                                           hate: 0,
                                                           violence: 0,
                                                           selfHarm: 0,
                                                           sexualMinors: 0,
                                                           hateThreatening: 0,
                                                           violenceGraphic: 0)
                                    )
                     ],
                     prompt: input)
    }
}

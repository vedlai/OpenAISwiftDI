//
//  MockOpenAIProvider+Edits.swift
//  
//
//  Created by vedlai on 5/4/23.
//

import Foundation
extension MockOpenAIProvider {
    func makeEditCall(parameters: EditRequest) async throws -> EditResponse {
        .init(object: "mock",
              created: Date(),
              choices: [.init(text: "Edited: \"\(parameters.input ?? "")\" by adding \"\(parameters.instruction)\"",
                              index: 0,
                              finishReason: "stop",
                              logprobs: nil)])
    }
}

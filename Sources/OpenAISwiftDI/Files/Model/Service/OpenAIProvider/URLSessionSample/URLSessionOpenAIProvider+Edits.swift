//
//  File.swift
//  
//
//  Created by vedlai on 5/4/23.
//

import Foundation
extension URLSessionOpenAIProvider {
    // MARK: Edit
    public func makeEditCall(parameters: EditRequest) async throws -> EditResponse {
        try await makeCall(parameters, endpoint: .edits)
    }

}

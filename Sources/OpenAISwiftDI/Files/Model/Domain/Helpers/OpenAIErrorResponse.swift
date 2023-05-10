//
//  OpenAIErrorResponse.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
// MARK: - OpenAIErrorResponse
struct OpenAIErrorResponse: Codable, Sendable {
    let error: OpenAIError
}

// MARK: - Error
struct OpenAIError: Codable, LocalizedError, Sendable {
    let message, type: String
    let param, code: String?

    var errorDescription: String? {
        var errorMessage = ""

        if let errorCode = code {
            errorMessage.append("Code: \(errorCode)\n")
        }
        errorMessage.append("Type: \(type)\n")
        errorMessage.append("Message: \(message)\n")

        if let errorParam = param {
            errorMessage.append("Param: \(errorParam)")
        }
        return errorMessage
    }
}

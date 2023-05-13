//
//  OpenAIErrorResponse.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
// MARK: - OpenAIErrorResponse
public struct OpenAIErrorResponse: Codable, Sendable, Hashable, Equatable {
    public let error: OpenAIError
}

// MARK: - OpenAIError
public struct OpenAIError: Codable, LocalizedError, Sendable, Hashable, Equatable {
    public let message, type: String
    public let param, code: String?

    public var errorDescription: String? {
        var errorMessage = ""

        errorMessage.append("Type: \(type)")

        if let errorCode = code {
            errorMessage.append("\nCode: \(errorCode)")
        }

        if let errorParam = param {
            errorMessage.append("\nParam: \(errorParam)")
        }

        errorMessage.append("\nMessage: \(message)")

        return errorMessage
    }
}

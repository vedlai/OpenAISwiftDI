//
//  EditResponse.swift
//  
//
//  Created by vedlai on 5/4/23.
//

import Foundation
// MARK: - EditResponse
///https://platform.openai.com/docs/api-reference/edits/create
public struct EditResponse: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: Date{
        created
    }
    public var object: String
    public var created: Date
    public var choices: [Choice]
    ///As of 2-May-2023 Streaming does not provide a Usage value
    public var usage: Usage?
}

//
//  ChatCompletionRequest.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import SwiftUI
/// https://platform.openai.com/docs/api-reference/chat
public struct ChatCompletionRequest: Codable, Equatable, Hashable, Sendable {
    public var model: ChatModel = .gpt35Turbo
    public var messages: [ChatMessage] = []
    public var temperature: Double?
    public var topP: Double?
    public var number: Int = 1
    public var stream: Bool = false
    public var stop: [String]?
    public var maxTokens: Int?
    public var presencePenalty: Double?
    public var frequencyPenalty: Double?
    public var user: String?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case topP = "top_p"
        case number = "n"
        case stream
        case stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
    }

    /// https://platform.openai.com/docs/models/model-endpoint-compatibility
    public enum ChatModel: String, Codable, Equatable, Hashable, Sendable, CaseIterable {
        /// gpt-4
        case gpt4 = "gpt-4"
        /// gpt-4-0314
        case gpt4314 = "gpt-4-0314"
        /// gpt-4-32k
        case gpt4432k = "gpt-4-32k"
        /// gpt-4-32k-0314
        case gpt4432k314 = "gpt-4-32k-0314"
        /// gpt-3.5-turbo
        case gpt35Turbo = "gpt-3.5-turbo"
        /// gpt-3.5-turbo-0301
        case gpt35Turbo301 = "gpt-3.5-turbo-0301"

        var maxTokens: Int {
            switch self {
            case .gpt4:
                return 8192
            case .gpt4314:
                return 8192
            case .gpt4432k:
                return 32768
            case .gpt4432k314:
                return 32768
            case .gpt35Turbo:
                return 4096
            case .gpt35Turbo301:
                return 4096
            }
        }
        func validTokens(entry: Int?, allowOptional: Bool = true) -> Bool {
            guard let entry = entry else {
                return allowOptional
            }
            return entry <= maxTokens
        }
    }
    /*
     Validates that the model value has the recommended settings per OpenAI documentation
     */
    public func validate() throws {
        // Name
        _ = try messages.allSatisfy({ message in
            if let name = message.name {
                guard name.count <= 64 else {
                    throw PackageErrors.maxLetterCountIs(64)
                }
                let namePattern = "[a-zA-Z0-9_]{\(name.count)}"

                guard name
                    .range(of: namePattern, options: .regularExpression)?
                    .upperBound
                    .utf16Offset(in: name) == name.count else {
                    throw PackageErrors.nameComponents
                }
                return true
            } else {
                return true // name is optional per documentation
            }
        })

        guard (temperature == nil && topP == nil) ||
                (temperature != nil && topP == nil) ||
                (temperature == nil && topP != nil) else {
            throw PackageErrors.useTemperatureOrTopPButNotBoth
        }
        let tempRange = 0.0...2.0
        // temp
        if let temp = temperature, !(tempRange).contains(temp) {
            throw PackageErrors.temperatureShouldBeBetween(tempRange)
        }
        let topPRange = 0.0...1.0

        if let topP = topP, !(topPRange).contains(topP) {
            throw PackageErrors.topPShouldBeBetween(topPRange)
        }
        guard model.validTokens(entry: maxTokens) else {
            throw PackageErrors.maxTokensForModelIs(model: model.rawValue, tokens: model.maxTokens)
        }
        let presencePenaltyRange = -2.0...2.0

        if let presencePenalty = presencePenalty, !(presencePenaltyRange).contains(presencePenalty) {
            throw PackageErrors.presencePenaltyShouldBeBetween(presencePenaltyRange)
        }
        let frequencyPenaltyRange = -2.0...2.0

        if let frequencyPenalty = frequencyPenalty, !(frequencyPenaltyRange).contains(frequencyPenalty) {
            throw PackageErrors.frequencyPenaltyShouldBeBetween(frequencyPenaltyRange)
        }
    }

}
/// https://platform.openai.com/docs/api-reference/chat
public struct ChatMessage: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: UUID = .init()
    public let role: Role
    public var content: String
    public let name: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(ChatMessage.Role.self, forKey: .role)
        self.content = try container.decode(String.self, forKey: .content)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    enum CodingKeys: CodingKey {
        case id
        case role
        case content
        case name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.role, forKey: .role)
        try container.encode(self.content, forKey: .content)
        try container.encodeIfPresent(self.name, forKey: .name)
    }

    public init(role: Role = .user, content: String, name: String? = nil) {
        self.role = role
        self.content = content
        self.name = name
    }

    public enum Role: String, CustomStringConvertible, Codable, Equatable, Hashable, Identifiable, Sendable {
        public var id: String {
            rawValue
        }
        case system
        case user
        case assistant
        public var description: String {
            rawValue
        }
    }
}

public struct DeltaMessage: Codable, Equatable, Hashable, Sendable {
    public let role: ChatMessage.Role?
    public var content: String?
    public let name: String?

}

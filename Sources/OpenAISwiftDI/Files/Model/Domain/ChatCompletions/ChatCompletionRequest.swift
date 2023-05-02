//
//  ChatCompletionRequest.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import SwiftUI
///https://platform.openai.com/docs/api-reference/chat
public struct ChatCompletionRequest: Codable, Equatable, Hashable, Sendable{
    public var model: ChatModel = .gpt3_5Turbo
    public var messages: [ChatMessage] = []
    public var temperature: Double?
    public var top_p: Double?
    public var n: Int = 1
    public var stream: Bool = false
    public var stop: [String]?
    public var max_tokens: Int?
    public var presence_penalty: Double?
    public var frequency_penalty: Double?
    public var user: String?
    
    ///https://platform.openai.com/docs/models/model-endpoint-compatibility
    public enum ChatModel: String, Codable, Equatable, Hashable, Sendable{
        case gpt4 = "gpt-4"
        case gpt4_314 = "gpt-4-0314"
        case gpt4_4_32k = "gpt-4-32k"
        case gpt4_4_32k_314 = "gpt-4-32k-0314"
        case gpt3_5Turbo = "gpt-3.5-turbo"
        case gpt3_5Turbo_301 = "gpt-3.5-turbo-0301"
        
        var maxTokens: Int {
            switch self{
            case .gpt4:
                return 8192
            case .gpt4_314:
                return 8192
            case .gpt4_4_32k:
                return 32768
            case .gpt4_4_32k_314:
                return 32768
            case .gpt3_5Turbo:
                return 4096
            case .gpt3_5Turbo_301:
                return 4096
            }
        }
        func validTokens(entry: Int?, allowOptional: Bool = true) -> Bool{
            guard let entry = entry else{
                return allowOptional
            }
            return entry <= maxTokens
        }
    }
    /*
     Validates that the model value has the recommended settings per OpenAI documentation
     */
    public func validate() throws {
                
        //Name
        guard try messages.allSatisfy({ m in
            if let name = m.name {
                guard name.count <= 64 else {
                    throw ModelError.custom("Max name letter count is 64")
                }
                let namePattern = "[a-zA-Z0-9_]{\(name.count)}"

                guard (name.range(of: namePattern, options:.regularExpression)?.upperBound.utf16Offset(in: name) == name.count) else {
                    throw ModelError.custom("Name must be composed of letters numbers and underscore.")
                }
                return true
            }else{
                return true //name is optional per documentation
            }
        }) else {
            throw ModelError.custom("Chat Messsages must have a valid name that only contains letters, numbers and underscore.")
        }
        
        guard (temperature == nil && top_p == nil) || (temperature != nil && top_p == nil) || (temperature == nil && top_p != nil) else{
            throw ModelError.custom("use temperature or top_p but not both")
        }
        //temp
        if let temp = temperature, !(0...2).contains(temp){
            throw ModelError.custom("temperature should be between 0...2")
        }
        if let top_p = top_p, !(0...1).contains(top_p){
            throw ModelError.custom("top_p should be between 1 & 0")
        }
        guard model.validTokens(entry: max_tokens) else {
            throw PackageErrors.custom("Max tokens for \(model.rawValue) is \(model.maxTokens)")
        }
        
        if let presence_penalty = presence_penalty, !(-2...2).contains(presence_penalty){
            throw ModelError.custom("presence_penalty should be a number between -2.0 and 2.0. ")
        }
        if let frequency_penalty = frequency_penalty, !(-2...2).contains(frequency_penalty){
            throw ModelError.custom("frequency_penalty should be a number between -2.0 and 2.0. ")
        }
    }
    
    public enum ModelError: LocalizedError{
        case custom(String)
        public var errorDescription: String?{
            switch self{
            case .custom(let string):
                return string
            }
        }
    }
}
///https://platform.openai.com/docs/api-reference/chat
public struct ChatMessage: Codable, Equatable, Hashable, Identifiable, Sendable{
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
    
    public init(role: Role = .user, content: String, name: String? = nil){
        self.role = role
        self.content = content
        self.name = name
    }
    
    
    public enum Role: String, CustomStringConvertible, Codable, Equatable, Hashable, Identifiable, Sendable{
        public var id: String{
            rawValue
        }
        case system
        case user
        case assistant
        public var description: String{
            rawValue
        }
    }
}

public struct DeltaMessage: Codable, Equatable, Hashable, Sendable{
    public let role: ChatMessage.Role?
    public var content: String?
    public let name: String?

}

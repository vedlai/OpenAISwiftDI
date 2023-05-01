//
//  ChatCompletionRequest.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
///https://platform.openai.com/docs/api-reference/chat
public struct ChatCompletionRequest: Codable{
    public var model: ChatModel = .gpt35Turbo
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
    public enum ChatModel: String, Codable{
        case gpt4 = "gpt-4"
        case gpt4_314 = "gpt-4-0314"
        case gpt4_4_32k = "gpt-4-32k"
        case gpt4_4_32k_314 = "gpt-4-32k-0314"
        case gpt35Turbo = "gpt-3.5-turbo"
        case gpt35Turbo_301 = "gpt-3.5-turbo-0301"
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

public struct ChatMessage: Codable{
    
    public let role: Role
    public let content: String
    public let name: String?
    public let created: Date
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(ChatMessage.Role.self, forKey: .role)
        self.content = try container.decode(String.self, forKey: .content)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.created = try container.decodeIfPresent(Date.self, forKey: .created) ?? Date()
    }
    
    public init(role: Role = .user, content: String, name: String? = nil){
        self.role = role
        self.content = content
        self.name = name
        self.created = Date()
    }
    
    
    public enum Role: String, CustomStringConvertible, Codable{
        case system
        case user
        case assistance
        public var description: String{
            rawValue
        }
    }
}

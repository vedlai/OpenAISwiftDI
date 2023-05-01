//
//  CompletionsRequest.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
// MARK: - CompletionsParameters
public struct CompletionsRequest: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: UUID = .init()
    public var model: CompletionsModel = .textDavinci3
    public var prompt: String
    public var maxTokens: Int = 75
    public var temperature: Double = 1.4
    public var topP: Int? = nil
    public var n: Int = 1
    public var stream: Bool? = true
    public var logprobs: String? = nil
    public var stop: String? = nil
    public var user: String? = nil
    public init(prompt: String){
        self.prompt = prompt
    }
    
    public enum CodingKeys: String, CodingKey {
        case model, prompt
        case maxTokens = "max_tokens"
        case temperature
        case topP = "top_p"
        case n, stream, logprobs, stop
    }
    public enum CompletionsModel: String, Codable, Equatable, Hashable, Sendable{
        case textDavinci3 = "text-davinci-003"
        case textDavinci2 = "text-davinci-002"
        case textCurie1 = "text-curie-001"
        case textBabbage1 = "text-babbage-001"
        case textAda1 = "text-ada-001"
    }
}



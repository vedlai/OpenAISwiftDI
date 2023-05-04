//
//  CompletionsRequest.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
// MARK: - CompletionsRequest
/// https://platform.openai.com/docs/api-reference/completions
public struct CompletionsRequest: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: UUID = .init()
    public var model: CompletionsModel = .textDavinci3
    public var prompt: String
    public var maxTokens: Int = 75
    public var temperature: Double? = 1.4
    public var topP: Int? = nil
    public var n: Int = 1
    public var stream: Bool? = true
    public var logprobs: String? = nil
    public var stop: String? = nil
    public var presence_penalty: Double?
    public var frequency_penalty: Double?
    public var user: String? = nil
    
    public init(prompt: String){
        self.prompt = prompt
    }
    func validate() throws{
        guard model.validTokens(entry: maxTokens) else {
            throw PackageErrors.custom("Max tokens for \(model.rawValue) is \(model.maxTokens ?? .max)")
        }
        guard (temperature == nil && topP == nil) || (temperature != nil && topP == nil) || (temperature == nil && topP != nil) else{
            throw PackageErrors.custom("use temperature or top_p but not both")
        }
        //temp
        if let temp = temperature, !(0...2).contains(temp) {
            throw PackageErrors.custom("temperature should be between 0...2")
        }
        if let top_p = topP, !(0...1).contains(top_p){
            throw PackageErrors.custom("top_p should be between 1 & 0")
        }

        
        if let presence_penalty = presence_penalty, !(-2...2).contains(presence_penalty){
            throw PackageErrors.custom("presence_penalty should be a number between -2.0 and 2.0. ")
        }
        if let frequency_penalty = frequency_penalty, !(-2...2).contains(frequency_penalty){
            throw PackageErrors.custom("frequency_penalty should be a number between -2.0 and 2.0. ")
        }
    }
    public enum CodingKeys: String, CodingKey {
        case model, prompt
        case maxTokens = "max_tokens"
        case temperature
        case topP = "top_p"
        case n, stream, logprobs, stop
    }
    public enum CompletionsModel: String, Codable, Equatable, Hashable, Sendable, CaseIterable{
        case textDavinci3 = "text-davinci-003"
        case textDavinci2 = "text-davinci-002"
        case textCurie1 = "text-curie-001"
        case textBabbage1 = "text-babbage-001"
        case textAda1 = "text-ada-001"
        
        var maxTokens: Int?{
            switch self{
            case .textDavinci3:
                return 4097
            case .textDavinci2:
                return 4097
            case .textCurie1:
                return nil
            case .textBabbage1:
                return nil
            case .textAda1:
                return nil
            }
        }
        func validTokens(entry: Int?, allowOptional: Bool = true) -> Bool{
            guard let entry = entry else{
                return allowOptional
            }

            return entry <= maxTokens ?? .max
        }
    }
}



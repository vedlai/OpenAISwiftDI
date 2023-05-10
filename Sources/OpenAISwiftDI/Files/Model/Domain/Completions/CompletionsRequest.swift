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
    public var topP: Int?
    public var number: Int = 1
    public var stream: Bool? = true
    public var logprobs: String?
    public var stop: String?
    public var presencePenalty: Double?
    public var frequencyPenalty: Double?
    public var user: String?

    public init(prompt: String) {
        self.prompt = prompt
    }
    func validate() throws {
        guard model.validTokens(entry: maxTokens) else {
            throw PackageErrors.maxTokensForModelIs(model: model.rawValue, tokens: model.maxTokens ?? .max)
        }
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
        if let topP = topP, !(0...1).contains(topP) {
            throw PackageErrors.topPShouldBeBetween(topPRange)
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
    public enum CodingKeys: String, CodingKey {
        case model, prompt
        case temperature
        case stream, logprobs, stop
        case maxTokens = "max_tokens"
        case topP = "top_p"
        case number = "n"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
    }
    public enum CompletionsModel: String, Codable, Equatable, Hashable, Sendable, CaseIterable {
        case textDavinci3 = "text-davinci-003"
        case textDavinci2 = "text-davinci-002"
        case textCurie1 = "text-curie-001"
        case textBabbage1 = "text-babbage-001"
        case textAda1 = "text-ada-001"

        var maxTokens: Int? {
            switch self {
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
        func validTokens(entry: Int?, allowOptional: Bool = true) -> Bool {
            guard let entry = entry else {
                return allowOptional
            }
            return entry <= maxTokens ?? .max
        }
    }
}

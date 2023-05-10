//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
// MARK: - ModerationResponseModel
public struct ModerationResponseModel: Codable, Sendable {
    public let id, model: String
    public let results: [OAIModModelResult]
    public var prompt: String?
    public func check() throws -> Self {
        guard self.results.allSatisfy({ result in
            result.flagged == false
        }) else {
            let flaggedString = self.results.map { res in
                res.categories.flaggedDescription
            }.joined(separator: ", ")
            throw ModerationError
                .flag("\(prompt?.capitalized ?? "Prompt") was flagged as \(flaggedString). Rephrase your prompt!")
        }
        return self
    }
    public enum ModerationError: LocalizedError {
        case flag(String)
        public var errorDescription: String? {
            switch self {
            case .flag(let string):
                return string
            }
        }
    }
}

// MARK: - Result
public struct OAIModModelResult: Codable, Sendable {
    public let flagged: Bool
    public let categories: OAIModCategoriesModel
    public let categoryScores: OAIModCategoryScoresModel

    enum CodingKeys: String, CodingKey {
        case flagged, categories
        case categoryScores = "category_scores"
    }
}

// MARK: - Categories
public struct OAIModCategoriesModel: Codable, Sendable {
    public let sexual, hate, violence, selfHarm: Bool
    public let sexualMinors, hateThreatening, violenceGraphic: Bool
    /// Returns a String with all the variables that are marked `true`
    public var flaggedDescription: String {
        let mirror = Mirror(reflecting: self)
        return mirror.children.filter { child in
            (child.value as? Bool) == true
        }.compactMap { (key, _) in
            if key == "selfHarm"{
                return key?.camelCaseToWords(separator: "-")
            } else {
                return key?.camelCaseToWords(separator: "/")
            }
        }.joined(separator: ", ")
    }
    /// Returns a String with all the variables that are marjed `false`
    public var acceptableDescription: String {
        let mirror = Mirror(reflecting: self)
        return mirror.children.filter { child in
            (child.value as? Bool) == false
        }.compactMap { (key, _) in
            if key == "selfHarm"{
                return key?.camelCaseToWords(separator: "-")
            } else {
                return key?.camelCaseToWords(separator: "/")
            }
        }.joined(separator: ", ")
    }
    enum CodingKeys: String, CodingKey {
        case sexual, hate, violence
        case selfHarm = "self-harm"
        case sexualMinors = "sexual/minors"
        case hateThreatening = "hate/threatening"
        case violenceGraphic = "violence/graphic"
    }
}

// MARK: - CategoryScores
public struct OAIModCategoryScoresModel: Codable, Sendable {
    let sexual, hate, violence, selfHarm: Double
    let sexualMinors, hateThreatening, violenceGraphic: Double

    enum CodingKeys: String, CodingKey {
        case sexual, hate, violence
        case selfHarm = "self-harm"
        case sexualMinors = "sexual/minors"
        case hateThreatening = "hate/threatening"
        case violenceGraphic = "violence/graphic"
    }
}
public enum ModerationModels: String, Codable, Equatable, Hashable, Sendable, CaseIterable {
    case textModerationStable = "text-moderation-stable"
    case textModerationLatest = "text-moderation-latest"
}

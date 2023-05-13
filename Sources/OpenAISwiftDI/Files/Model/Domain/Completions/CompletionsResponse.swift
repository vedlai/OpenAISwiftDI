//
//  CompletionsResponse.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation

// MARK: - CompletionsResponse
/// https://platform.openai.com/docs/api-reference/completions
public struct CompletionsResponse: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    public var object: String
    public var created: Date
    public var model: CompletionsRequest.CompletionsModel
    public var choices: [Choice]
    public var usage: Usage?
    public var parameters: CompletionsRequest?
    public mutating func merge(_ obj: Self) {
        guard obj.id == id else {
            return
        }
        created = obj.created
        object = obj.object
        model = obj.model
        usage = obj.usage
        for choice in obj.choices {
            if let idx = choices.firstIndex(where: { choice in
                choice.index == choice.index
            }) {
                choices[idx].text.append(choice.text)
            } else {
                choices.append(choice)
            }
        }
    }
}
extension Array where Element == CompletionsResponse {
    public mutating func merge(_ obj: Element) -> Int {
        if let index = self.firstIndex(where: { response in
            response.id == obj.id
        }) {
            self[index].merge(obj)
            return index
        } else {
            self.append(obj)
            return self.indices.last!
        }
    }
}
// MARK: - Choice
public struct Choice: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: Int {
        index
    }
    public var text: String

    public let index: Int
    public let finishReason: String?
    public let logprobs: String?

}
// MARK: - Usage
public struct Usage: Codable, Equatable, Hashable, Sendable {
    public let totalTokens, completionTokens, promptTokens: Int

    static func + (lhs: Usage, rhs: Usage) -> Usage {
        Usage(totalTokens: lhs.totalTokens + rhs.totalTokens,
              completionTokens: lhs.completionTokens + rhs.completionTokens,
              promptTokens: lhs.promptTokens + rhs.promptTokens)
    }
}
extension Optional<Usage> {
    static func + (lhs: Usage?, rhs: Usage?) -> Usage {
        let lhs = lhs ?? .init(totalTokens: 0, completionTokens: 0, promptTokens: 0)
        let rhs = rhs ?? .init(totalTokens: 0, completionTokens: 0, promptTokens: 0)
        return lhs + rhs
    }
    static func += (lhs: Usage?, rhs: Usage?) -> Usage {
         lhs + rhs
    }
}

protocol RawCodable: Codable, RawRepresentable where RawValue == String {
}

extension RawCodable {
    public var rawValue: RawValue {
        let encoder = JSONEncoder()
        do {
            let string = try encoder.encode(self)
            return String(data: string, encoding: .utf8) ?? ""
        } catch {
            print(error)
            return error.localizedDescription
        }
    }
    public init?(rawValue: RawValue) {
        guard let data = rawValue.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            self = try decoder.decode(Self.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
}
// Allows all Codable Arrays to be saved using AppStorage
extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

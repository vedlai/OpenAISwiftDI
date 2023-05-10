//
//  ChatCompletionsResponse.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import Foundation
// MARK: - ChatCompletionsResponse
/// https://platform.openai.com/docs/api-reference/chat
public struct ChatCompletionsResponse: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    public var object: String
    public var created: Date
    public var model: ChatCompletionRequest.ChatModel
    public var choices: [ChatChoice]
    /// As of 2-May-2023 Streaming does not provide a Usage value
    public var usage: Usage?
    public var parameters: ChatCompletionRequest?

    public init(id: String,
                object: String,
                created: Date,
                model: ChatCompletionRequest.ChatModel,
                choices: [ChatChoice],
                usage: Usage? = nil,
                parameters: ChatCompletionRequest? = nil) {
        self.id = id
        self.object = object
        self.created = created
        self.model = model
        self.choices = choices
        self.usage = usage
        self.parameters = parameters
    }
    public mutating func merge(_ obj: Self) {
        guard obj.id == id else {
            return
        }
        created = obj.created
        object = obj.object
        model = obj.model
        usage = self.usage + obj.usage
        for choice in obj.choices {
            if let idx = choices.firstIndex(where: { choice in
                choice.index == choice.index
            }) {
                choices[idx].message!.content.append(choice.message!.content)
            } else {
                choices.append(choice)
            }
        }
    }
}
public struct ChatChoice: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: Int {
        index
    }
    let index: Int
    var delta: DeltaMessage?
    var message: ChatMessage?
    let finishReason: String?

    func convertDeltaToMessage(role: ChatMessage.Role = .assistant) -> Self {
        guard let delta = delta else {
            return self
        }
        if message == nil {
            return .init(index: index,
                         message: .init(role: delta.role ?? role, content: delta.content ?? "", name: delta.name),
                         finishReason: finishReason)
        } else {
            var temp = Self(index: index, message: .init(content: ""), finishReason: finishReason)
            temp.message?.content = ((message?.content) ?? "") + (delta.content ?? "")
            temp.delta = nil
            return temp
        }
    }
    enum CodingKeys: String, CodingKey {
        case index
        case delta
        case message
        case finishReason = "finish_reason"
    }
}

extension Array where Element == ChatCompletionsResponse {
    /// Adds the usage object (if available) and provides a total.
    /// As of 2 May 2023 streaming does not provide usage.
    var totalUsage: Usage {
        self.compactMap { response in
            response.usage
        }.reduce(.init(totalTokens: 0, completionTokens: 0, promptTokens: 0)) { partialResult, usage in
            partialResult + usage
        }
    }
    /// Combines all the messages in the choices for easy display
    var messages: [ChatMessage] {
        self.flatMap { response in
            response.choices.compactMap { choice in
                choice.message
            }
        }
    }

    mutating func mergeChunks(newResponse: ChatCompletionsResponse) {
        // Merge the chuncks
        if let index = self.firstIndex(where: { response in
            response.id == newResponse.id
        }) {
            let temp = self[index].usage + newResponse.usage
            // Add Usage
            self[index].usage = temp
            // Merge choices
            let choices = newResponse.choices.filter({ choice in
                choice.delta != nil
            }).map { choice in
                choice.convertDeltaToMessage()
            }
            for choice in choices {
                if let idx = self[index].choices.firstIndex(where: { cho in
                    cho.index == choice.index
                }) {
                    if self[index].choices[idx].message == nil {
                        self[index].choices[idx].message = .init(content: "")
                    }
                    self[index].choices[idx].message?.content.append(choice.message?.content ?? "")
                } else {
                    self[index].choices.append(choice)
                }
            }
            //

        } else {
            var newResponse = newResponse
            let choices = newResponse.choices.map { choice in
                choice.convertDeltaToMessage()
            }
            newResponse.choices = choices
            self.append(newResponse)
        }
    }
}

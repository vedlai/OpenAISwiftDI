//
//  ChatCompletionsResponse.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import Foundation
// MARK: - ChatCompletionsResponse
///https://platform.openai.com/docs/api-reference/chat
public struct ChatCompletionsResponse: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    public var object: String
    public var created: Date
    public var model: ChatCompletionRequest.ChatModel
    public var choices: [ChatChoice]
    ///As of 2-May-2023 Streaming does not provide a Usage value
    public var usage: Usage?
    public var parameters: ChatCompletionRequest?
    
    public init(id: String, object: String, created: Date, model: ChatCompletionRequest.ChatModel, choices: [ChatChoice], usage: Usage? = nil, parameters: ChatCompletionRequest? = nil) {
        self.id = id
        self.object = object
        self.created = created
        self.model = model
        self.choices = choices
        self.usage = usage
        self.parameters = parameters
    }
    public mutating func merge(_ obj: Self) {
        
        guard obj.id == id else{
            return
        }
        created = obj.created
        object = obj.object
        model = obj.model
        usage = self.usage + obj.usage
        for c in obj.choices{
            if let idx = choices.firstIndex(where: { choice in
                choice.index == c.index
            }){
                choices[idx].message!.content.append(c.message!.content)
            }else{
                choices.append(c)
            }
        }
    }
    
}
public struct ChatChoice: Codable, Equatable, Hashable, Identifiable, Sendable{
    
    public var id: Int{
        index
    }
    let index: Int
    var delta: DeltaMessage?
    var message: ChatMessage?
    let finish_reason: String?
    
    func convertDeltaToMessage(role: ChatMessage.Role = .assistant) -> Self {
        guard let delta = delta else {
            return self
        }
        if message == nil{
            return .init(index: index, message: .init(role: delta.role ?? role, content: delta.content ?? "", name: delta.name) ,finish_reason: finish_reason)
        }else {
            var temp = Self(index: index, message: .init(content: ""),finish_reason: finish_reason)
            temp.message?.content = ((message?.content) ?? "") + (delta.content ?? "")
            temp.delta = nil
            return temp
        }
    }
}


extension Array where Element == ChatCompletionsResponse{
    ///Adds the usage object (if available) and provides a total.
    ///As of 2 May 2023 streaming does not provide usage.
    var totalUsage: Usage{
        self.compactMap { r in
            r.usage
        }.reduce(.init(totalTokens: 0, completionTokens: 0, promptTokens: 0)) { partialResult, u in
            partialResult + u
        }
    }
    ///Combines all the messages in the choices for easy display
    var messages: [ChatMessage]{
        self.flatMap { r in
            r.choices.compactMap { c in
                c.message
            }
        }
    }

    mutating func mergeChunks(newResponse: ChatCompletionsResponse) {
        //Merge the chuncks
        if let index = self.firstIndex(where: { r in
            r.id == newResponse.id
        }){
            //Add Usage
            self[index].usage = self[index].usage + newResponse.usage
            
            //Merge choices
            let choices = newResponse.choices.filter({ c in
                c.delta != nil
            }).map { c in
                c.convertDeltaToMessage()
            }
            
            for choice in choices{
                if let i = self[index].choices.firstIndex(where: { c in
                    c.index == choice.index
                }){
                    if self[index].choices[i].message == nil{
                        self[index].choices[i].message = .init(content: "")
                    }
                    self[index].choices[i].message?.content.append(choice.message?.content ?? "")
                }else{
                    self[index].choices.append(choice)
                }
            }
            //

        }else{
            var newResponse = newResponse
            let choices = newResponse.choices.map { c in
                c.convertDeltaToMessage()
            }
            newResponse.choices = choices
            self.append(newResponse)
        }
    }
}


//
//  File.swift
//  
//
//  Created by vedlai on 5/4/23.
//

import Foundation
///https://platform.openai.com/docs/api-reference/edits/create
public struct EditRequest: Codable{
    public var model: EditModels = .textDavinciEdit001
    public var input: String?
    public var instruction: String
    public var temperature: Double?
    public var top_p: Double?
    
    public func validate() throws{
        guard (temperature == nil && top_p == nil) || (temperature != nil && top_p == nil) || (temperature == nil && top_p != nil) else{
            throw PackageErrors.custom("use temperature or top_p but not both")
        }
        //temp
        if let temp = temperature, !(0...2).contains(temp){
            throw PackageErrors.custom("temperature should be between 0...2")
        }
        if let top_p = top_p, !(0...1).contains(top_p){
            throw PackageErrors.custom("top_p should be between 1 & 0")
        }
    }
    public enum EditModels: String, Codable, Equatable, Hashable, Sendable, CaseIterable{
        case textDavinciEdit001 = "text-davinci-edit-001"
        case codeDavinciEdit001 = "code-davinci-edit-001"

    }
}

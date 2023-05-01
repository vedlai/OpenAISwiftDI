//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
///https://platform.openai.com/docs/api-reference/images/create
public struct ImageCreateRequestModel: Codable, Sendable{
    public var prompt: String
    public var n: Int
    public var size: ImageSize
    ///Default is url , bson64 json might come at a later time.
    let response_format: ImageResponseFormat
    public var user: String?
    public init(prompt: String, n: Int = 1, size: ImageSize = .large, user: String? = nil) {
        self.prompt = prompt
        self.n = n
        self.size = size
        self.response_format = .url
        self.user = user
    }
    public func validate() throws{
        guard prompt.count <= 1000 else {
            throw PackageErrors.custom("prompt has a maximum length of 1000 characters.")
        }
        
        guard (0...10).contains(n) else {
            throw PackageErrors.custom("n must be between 1 and 10.")
        }
    }
    
}

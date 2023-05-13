//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//
#if canImport(UIKit)
import Foundation
/// https://platform.openai.com/docs/api-reference/images/create
public struct ImageCreateRequestModel: Codable, Sendable {
    public var prompt: String
    public var number: Int
    public var size: ImageSize
    /// Default is url , bson64 json might come at a later time.
    let responseFormat: ImageResponseFormat
    public var user: String?
    public init(prompt: String,
                number: Int = 1,
                size: ImageSize = .large,
                user: String? = nil) {
        self.prompt = prompt
        self.number = number
        self.size = size
        self.responseFormat = .url
        self.user = user
    }
    public func validate() throws {
        guard !prompt.isEmpty else {
            throw PackageErrors.promptShouldNotBeEmpty
        }

        let promptMax = 1000
        guard prompt.count <= promptMax else {
            throw PackageErrors.promptShouldHaveMaximumOf(1000)
        }

        let nRange = 1.0...10.0
        guard (nRange).contains(Double(number)) else {
            throw PackageErrors.number(nRange)
        }
    }
    enum CodingKeys: String, CodingKey {
        case prompt
        case number = "n"
        case size
        case responseFormat
        case user
    }
}
#endif

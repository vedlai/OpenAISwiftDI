//
//  File.swift
//  
//
//  Created by vedlai on 5/4/23.
//

import Foundation
/// https://platform.openai.com/docs/api-reference/edits/create
public struct EditRequest: Codable, Sendable, Hashable, Equatable {
    public var model: EditModels = .textDavinciEdit001
    public var input: String?
    public var instruction: String
    public var temperature: Double?
    public var topP: Double?

    public func validate() throws {
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

        if let topP = topP, !(topPRange).contains(topP) {
            throw PackageErrors.topPShouldBeBetween(topPRange)
        }
    }
    public enum EditModels: String, Codable, Equatable, Hashable, Sendable, CaseIterable {
        case textDavinciEdit001 = "text-davinci-edit-001"
        case codeDavinciEdit001 = "code-davinci-edit-001"

    }
}

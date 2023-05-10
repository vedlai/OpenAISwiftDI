//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
enum ImageResponseFormat: String, Codable, Equatable, Hashable, Sendable, CaseIterable {
    case url
    case b64json = "b64_json"
}

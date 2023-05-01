//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
enum ImageResponseFormat: String, Codable, Sendable{
    case url
    case b64json = "b64_json"
}

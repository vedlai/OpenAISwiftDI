//
//  OpenAIProviderProtocol+Codable.swift
//  
//
//  Created by vedlai on 5/11/23.
//

import Foundation
extension OpenAIProviderProtocol {
    // MARK: Codable Helpers

    public static func encoder(_ encoder: JSONEncoder) -> JSONEncoder {
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    public static func decoder(_ decoder: JSONDecoder) -> JSONDecoder {
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

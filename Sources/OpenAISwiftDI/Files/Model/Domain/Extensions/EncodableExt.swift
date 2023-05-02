//
//  EncodableExt.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
extension Encodable {
    public func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

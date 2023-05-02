//
//  StringExt.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
extension String {
    public func camelCaseToWords(separator: String = " ") -> String {
        return unicodeScalars.dropFirst().reduce(String(prefix(1))) {
            return (CharacterSet.uppercaseLetters.contains($1)
                ? $0 + separator + String($1)
            : $0 + String($1)).lowercased()
        }
    }
}

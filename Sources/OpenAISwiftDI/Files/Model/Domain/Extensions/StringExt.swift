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
    mutating func snake_cased() {
        self = self.snake_case()
    }

    func snake_case() -> String {
        var result = ""
        var previousCharWasCapitalized = false

        for (index, char) in self.enumerated() {
            var charStr = String(char)

            // remove (ignore) non-alphas
            if !charStr.isAlpha { continue }

            // If capital is found...
            if charStr == charStr.uppercased() {
                // ...lower case it...
                charStr = charStr.lowercased()

                // If it's not the first letter, nor follows another lowercased letter, prepend an underscore
                // (If it followed another operated-on letter, we'd get "JSON" -> "j_s_o_n" instead of "json")
                if
                    index != 0,
                    !previousCharWasCapitalized {
                    charStr = "_" + charStr
                }
                previousCharWasCapitalized = true
            }
                // If capital is not found, mark it for the next cycle, and move on.
            else { previousCharWasCapitalized = false }
            result += charStr
        }
        return result
    }
    var isAlpha: Bool {
        let alphaSet = CharacterSet.uppercaseLetters.union(.lowercaseLetters).union(.whitespacesAndNewlines)
        return self.rangeOfCharacter(from: alphaSet.inverted) == nil
    }
}

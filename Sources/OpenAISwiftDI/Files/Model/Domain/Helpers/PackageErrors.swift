//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
enum PackageErrors: LocalizedError{
    case custom(String)
    
    var errorDescription: String?{
        switch self {
        case .custom(let string):
            return string
        }
    }
}

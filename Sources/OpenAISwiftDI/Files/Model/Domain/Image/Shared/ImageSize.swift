//
//  ImageSize.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
public enum ImageSize: String, Codable, Equatable, Hashable, Sendable, CaseIterable, CustomStringConvertible {
    /// "256x256"
    case small = "256x256"
    /// "512x512"
    case medium = "512x512"
    /// "1024x1024"
    case large = "1024x1024"

    public var description: String {
        switch self {
        case .small:
            return "small".localize()
        case .medium:
            return "medium".localize()
        case .large:
            return "large".localize()
        }
    }
    public var size: CGFloat {
        switch self {
        case .small:
            return 256
        case .medium:
            return 512
        case .large:
            return 1024
        }
    }
}

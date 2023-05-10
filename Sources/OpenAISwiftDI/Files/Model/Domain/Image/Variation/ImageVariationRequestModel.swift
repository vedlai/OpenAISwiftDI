//
//  ImageVariationRequestModel.swift
//  
//
//  Created by vedlai on 4/30/23.
//
#if canImport(UIKit)
import Foundation
import UIKit
// https://platform.openai.com/docs/api-reference/images/create-variation
public struct ImageVariationRequestModel: Sendable {
    public var image: UIImage
    public var number: Int
    public var size: ImageSize
    var responseFormat: ImageResponseFormat
    public var user: String?

    public init(image: UIImage, number: Int, size: ImageSize, user: String? = nil) {
        self.image = image
        self.number = number
        self.size = size
        self.responseFormat = .url
        self.user = user
    }

    public func validate() throws {
        let maxMB = Measurement(value: 4, unit: UnitInformationStorage.megabytes)
        let maxBytes = maxMB.converted(to: .bytes).value

        guard let data = image.pngData() else {
            throw PackageErrors.imageMustBeValidPng
        }
        guard  Double(data.count) < maxBytes else {
            throw PackageErrors.imageSizeShouldNotExceed(maxMB)
        }
        let ratio = image.size.aspectRatio

        guard ratio == 1 else {
            throw PackageErrors.imageMustBeSquare
        }
        let numberRange = 0.0...10.0
        guard (numberRange).contains(Double(number)) else {
            throw PackageErrors.number(numberRange)
        }
    }
    enum CodingKeys: String, CodingKey {
        case image
        case number = "n"
        case size
        case responseFormat = "response_format"
    }
}
#endif

//
//  ImageEditRequestModel.swift
//  
//
//  Created by vedlai on 4/30/23.
//
import SwiftUI
#if canImport(UIKit)
import UIKit

// https://platform.openai.com/docs/api-reference/images/create-edit
public struct ImageEditRequestModel: Sendable {
    public var image: UIImage
    public var mask: UIImage?
    public var prompt: String
    public var number: Int
    public var size: ImageSize
    var responseFormat: ImageResponseFormat
    public var user: String?
    enum CodingKeys: String, CodingKey {
        case prompt
        case number = "n"
        case size
        case responseFormat = "response_format"
        case user
        case mask
        case image
    }
    public init(image: UIImage,
                mask: UIImage? = nil,
                prompt: String,
                number: Int,
                size: ImageSize,
                user: String? = nil) {
        self.image = image
        self.mask = mask
        self.prompt = prompt
        self.number = number
        self.size = size
        self.responseFormat = .url
        self.user = user
    }
    public func validate() throws {
        let maxMB = Measurement.init(value: 4, unit: UnitInformationStorage.megabytes)
        let maxBytes = maxMB.converted(to: .bytes).value
        if let mask = mask {
            guard mask.hasAlpha else {
                throw PackageErrors.maskMustHaveTransparentAreas
            }

            guard mask.size == image.size else {
                throw PackageErrors.imageAndMaskMustHaveTheSameDimensions
            }

            guard let data = mask.pngData() else {
                throw PackageErrors.maskMustBeValidPng
            }
            guard  Double(data.count) < maxBytes else {
                throw PackageErrors.maskSizeShouldNotExceed(maxMB)
            }
        } else {
            guard image.hasAlpha else {
                throw
                PackageErrors.imageMustHaveTransparentAreas
            }
        }
        guard let data = image.pngData() else {
            throw PackageErrors.imageMustBeValidPng
        }
        guard  Double(data.count) < maxBytes else {
            throw PackageErrors.imageSizeShouldNotExceed(maxMB)
        }

        guard image.size.aspectRatio == 1 else {
            throw PackageErrors.imageMustBeSquare
        }

        let promptMax = 1000
        guard prompt.count <= promptMax else {
            throw PackageErrors.promptShouldHaveMaximumOf(promptMax)
        }

        let nRange = 0.0...10.0
        guard (nRange).contains(Double(number)) else {
            throw PackageErrors.number(nRange)
        }
    }
}
#endif
public struct ImageEditRequestUniModel: Sendable {
    public var image: Data
    public var mask: Data?
    public var prompt: String
    public var number: Int
    public var size: ImageSize
    var responseFormat: ImageResponseFormat
    public var user: String?
    enum CodingKeys: String, CodingKey {
        case prompt
        case number = "n"
        case size
        case responseFormat = "response_format"
        case user
        case mask
        case image
    }
    public init(image: Data, mask: Data? = nil, prompt: String, number: Int, size: ImageSize, user: String? = nil) {
        self.image = image
        self.mask = mask
        self.prompt = prompt
        self.number = number
        self.size = size
        self.responseFormat = .url
        self.user = user
    }
    public func validate() throws {
        let maxMB = Measurement.init(value: 4, unit: UnitInformationStorage.megabytes)

        let maxBytes = maxMB.converted(to: .bytes).value
        if let mask = mask {

            guard  Double(mask.count) < maxBytes else {
                throw PackageErrors.maskSizeShouldNotExceed(maxMB)
            }
        }

        guard  Double(image.count) < maxBytes else {
            throw PackageErrors.imageSizeShouldNotExceed(maxMB)
        }
        let promptMax = 1000
        guard prompt.count <= promptMax else {
            throw PackageErrors.promptShouldHaveMaximumOf(promptMax)
        }
        let nRange = 0.0...10.0
        guard (nRange).contains(Double(number)) else {
            throw PackageErrors.number(nRange)
        }
    }
}

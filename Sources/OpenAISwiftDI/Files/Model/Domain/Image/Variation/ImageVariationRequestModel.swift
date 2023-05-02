//
//  ImageVariationRequestModel.swift
//  
//
//  Created by vedlai on 4/30/23.
//
#if canImport(UIKit)
import Foundation
import UIKit
//https://platform.openai.com/docs/api-reference/images/create-variation
public struct ImageVariationRequestModel: Sendable{
    public var image: UIImage
    public var n: Int
    public var size: ImageSize
    var response_format: ImageResponseFormat
    public var user: String?
    
    public init(image: UIImage, n: Int, size: ImageSize, user: String? = nil) {
        self.image = image
        self.n = n
        self.size = size
        self.response_format = .url
        self.user = user
    }
    
    public func validate() throws {
        let maxBytes = 40000000

        guard let data = image.pngData() else {
            throw PackageErrors.custom("Image must be a valid PNG file.")
        }
        guard  data.count < maxBytes else {
            throw PackageErrors.custom("Image size should not exceed 4MB.")
        }
        let ratio = image.size.aspectRatio
        
        guard ratio == 1 else {
            throw PackageErrors.custom("Image must be a square.")
        }
        
        guard (0...10).contains(n) else{
            throw PackageErrors.custom("n must be between 1 and 10.")
        }
    }
}
#endif

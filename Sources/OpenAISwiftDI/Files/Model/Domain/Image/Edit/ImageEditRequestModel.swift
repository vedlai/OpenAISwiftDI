//
//  ImageEditRequestModel.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import UIKit
//https://platform.openai.com/docs/api-reference/images/create-edit
public struct ImageEditRequestModel: Sendable{
    public var image: UIImage
    public var mask: UIImage?
    public var prompt: String
    public var n: Int
    public var size: ImageSize
    var response_format: ImageResponseFormat
    public var user: String?
    
    public init(image: UIImage, mask: UIImage? = nil, prompt: String, n: Int, size: ImageSize, user: String? = nil) {
        self.image = image
        self.mask = mask
        self.prompt = prompt
        self.n = n
        self.size = size
        self.response_format = .url
        self.user = user
    }
    public func validate() throws {
        let maxBytes = 40000000
        if let mask = mask {
            guard mask.hasAlpha else{
                throw PackageErrors.custom("Mask must have transparent areas.")
            }
            
            guard mask.size == image.size else {
                throw PackageErrors.custom("Image and mask must have the same dimensions.")
            }
            
            guard let data = mask.pngData() else {
                throw PackageErrors.custom("Mask must be a valid PNG file.")
            }
            guard  data.count < maxBytes else {
                throw PackageErrors.custom("Mask size should not exceed 4MB.")
            }
        }else {
            guard image.hasAlpha else {
                throw
                PackageErrors.custom("If no mask is included image must have transparent areas.")
            }
        }
        guard let data = image.pngData() else {
            throw PackageErrors.custom("Image must be a valid PNG file.")
        }
        guard  data.count < maxBytes else {
            throw PackageErrors.custom("Image size should not exceed 4MB.")
        }
        
        guard image.size.aspectRatio == 1 else {
            throw PackageErrors.custom("Image must be a square.")
        }
        
        guard prompt.count <= 1000 else{
            throw PackageErrors.custom("prompt maximum length is 1000 characters.")
        }
        
        guard (0...10).contains(n) else{
            throw PackageErrors.custom("n must be between 1 and 10.")
        }
    }
}

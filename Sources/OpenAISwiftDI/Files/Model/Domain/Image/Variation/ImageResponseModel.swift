//
//  ImageResponseModel.swift
//  
//
//  Created by vedlai on 5/1/23.
//
#if canImport(UIKit)
import SwiftUI

public struct ImageResponseModel: OAIImageProtocol {
    public init(data: [ImageDataModel]) {
        self.created = Date()
        self.data = data
    }

    public var created: Date?
    public var prompt: String?
    public var data: [ImageDataModel]
    public var childType: ChildType?
    public func save() async throws {
    }
}

public struct ImageDataModel: OAIImageDataProtocol {
    public var url: URL?
    public var image: UIImage?
    public var mask: UIImage?
    public func save() async throws {
    }
    public init(url: URL? = nil, image: UIImage? = nil, mask: UIImage? = nil) {
        self.url = url
        self.image = image
        self.mask = mask
    }
    public init(image: UIImage?) {
        self.image = image
        self.url = nil
        self.mask = nil
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.url = try container.decodeIfPresent(URL.self, forKey: .url)
        self.image = try container.decodeIfPresent(MyImage.self, forKey: .image)?.value
        self.mask = try container.decodeIfPresent(MyImage.self, forKey: .mask)?.value
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(MyImage(value: image), forKey: .image)
        try container.encode(MyImage(value: mask), forKey: .mask)

    }
    public enum CodingKeys: String, CodingKey {
        case url
        case image = "b64_json"
        case mask
    }
}

@objc(MyImage)
public class MyImage: NSObject, Codable {
    public let value: UIImage?

    public init(value: UIImage?) {
        self.value = value
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value?.pngData()?.base64EncodedString(options: .lineLength64Characters))
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters) else {
            throw ImageError.dataIsMissingOrInavalid
        }

        value = .init(data: data)
    }

    enum ImageError: String, LocalizedError {
        case unableToAddAplhaToImage
        case dataIsMissingOrInavalid
        public var errorDescription: String? {
            rawValue.localizedCapitalized.camelCaseToWords()
        }
    }
}
#endif

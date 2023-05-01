//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import UIKit

// MARK: - OAIImageDataModel
public struct OAIImageDataModel: OAIImageDataProtocol {
    public var mask: UIImage?
    public var image: UIImage?
    
    public let url: URL?
    
    public init(image: UIImage?, url: URL?) {
        self.image = image
        self.url = url
    }
    
    public init(from decoder: Decoder) throws {
        fatalError("not yet implemented")
    }
    public func encode(to encoder: Encoder) throws {
        fatalError("not yet implemented")
    }
    public func save() throws {
        fatalError("not yet implemented")
    }
    public static func sample() -> OAIImageDataModel{
        .init(image: UIImage(systemName: "person")!, url: [URL(string: "https://www.google.com")!].randomElement()!)
    }
}

public protocol OAIImageDataProtocol: Codable, Equatable, Hashable, Sendable{
    
    var url: URL? {get}
    var image: UIImage? {get set}
    var mask: UIImage? {get set}
    
    func save() async throws
    mutating func downloadImage() async throws
}
extension OAIImageDataProtocol{
    //MARK: Helpers
    mutating public func downloadImage() async throws {
        guard let url = url else{
            return
        }
        self.image = try await OpenAIImageManager.downloadImage(url: url)
    }

}

public protocol OAIImageProtocol: Codable, ObservableObject, Equatable, Hashable, AnyObject, Sendable {
    associatedtype S : OAIImageProtocol
    associatedtype D : OAIImageDataProtocol
    var created: Date? {get}
    var data: [D] { get set}
    var prompt: String? {get set}
    var parent: S? {get set}
    var children: [S] {get set}
    var childType: ChildType?  {get set}

    func save() async throws
}
public enum ChildType: String, Sendable{
    case variation
    case edit
    case top
}


//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//
#if canImport(UIKit)
import UIKit

// MARK: - OAIImageDataModel
public struct OAIImageDataModel: OAIImageDataProtocol {
    public init(image: UIImage?) {
        self.image = image
        self.url = nil
    }
    
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

}

public protocol OAIImageDataProtocol: Codable, Equatable, Hashable, Sendable{
    
    var url: URL? {get}
    var image: UIImage? {get set}
    var mask: UIImage? {get set}
    
    init(image: UIImage?)
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

public protocol OAIImageProtocol: Codable, Equatable, Hashable, Sendable {
    associatedtype D : OAIImageDataProtocol
    var created: Date? {get}
    var data: [D] { get set}
    var prompt: String? {get set}
    var childType: ChildType?  {get set}
    
    init(data: [D])
    func save() async throws

}

public protocol OAIImageReferenceProtocol: OAIImageProtocol, ObservableObject, AnyObject {
    associatedtype S : OAIImageReferenceProtocol
    var parent: S? {get set}
    var children: [S] {get set}

}
public enum ChildType: String, Codable, Equatable, Hashable, Sendable, CaseIterable{
    case variation
    case edit
    case top
}

#endif

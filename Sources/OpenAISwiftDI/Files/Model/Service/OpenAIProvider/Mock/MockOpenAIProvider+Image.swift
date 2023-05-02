//
//  MockOpenAIProvider+Image.swift
//  
//
//  Created by vedlai on 5/1/23.
//
#if canImport(UIKit)
import SwiftUI
extension MockOpenAIProvider{
    func generateImage<O>(request: ImageCreateRequestModel) async throws -> O where O : OAIImageProtocol {
        try request.validate()
        let image = await MainActor.run {
            ZStack{
                Color.green
                Text(request.prompt) +
                Text(request.size.rawValue)
            }
                .frame(width: request.size.size, height: request.size.size)
                .snapshot()
        }
        return .init(data: [.init(image:image)])
    }
    func generateImageEditWMask<O>(request: ImageEditRequestModel) async throws -> O where O : OAIImageProtocol {
        try request.validate()
        
        let image = await MainActor.run {
            
        ZStack{
            Color.green
            Text(request.prompt) +
            Text(request.size.rawValue)
            Image(uiImage: request.mask!)
        }.aspectRatio(1, contentMode: .fit)
                .frame(width: request.size.size)
                .snapshot()
        }
        return .init(data: [.init(image:image)])
        
    }
    func generateImageEdit<O>(request: ImageEditRequestModel) async throws -> O where O : OAIImageProtocol {
        try request.validate()
        let image = await MainActor.run {
            return ZStack{
                Color.green
                Text(request.prompt) +
                Text(request.size.rawValue)
                Image(uiImage: request.image)
            }.aspectRatio(1, contentMode: .fit)
                .frame(width: request.size.size)
                .snapshot()
        }
        return .init(data: [.init(image:image)])
    }
    func generateImageVariation<O>(request: ImageVariationRequestModel) async throws -> O where O : OAIImageProtocol {
        try request.validate()
        let image = await MainActor.run {
            ZStack{
                Text(request.size.rawValue)
                Image(uiImage: request.image)
                    .resizable()
                Circle()
                    .fill(Color.red)
                    .border(Color.blue)
                    .frame(width: 20)
                    .position(.init(x: (0...Int(request.size.size)).randomElement()!, y: (0...Int(request.size.size)).randomElement()!))
        }
                .aspectRatio(1, contentMode: .fit)
                .frame(width: request.size.size)
                .snapshot()
        }
        return .init(data: [.init(image:image)])
    }
}
#endif

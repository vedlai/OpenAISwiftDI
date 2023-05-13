//
//  MockOpenAIProvider+Image.swift
//  
//
//  Created by vedlai on 5/1/23.
//
#if canImport(UIKit)
import SwiftUI
extension MockOpenAIProvider {
    public func generateImage<O>(request: ImageCreateRequestModel) async throws -> O where O: OAIImageProtocol {
        try request.validate()
        let image = await MainActor.run {
            ZStack {
                Color.green
                Text(request.prompt) +
                Text(request.size.rawValue)
            }
                .frame(width: request.size.size, height: request.size.size)
                .snapshot()
        }
        return O(data: [.init(image: image)])
    }

    public func generateImageEditWMask<O>(request: ImageEditRequestUniModel) async throws ->
    O where O: OAIImageProtocol {
        try request.validate()

#if canImport(UIKit)
        if let ios = request.toIOSVersion() {
            try ios.validate()
        }
#endif

        let image = await MainActor.run {

        ZStack {
            Color.green
            Text(request.prompt) +
            Text(request.size.rawValue)
            if let mask = request.mask, let image = UIImage(data: mask) {
                Image(uiImage: image)
            } else {
                Text(String.maskIsNotValidImage)
            }
        }.aspectRatio(1, contentMode: .fit)
                .frame(width: request.size.size)
                .snapshot()
        }
        return .init(data: [.init(image: image)])

    }
    public func generateImageEdit<O>(request: ImageEditRequestUniModel) async throws -> O where O: OAIImageProtocol {
        try request.validate()

#if canImport(UIKit)
        if let ios = request.toIOSVersion() {
            try ios.validate()
        } else {
            throw PackageErrors.imageMustBeValidPng
        }
#endif
        let image = await MainActor.run {
            return ZStack {
                Color.green
                Text(request.prompt) +
                Text(request.size.rawValue)
                if let image = UIImage(data: request.image) {
                    Image(uiImage: image)
                } else {
                    Text(String.imageIsNotValid)
                }
            }.aspectRatio(1, contentMode: .fit)
                .frame(width: request.size.size)
                .snapshot()
        }
        return .init(data: [.init(image: image)])
    }

    public func generateImageVariation<O>(request: ImageVariationRequestModel) async throws ->
    O where O: OAIImageProtocol {
        try request.validate()
        let image = await MainActor.run {
            ZStack {
                Text(request.size.rawValue)
                Image(uiImage: request.image)
                    .resizable()
                Circle()
                    .fill(Color.red)
                    .border(Color.blue)
                    .frame(width: 20)
                    .position(.init(x: (0...Int(request.size.size))
                        .randomElement()!,
                                    y: (0...Int(request.size.size))
                        .randomElement()!))
        }
                .aspectRatio(1, contentMode: .fit)
                .frame(width: request.size.size)
                .snapshot()
        }
        return .init(data: [.init(image: image)])
    }
}
#endif

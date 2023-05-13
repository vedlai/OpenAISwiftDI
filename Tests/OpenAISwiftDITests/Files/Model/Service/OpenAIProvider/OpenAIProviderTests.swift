//
//  OpenAIProvider.swift
//  
//
//  Created by vedlai on 5/11/23.
//

import XCTest
import SwiftUI
@testable import OpenAISwiftDI
final class OpenAIProviderTests: XCTestCase {
    @Injected(\.openAIProvider) var provider
    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModedrations() async throws {
        var input = "violence"
            var result = try await provider.checkModeration(input: input, model: .textModerationLatest)
            
        
        var firstResult = result.results.first
        XCTAssert(firstResult?.flagged == true)
        XCTAssert(firstResult?.categories.violence == true)
        XCTAssert(result.prompt == input)
        
        input = "sexual"
        result = try await provider.checkModeration(input: input, model: .textModerationLatest)
        
        firstResult = result.results.first
        XCTAssert(firstResult?.flagged == true)
        print(result)
        XCTAssert(firstResult?.categories.sexual == true)
        XCTAssert(result.prompt == input)
        
    }
#if canImport(UIKit)
    func testGenerateImage() async throws {
        let request: ImageCreateRequestModel = .init(prompt: "test prompt")
        let response: ImageResponseModel = try await provider.generateImage(request: request)
        
        XCTAssert(!response.data.isEmpty)
    }
    
    @available(iOS 15.0, *)
    func testGenerateEdit() async throws {
        let request: ImageEditRequestUniModel = .init(image: await noAlpha(), prompt: "test edit", number: 1, size: .large)
        do {
            let _: ImageResponseModel = try await provider.generateImageEdit(request: request)
            XCTFail("No image alpha and no mask")
        } catch {
            //PASS
            XCTAssert(error.localizedDescription == PackageErrors.imageMustHaveTransparentAreas.localizedDescription)

        }
        
        let requestPass: ImageEditRequestUniModel = .init(image: await wAlpha(), prompt: "test edit", number: 1, size: .large)
            let _: ImageResponseModel = try await provider.generateImageEdit(request: requestPass)
        
        let requestPass2: ImageEditRequestUniModel = .init(image: await noAlpha(), mask: await wAlpha(), prompt: "test edit", number: 1, size: .large)
            let _: ImageResponseModel = try await provider.generateImageEditWMask(request: requestPass2)
        
        let iASImage = await incorrectAS()
        
        let request2: ImageEditRequestUniModel = .init(image: iASImage.pngData()!, prompt: "test edit", number: 1, size: .large)
        do {
            let _: ImageResponseModel = try await provider.generateImageEdit(request: request2)
            XCTFail("Incorrect aspect ratio, should be 1")
        } catch {
            //PASS
            XCTAssert(error.localizedDescription == PackageErrors.imageMustBeSquare.localizedDescription)

        }
        
        let request3: ImageEditRequestUniModel = .init(image: await noAlpha(), mask: await noAlpha(), prompt: "test edit", number: 1, size: .large)
        do {
            let _: ImageResponseModel = try await provider.generateImageEdit(request: request3)
            XCTFail("No image alpha and no mask alpha")
        } catch {
            //PASS
            XCTAssert(error.localizedDescription == PackageErrors.maskMustHaveTransparentAreas.localizedDescription)

        }
        let request4: ImageEditRequestUniModel = .init(image: await wAlpha(), prompt: "test edit", number: 0, size: .large)
        do {
            let _: ImageResponseModel = try await provider.generateImageEdit(request: request4)
            XCTFail("number is below range, should fail")
        } catch {
            //PASS
        }
        let request5: ImageEditRequestUniModel = .init(image: await wAlpha(), prompt: "test edit", number: 11, size: .large)
        do {
            let _: ImageResponseModel = try await provider.generateImageEdit(request: request5)
            XCTFail("number is above range")
        } catch {
            //PASS
            XCTAssert(error.localizedDescription == PackageErrors.number(1.0...10.0).localizedDescription)

        }
        
    }
    func testGenerateVariation() async throws{
        let request1: ImageVariationRequestModel = .init(image: .init(), number: 1, size: .small)
        do {
            let _: ImageResponseModel = try await provider.generateImageVariation(request: request1)
            XCTFail("Image should have been an invalid PNG")
        } catch {
            //PASS
            XCTAssert(error.localizedDescription == PackageErrors.imageMustBeValidPng.localizedDescription)

        }
        let request2: ImageVariationRequestModel = .init(image: await incorrectAS(), number: 1, size: .small)
        do {
            let _: ImageResponseModel = try await provider.generateImageVariation(request: request2)
            XCTFail("Image should have invalid aspect ratio")
        } catch {
            //PASS
            XCTAssert(error.localizedDescription == PackageErrors.imageMustBeSquare.localizedDescription)
        }
        let goodImage = UIImage(data: await noAlpha())!
        let request2Pass: ImageVariationRequestModel = .init(image: goodImage, number: 1, size: .small)
            let _: ImageResponseModel = try await provider.generateImageVariation(request: request2Pass)
        
        let request3: ImageVariationRequestModel = .init(image: goodImage, number: 0, size: .small)
        do {
            let _: ImageResponseModel = try await provider.generateImageVariation(request: request3)
            XCTFail("Number should be below zero")
        } catch {
            //PASS
            XCTAssert(error.localizedDescription == PackageErrors.number(1.0...10.0).localizedDescription)
        }
        
        let request4: ImageVariationRequestModel = .init(image: goodImage, number: 11, size: .small)
        
        do {
            let _: ImageResponseModel = try await provider.generateImageVariation(request: request4)
            XCTFail("Number should be above 10 (max)")
        } catch {
            //PASS
            XCTAssert(error.localizedDescription == PackageErrors.number(1.0...10.0).localizedDescription)
        }

    }
    
    func incorrectAS() async -> UIImage  {
        return await MainActor.run{
            Rectangle()
                .fill(Color.black)
                .frame(width: 100)
                .aspectRatio(1.5, contentMode: .fill)
            
                .snapshot()
        }
    }
    
    func noAlpha() async -> Data  {
        let iWAlpha =  await MainActor.run{
            Rectangle()
                .fill(Color.black)
                .frame(width:500, height:500)
                .aspectRatio(1, contentMode: .fit)
                .snapshot()
        }
        
        return iWAlpha.jpegData(compressionQuality: 1)!
    }
    
    func wAlpha() async -> Data {
        let data = await noAlpha()
        let image = UIImage(data: data)!.processPixels(location: .init(x: 100, y: 100))
        return image!.pngData()!
    }
    #endif
}

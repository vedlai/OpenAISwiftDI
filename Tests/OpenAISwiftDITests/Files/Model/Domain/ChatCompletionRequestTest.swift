//
//  ChatCompletionRequestTest.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import XCTest
@testable import OpenAISwiftDI
final class ChatCompletionRequestTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidate() throws {
       var new = ChatCompletionRequest()
        
        try new.validate()
        
        new.messages.removeAll()
        new.messages.append(.init(content: "", name: "a"))// pass
        try new.validate()
        
        new.messages.removeAll()
        new.messages.append(.init(content: "", name: "A"))// pass
        try new.validate()
        
        new.messages.removeAll()
        new.messages.append(.init(content: "", name: "_"))// pass
        try new.validate()
    
        new.messages.removeAll()
        new.messages.append(.init(content: "", name: "*"))//Fail special
        XCTAssertThrowsError(try new.validate())
        
        new.messages.removeAll()
        new.messages.append(.init(content: "", name: "aAbB1_"))// pass
        try new.validate()
        
        new.temperature = -1 //Fail range 0...2
        XCTAssertThrowsError(try new.validate())
        
        new.temperature = 2.1 //Fail range 0...2
        XCTAssertThrowsError(try new.validate())
        
        new.temperature = 0 //Pass range 0...2
        try new.validate()
        
        new.temperature = 2 //Pass range 0...2
        try new.validate()
        
        new.temperature = 1 //Pass range 0...2
        try new.validate()
        
        new.top_p = 1 //Fail both temp and top set
        XCTAssertThrowsError(try new.validate())
        
        new.temperature = nil //Pass
        try new.validate()
        
        new.presence_penalty = -2.1 //Fail
        XCTAssertThrowsError(try new.validate())
        
        new.presence_penalty = 2.1 //Fail
        XCTAssertThrowsError(try new.validate())
        
        new.presence_penalty = -2 //Pass
        try new.validate()

        new.presence_penalty = 2 //Pass
        try new.validate()
        
        new.presence_penalty = 1 //Pass
        try new.validate()
        //frequency_penalty
        new.frequency_penalty = -2.1 //Fail
        XCTAssertThrowsError(try new.validate())
        
        new.frequency_penalty = 2.1 //Fail
        XCTAssertThrowsError(try new.validate())
        
        new.frequency_penalty = -2 //Pass
        try new.validate()

        new.frequency_penalty = 2 //Pass
        try new.validate()
        
        new.frequency_penalty = 1 //Pass
        try new.validate()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

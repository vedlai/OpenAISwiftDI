//
//  File.swift
//  
//
//  Created by vedlai on 5/11/23.
//

import Foundation
import OpenAISwiftDI
public struct ProviderSetup{
    typealias TestProvider = MockOpenAIProvider
    typealias ProductionProvider = URLSessionOpenAIProvider
    
    public static var isTestingProduction: Bool = false
    
    public static func checkProvider<O: OpenAIProviderProtocol>(provider: O) throws {
        if provider is TestProvider{
            //Continue
        } else if provider is ProductionProvider && isTestingProduction{
            //Continue
        } else {
            throw PackageErrors.custom("attempting to test with \(type(of: self))")
        }
    }
    public static func injectProvider() {
        
    }
}

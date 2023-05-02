//
//  OpenAIEndpoints.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
public enum OpenAIEndpoints: String{
    case completions = "/v1/completions"
    case imagesGenerations = "/v1/images/generations"
    case imagesEdits = "/v1/images/edits"
    case imagesVariations = "/v1/images/variations"
    case moderations = "/v1/moderations"
    case chatCompletions = "/v1/chat/completions"
}

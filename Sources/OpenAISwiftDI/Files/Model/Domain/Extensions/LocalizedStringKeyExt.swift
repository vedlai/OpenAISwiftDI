//
//  LocalizedStringKeyExt.swift
//  
//
//  Created by vedlai on 5/6/23.
//

import SwiftUI
extension String {
    static let enterPromptHere: Self = "enterPromptHere".localize()
    static let maskIsNotValidImage: Self = "maskIsNotValidImage".localize()
    static let imageIsNotValid: Self = "imageIsNotValid".localize()
    static let submitARequestToSeeAResponse: Self = "submitARequestToSeeAResponse".localize()
    static let addInputHere: Self = "addInputHere".localize()
    static let addInstructionHere: Self = "addInstructionHere".localize()
    static let enterInputAndResponse: Self = "enterInputAndResponse".localize()
    static let editImage: Self = "editImage".localize()
    static let enterPromptAndGenerateImage: Self = "enterPromptAndGenerateImage".localize()
    static let showMask: Self = "showMask".localize()
    static let addPrompt: Self = "addPrompt".localize()
    static let addMaskWithTransparentArea: Self = "addMaskWithTransparentArea".localize()
    static let addImageToRequest: Self = "addImageToRequest".localize()
    static let editImageAndSubmitRequest: Self = "editImageAndSubmitRequest".localize()
    static let tapImageToCreateTransparentArea: Self = "tapImageToCreateTransparentArea".localize()
    static let imageSize: Self = "imageSize".localize()
    static let createVariation: Self = "createVariation".localize()
    static let generateSample: Self = "generateSample".localize()
    static let pressSubmitToGenerateSample: Self = "pressSubmitToGenerateSample".localize()

    static let sample: Self = "sample".localizedCapitalized
    static let reset: Self = "reset".localizedCapitalized

    static let edit: Self = "edit".localizedCapitalized
    static let submit: Self = "submit".localizedCapitalized
    static let stream: Self = "stream".localizedCapitalized
    static let request: Self = "request".localizedCapitalized
    static let response: Self = "response".localizedCapitalized
    static let input: Self = "input".localizedCapitalized
    static let instruction: Self = "instruction".localizedCapitalized
    static let okay: Self = "ok".localizedCapitalized
    static let generate: Self = "generate".localizedCapitalized

    var key: LocalizedStringKey {
        LocalizedStringKey(self)
    }
    func localize(_ comment: String = "default") -> Self {
        var value = NSLocalizedString(self, comment: comment)
        if !value.contains(" ") {
            value = value.camelCaseToWords()
        }
        return value.capitalized
    }
}

extension LocalizedStringKey {
    static func getString(_ str: String) -> LocalizedStringKey {
        LocalizedStringKey(str)
    }

}

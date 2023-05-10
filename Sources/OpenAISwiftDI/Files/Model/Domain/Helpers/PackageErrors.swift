//
//  File.swift
//  
//
//  Created by vedlai on 4/30/23.
//

import Foundation
/// Unit doesnt change without replacement
extension UnitInformationStorage: @unchecked Sendable {}

enum PackageErrors: LocalizedError {
    case imageMustBeValidPng
    case maskMustBeValidPng
    case imageMustHaveTransparentAreas
    case maskMustHaveTransparentAreas
    case imageMustBeSquare
    case nameComponents
    case useTemperatureOrTopPButNotBoth
    case imageAndMaskMustHaveTheSameDimensions
    case streamingIsNotSupportedForThisOS
    case promptShouldNotBeEmpty
    case maskSizeShouldNotExceed(Measurement<UnitInformationStorage>)
    case imageSizeShouldNotExceed(Measurement<UnitInformationStorage>)
    case number(ClosedRange<Double>)
    case temperatureShouldBeBetween(ClosedRange<Double>)
    case topPShouldBeBetween(ClosedRange<Double>)
    case presencePenaltyShouldBeBetween(ClosedRange<Double>)
    case frequencyPenaltyShouldBeBetween(ClosedRange<Double>)
    case maxTokensForModelIs(model: String, tokens: Int)
    case maxLetterCountIs(Int)
    case promptShouldHaveMaximumOf(Int)
    case custom(String)
    var errorDescription: String? {
        switch self {
        case .promptShouldNotBeEmpty:
            return "mustProvideAPrompt".localize()
        case .nameComponents:
            return "nameMustBeComposedOfLettersNumbersAndUnderscore".localize()
        case .maskSizeShouldNotExceed(let measurement):
            // guard #available(iOS 15.0, *), #available(macOS 12.0, *) else {
                return "maskSizeShouldNotExceed".localize() + " \(measurement.description)"
           // }
            // return "maskSizeShouldNotExceed".localize() + "
            // \(measurement.formatted(.measurement(width: .abbreviated)))"
        case .imageSizeShouldNotExceed(let measurement):
            // guard #available(iOS 15.0, *), #available(macOS 12.0, *) else {
                return "imageSizeShouldNotExceed".localize() + " \(measurement.description)"
            // }
            // return "imageSizeShouldNotExceed".localize() +
            // " \(measurement.formatted(.measurement(width: .abbreviated)))"
        case .custom(let string):
            return string
        case .number(let range):
            return "numberShouldBeBetween".localize("numberShouldBeBetween \(range)") + " \(range)"
        case .promptShouldHaveMaximumOf(let charCount):
            return "promptShouldHaveMaximumOf".localize() + "\(charCount)" + "characters.".localize()
        case .maxLetterCountIs(let number):
            return "maxLetterCountIs".localize("maxLetterCountIs \(number)") + " \(number)"
        case .temperatureShouldBeBetween(let range):
            return "temperatureShouldBeBetween".localize("temperatureShouldBeBetween \(range)") + " \(range)"
        case .topPShouldBeBetween(let range):
            return "top_p "  + "shouldBeBetween"
                .localize("top_p shouldBeBetween \(range)") + " \(range)"
        case .presencePenaltyShouldBeBetween(let range):
            return "presence_penalty "  + "shouldBeBetween"
                .localize("presence_penalty shouldBeBetween \(range)") + " \(range)"
        case .frequencyPenaltyShouldBeBetween(let range):
            return "frequency_penalty "  + "shouldBeBetween"
                .localize("frequency_penalty shouldBeBetween \(range)") + " \(range)"
        case .maxTokensForModelIs(let model, let count):
            return "maxTokensFor"
                .localize("maxTokensFor model is count") + model + "is".localize() + count.description + "."
        default:
            return "\(self)".localize()
        }
    }
}

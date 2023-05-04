//
//  File.swift
//  
//
//  Created by vedlai on 5/4/23.
//

import SwiftUI

extension Binding {
    public init(_ source: Binding<Value?>, _ defaultValue: Value) {
        self = Binding {
            source.wrappedValue ?? defaultValue
        } set: { newValue in
            source.wrappedValue = newValue
        }

    }
}


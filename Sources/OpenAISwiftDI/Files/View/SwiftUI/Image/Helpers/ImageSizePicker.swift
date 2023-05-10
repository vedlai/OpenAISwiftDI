//
//  ImageSizePicker.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI

public struct ImageSizePicker: View {
    @Binding var size: ImageSize
    public init(size: Binding<ImageSize>) {
        self._size = size
    }
    public var body: some View {
        Picker(.getString(.imageSize), selection: $size) {
            ForEach(ImageSize.allCases, id: \.rawValue) { size in
                Text(size.rawValue)
                    .tag(size)
            }
        }
    }
}

struct ImageSizePicker_Previews: PreviewProvider {
    static var previews: some View {
        ImageSizePicker(size: .constant(.large))
    }
}

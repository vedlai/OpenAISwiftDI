//
//  CGSizeExt.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import Foundation
extension CGSize {
    /// Height/Width
    var aspectRatio: CGFloat {
        self.height/self.width
    }
}

//
//  CropBarArea.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Foundation
import SwiftUI

func cropMiddle(of cgImage: CGImage, divider number: Float) -> CGImage? {
    let width = Float(cgImage.width)
    let height = Float(cgImage.height)

    let newHeight = height / 21
    let startY = (height - newHeight) / 2
    
    let newWidth = width / number
    let startX = (width - newWidth) / 2

    let rect = CGRect(x: CGFloat(startX),
                      y: CGFloat(startY),
                      width: CGFloat(newWidth),
                      height: CGFloat(newHeight))

    return cgImage.cropping(to: rect)
}


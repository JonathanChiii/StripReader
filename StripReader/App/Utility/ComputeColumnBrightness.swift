//
//  ComputeColumnBrightness.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/19/25.
//

import Foundation
import CoreGraphics

// Extract redness values column by column
func computeColumnRedness(from cgImage: CGImage) -> [CGFloat] {
    let width = cgImage.width
    let height = cgImage.height

    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width

    guard let data = cgImage.dataProvider?.data,
          let ptr = CFDataGetBytePtr(data) else {
        return []
    }

    var redness = [CGFloat](repeating: 0, count: width)

    for x in 0..<width {
        var sum: CGFloat = 0
        for y in 0..<height {
            let offset = y * bytesPerRow + x * bytesPerPixel
            let r = CGFloat(ptr[offset + 0])
            let g = CGFloat(ptr[offset + 1])
            sum += max(0, r - g)   // pink signal
        }
        redness[x] = sum / CGFloat(height)
    }
    return redness
}



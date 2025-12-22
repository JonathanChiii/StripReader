//
//  ComputeColumnRedness.swift
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
    print("Cropped Image Height: \(height) Width: \(width)")

    guard let data = cgImage.dataProvider?.data,
          let ptr = CFDataGetBytePtr(data) else {
        return []
    }

    var values = [CGFloat](repeating: 0, count: width)
    
    
    // Sampling bounds
    let topY = Int(CGFloat(height) * 0.20)
    let bottomY = Int(CGFloat(height) * 0.80)
    
    for x in 0..<width {
        var sum: CGFloat = 0
        var count: CGFloat = 0

        for y in topY..<bottomY {
            let offset = (y * width + x) * 4

            let b = CGFloat(ptr[offset    ]) / 255.0
            let g = CGFloat(ptr[offset + 1]) / 255.0
            let r = CGFloat(ptr[offset + 2]) / 255.0

            // Luminance filtering
            let Y = 0.299*r + 0.587*g + 0.114*b

            if Y < 0.3 { continue }  // too dark
            if Y > 0.8 { continue }  // too bright
            
            // Gentle pink detection
            let redScore1 = max(0, (r - 0.8*g) + (r - 0.8*b))
            let redScore2 = max(0, 1.3*r - g - b)
            let redScore3 = r - (g + b)/2
            let redScore4 = max(0, r - max(g, b))
            let redScore = (redScore1 + redScore2 + redScore3 + redScore4)/4
            print("red score: \(redScore1), \(redScore2), \(redScore3), \(redScore4)")
            sum += redScore1
            count += 1
        }

        values[x] = (count > 0) ? sum / count : 0
    }

    // Normalize 0–1
    let minV = values.min() ?? 0
    let maxV = values.max() ?? 1
    let range = max(maxV - minV, 0.0001)

    print("Raw Redness values: \(values)");
    return values.map { ($0 - minV) / range }
}

func computeColumnBrightness(from cgImage: CGImage) -> [CGFloat] {
    let width = cgImage.width
    let height = cgImage.height

    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width

    guard let data = cgImage.dataProvider?.data,
          let ptr = CFDataGetBytePtr(data) else {
        return []
    }

    var brightness = Array(repeating: CGFloat(0), count: height)

    for y in 0..<height {
        var total: CGFloat = 0

        for x in 0..<width {
            let offset = y * bytesPerRow + x * bytesPerPixel

            let r = CGFloat(ptr[offset + 0])
            let g = CGFloat(ptr[offset + 1])
            let b = CGFloat(ptr[offset + 2])

            // luminance formula (Rec. 601)
            let lum = 0.299 * r + 0.587 * g + 0.114 * b
            //if lum < 0.3 { continue }  // too dark
            //if lum > 0.8 { continue }  // too bright
            total += lum
        }

        brightness[y] = total / CGFloat(width) / 255.0
    }
    print("Brightness: \(brightness)")
    print("Brightness length: \(brightness.count), width: \(width) height: \(height)")
    return brightness
}





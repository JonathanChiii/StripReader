//
//  ComputeColumnColorScore.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/19/25.
//

import Foundation
import CoreGraphics
import SwiftUI

func computeColumnColorScore(from cgImage: CGImage, colorFunction i: Int) -> [CGFloat] {
    let width = cgImage.width
    let height = cgImage.height

    let bytesPerPixel = 4
    //let bytesPerRow = bytesPerPixel * width
    let bytesPerRow = cgImage.bytesPerRow

    guard let data = cgImage.dataProvider?.data,
          let ptr = CFDataGetBytePtr(data) else {
        return []
    }

    var colorScores = Array(repeating: CGFloat(0), count: width)

    for x in 0..<width {
        var total: CGFloat = 0

        for y in 0..<height {
            let offset = y * bytesPerRow + x * bytesPerPixel

            let b = CGFloat(ptr[offset + 0])
            let g = CGFloat(ptr[offset + 1])
            let r = CGFloat(ptr[offset + 2])
            var score:CGFloat = 0
            if (i == 1) {
                score = pinknessScore(r: r, g: g, b: b)
            } else if (i == 2) {
                score = gentlePinknessScore(r: r, g: g, b: b)
            } else {
                score = luminanceScore(r: r, g: g, b: b)
            }
            total += score
        }

        colorScores[x] = total / CGFloat(height)
    }
    //print("Color Score: \(colorScores)")
    return colorScores
}

func pinknessScore(r: CGFloat, g: CGFloat, b: CGFloat) -> CGFloat {
    // Convert RGB -> HSV
    var h: CGFloat = 0
    var s: CGFloat = 0
    var v: CGFloat = 0
    UIColor(red: r, green: g, blue: b, alpha: 1).getHue(&h, saturation: &s, brightness: &v, alpha: nil)

    // Hue comes as 0...1, convert to degrees
    let hueDeg = h * 360

    // Ideal pink/magenta hue
    let target: CGFloat = 300 // degrees

    // Angular distance between hue and magenta
    let diff = abs(hueDeg - target)
    let hueDist = min(diff, 360 - diff)    // wrap around

    // Map hue distance into a gaussian-like falloff
    let hueWeight = exp(-pow(hueDist / 60, 2)) // 30–60° tolerance

    // Final pinkness score
    return s * hueWeight * 8.0  // saturated + near-magenta = high score
}


func gentlePinknessScore(r: CGFloat, g: CGFloat, b: CGFloat) -> CGFloat {
    // Gentle pink detection
    let redScore1 = max(0, (r - 0.8*g) + (r - 0.8*b))
    let redScore2 = max(0, 1.3*r - g - b)
    let redScore3 = r - (g + b)/2
    let redScore4 = max(0, r - max(g, b))
    let redScore = (redScore1 + redScore2 + redScore3 + redScore4)/4
    return redScore / 100.0;
}

func luminanceScore(r: CGFloat, g: CGFloat, b: CGFloat) -> CGFloat {
    // luminance formula (Rec. 601)
    let luminance = 0.299 * r + 0.587 * g + 0.114 * b
    let normalizedLuminance = luminance / 255.0
    return normalizedLuminance;
}





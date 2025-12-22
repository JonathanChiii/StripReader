//
//  AnalyzeBarColors.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/19/25.
//

import Foundation
import CoreGraphics
import UIKit


// Compute average color & intensity for each region
func analyzeBarColors(from cgImage: CGImage, regions: [BarRegion]) -> [BarResult] {
    let width = cgImage.width
    let height = cgImage.height

    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width

    guard let data = cgImage.dataProvider?.data,
          let ptr = CFDataGetBytePtr(data) else {
        return []
    }

    var results: [BarResult] = []

    for (idx, region) in regions.enumerated() {
        var sumR: CGFloat = 0
        var sumG: CGFloat = 0
        var sumB: CGFloat = 0
        var count: Int = 0

        for x in region.start...region.end {
            for y in 0..<height {
                let offset = y * bytesPerRow + x * bytesPerPixel

                sumR += CGFloat(ptr[offset + 0])
                sumG += CGFloat(ptr[offset + 1])
                sumB += CGFloat(ptr[offset + 2])

                count += 1
            }
        }

        let avgR = sumR / CGFloat(count)
        let avgG = sumG / CGFloat(count)
        let avgB = sumB / CGFloat(count)

        let color = UIColor(
            red: avgR / 255,
            green: avgG / 255,
            blue: avgB / 255,
            alpha: 1
        )

        // Brightness (0 - 1)
        let intensity = (0.299 * avgR + 0.587 * avgG + 0.114 * avgB) / 255.0

        results.append(
            BarResult(index: idx + 1, intensity: intensity, color: color)
        )
    }

    return results
}

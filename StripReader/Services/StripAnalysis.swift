//
//  StripAnalysis.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/16/25.
//

import Foundation
import CoreGraphics
import SwiftUI

func analyzeStrip(image: UIImage) -> [BarResult] {
    
    // 1. Crop center band
//       guard let bandImage = centerHorizontalBand(from: image) else {
//           return []
//       }
//
//       // 2. Column brightness
//       let brightness = columnBrightnessValues(from: bandImage)
//
//       // 3. Smooth
//       let smoothed = smooth(values: brightness, windowSize: 7)
//
//       // 4. Detect bar regions
//       let regions = detectBarRegions(from: smoothed,
//                                      darkThreshold: 0.7,   // tune this!
//                                      minWidth: 5)
//
//       // 5. Per-bar average color/intensity
//       let bars = barResults(from: bandImage, regions: regions)
//       return bars
    
    
    // TODO: Replace with real image processing:
    // 1. Crop strip region
    // 2. Detect vertical bar regions
    // 3. Compute average color & intensity per bar

    // Temporary fake data so you can see the UI working:
    return [
        BarResult(index: 1, intensity: 0.25, color: .red),
        BarResult(index: 2, intensity: 0.55, color: .green),
        BarResult(index: 3, intensity: 0.85, color: .blue)
    ]
}

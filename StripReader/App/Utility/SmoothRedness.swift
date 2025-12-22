//
//  SmoothRedness.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/19/25.
//

import Foundation

// Smooth brightness (moving average)
func smooth(_ values: [CGFloat], windowSize: Int = 5) -> [CGFloat] {
    guard windowSize > 1 else { return values }
    var result = values
    let half = windowSize / 2

    for i in 0..<values.count {
        let start = max(0, i - half)
        let end = min(values.count - 1, i + half)
        let s = values[start...end]
        result[i] = s.reduce(0, +) / CGFloat(s.count)
    }

    return result
}

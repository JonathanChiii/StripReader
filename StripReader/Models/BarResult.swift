//
//  BarResult.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/15/25.
//

import Foundation
import UIKit

struct BarResult: Identifiable {
    let id = UUID()
    let index: Int
    let intensity: CGFloat
    let color: UIColor
    let centerFrac: CGFloat  // 0..1 position for debugging
    let detected: Bool
}

struct BarRegion: Identifiable {
    let id = UUID()
    let start: Int
    let end: Int
    var center: CGFloat { CGFloat(start + end) / 2.0 }
    var range: ClosedRange<Int> { start...end }
    var width: Int { end - start + 1 }
}


let expectedPositions: [CGFloat] = [
    0.20, // bar1 (top control)
    0.50, // bar2
    0.80  // bar3
]

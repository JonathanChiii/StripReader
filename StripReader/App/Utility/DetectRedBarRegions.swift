//
//  DetectRedBarRegions.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Foundation

struct BarRegion {
    let index: Int
    let start: Int
    let end: Int
    var range: ClosedRange<Int> {
            return start...end
        }
}

func detectRedBarRegions(from values: [CGFloat]) -> [BarRegion] {
    // Compute mean & standard deviation
    let mean = values.reduce(0, +) / CGFloat(values.count)
    let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / CGFloat(values.count)
    let std = sqrt(variance)

    // Dynamic threshold
    let threshold = mean - std * 0.6
    
    
    print("mean:", mean, "std:", std, "threshold:", threshold)

    var regions: [BarRegion] = []
    var start: Int? = nil

    for i in 0..<values.count {
        if values[i] < threshold {
            if start == nil { start = i }
        } else if let s = start {
            let end = i - 1
            if end - s >= 20 {  // minimum width filter
                regions.append(BarRegion(index: regions.count + 1, start: s, end: i))
            }
            start = nil
        }
    }

//    if let s = start {
//        regions.append(BarRegion(index: regions.count + 1,
//                                 start: s,
//                                 end: values.count - 1))
//    }

    // Remove noise spikes
    print("bar regions: \(regions)")
    return regions.filter { $0.end - $0.start > 3 }
}


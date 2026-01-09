//
//  DetectBarRegionsByThresholding.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/19/25.
//

import Foundation
enum SignalPolarity {
    case peaks   // bar = higher signal
    case troughs // bar = lower signal
}

func detectBarRegions(values: [CGFloat],
                      polarity: SignalPolarity,
                      minWidth: Int = 6,
                      kStd: CGFloat = 0.6,
                      prominence: CGFloat = 0.08) -> [BarRegion] {

    guard values.count > 10 else { return [] }

    let mean = values.reduce(0, +) / CGFloat(values.count)
    let variance = values.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / CGFloat(values.count)
    let std = sqrt(variance)

    // threshold: above mean for peaks; below mean for troughs
    let threshold: CGFloat = {
        switch polarity {
        case .peaks:   return mean + kStd * std
        case .troughs: return mean - kStd * std
        }
    }()

    var regions: [BarRegion] = []
    var start: Int? = nil

    func isInside(_ v: CGFloat) -> Bool {
        switch polarity {
        case .peaks:   return v > threshold
        case .troughs: return v < threshold
        }
    }

    for i in 0..<values.count {
        if isInside(values[i]) {
            if start == nil { start = i }
        } else if let s = start {
            let e = i - 1
            if e - s + 1 >= minWidth {
                regions.append(BarRegion(start: s, end: e))
            }
            start = nil
        }
    }

    if let s = start {
        let e = values.count - 1
        if e - s + 1 >= minWidth {
            regions.append(BarRegion(start: s, end: e))
        }
    }

    // Prominence filter: region must stand out vs nearby baseline
    let filtered = regions.filter { r in
        let prom = regionProminence(values: values, region: r.range, polarity: polarity, window: 12)
        return prom >= prominence
    }

    return filtered.sorted { $0.center < $1.center }
}


func regionProminence(values: [CGFloat],
                      region: ClosedRange<Int>,
                      polarity: SignalPolarity,
                      window: Int) -> CGFloat {

    let n = values.count
    let s = max(0, region.lowerBound)
    let e = min(n - 1, region.upperBound)

    // baseline samples around region
    var baselineSamples: [CGFloat] = []

    let leftStart = max(0, s - window)
    let leftEnd = max(0, s - 1)
    if leftEnd >= leftStart { baselineSamples += Array(values[leftStart...leftEnd]) }

    let rightStart = min(n - 1, e + 1)
    let rightEnd = min(n - 1, e + window)
    if rightEnd >= rightStart { baselineSamples += Array(values[rightStart...rightEnd]) }

    guard !baselineSamples.isEmpty else { return 0 }

    let baseline = baselineSamples.reduce(0, +) / CGFloat(baselineSamples.count)

    switch polarity {
    case .peaks:
        let peak = (values[s...e].max() ?? baseline)
        return max(0, peak - baseline)
    case .troughs:
        let trough = (values[s...e].min() ?? baseline)
        return max(0, baseline - trough)
    }
}



//struct BarRegion {
//    let startX: Int
//    let endX: Int
//}
//
//// Detect bar regions by thresholding
//func detectBarRegions(
//    brightness: [CGFloat],
//    darkThreshold: CGFloat = 0.70,
//    minWidth: Int = 4
//) -> [BarRegion] {
//
//    var regions: [BarRegion] = []
//    var inBar = false
//    var start = 0
//
//    for x in 0..<brightness.count {
//        let isDark = brightness[x] < darkThreshold
//
//        if isDark && !inBar {
//            inBar = true
//            start = x
//        }
//        else if !isDark && inBar {
//            inBar = false
//            if x - start >= minWidth {
//                regions.append(BarRegion(startX: start, endX: x - 1))
//            }
//        }
//    }
//
//    if inBar {
//        let width = brightness.count - start
//        if width >= minWidth {
//            regions.append(BarRegion(startX: start, endX: brightness.count - 1))
//        }
//    }
//
//    return regions
//}

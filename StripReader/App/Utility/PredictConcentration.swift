//
//  PredictConcentration.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 1/8/26.
//

import Foundation

func predictConcentration(
    bars: [BarResult],
    baseline: CGFloat
) -> Prediction? {

    guard let f = extractFeatures(from: bars) else { return nil }

    //STARTING thresholds — tune with your 5 groups
    let weakT2 = f.t2n < 0.10
    let weakT3 = f.t3n < 0.08

    // Key disambiguation:
    // weak lines + HIGH baseline => hook/high concentration
    // weak lines + LOW baseline  => true negative
    if weakT2 && weakT3 {
        if baseline > 0.18 {
            return Prediction(concentration: .mg1,
                              confidence: 0.80,
                              reason: "T2/T3 weak but baseline pinkness elevated (hook/high conc)")
        } else {
            return Prediction(concentration: .mg0_1,
                              confidence: 0.90,
                              reason: "T2/T3 weak and baseline low (true negative)")
        }
    }

    // Otherwise use T2 as monotonic main axis
    if f.t2n > 0.85 { return Prediction(concentration: .ng0, confidence: 0.80, reason: "T2 very strong") }
    if f.t2n > 0.65 { return Prediction(concentration: .ng1,  confidence: 0.75, reason: "T2 strong") }
    if f.t2n > 0.45 { return Prediction(concentration: .ng10,   confidence: 0.70, reason: "T2 medium") }
    if f.t2n > 0.28 { return Prediction(concentration: .ug10, confidence: 0.65, reason: "T2 faint but present") }

    // Very low region: distinguish ng10 vs ng1 using T3 presence
    if f.t3n > 0.10 { return Prediction(concentration: .ng10, confidence: 0.60, reason: "T2 very faint, T3 still visible") }
    return Prediction(concentration: .ng1, confidence: 0.55, reason: "T2 barely present, T3 nearly absent")
}


struct Prediction {
    let concentration: Concentration
    let confidence: CGFloat
    let reason: String
}

struct StripFeatures {
    let c: CGFloat
    let t2: CGFloat
    let t3: CGFloat
    let t2n: CGFloat
    let t3n: CGFloat
    let ratio23: CGFloat
}

func extractFeatures(from bars: [BarResult]) -> StripFeatures? {
    let c  = bars.first(where: { $0.index == 1 })?.intensity ?? 0
    let t2 = bars.first(where: { $0.index == 2 })?.intensity ?? 0
    let t3 = bars.first(where: { $0.index == 3 })?.intensity ?? 0

    guard c > 0.0001 else { return nil }

    let t2n = t2 / c
    let t3n = t3 / c
    let ratio23 = (t2 > 0.0001) ? (t3 / t2) : 0

    return StripFeatures(c: c, t2: t2, t3: t3, t2n: t2n, t3n: t3n, ratio23: ratio23)
}


func computeBaseline(values: [CGFloat], exclude ranges: [ClosedRange<Int>]) -> CGFloat {
    let n = values.count
    var mask = Array(repeating: true, count: n)
    for r in ranges {
        let lo = max(0, r.lowerBound)
        let hi = min(n - 1, r.upperBound)
        if lo <= hi {
            for i in lo...hi { mask[i] = false }
        }
    }
    let kept = zip(values, mask).compactMap { $1 ? $0 : nil }
    guard !kept.isEmpty else { return 0 }
    let sorted = kept.sorted()
    return sorted[sorted.count / 2] // median is robust
}

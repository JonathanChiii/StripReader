//
//  PredictConcentration.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 1/8/26.
//

import Foundation

struct Prediction {
    let concentration: Concentration
    let confidence: CGFloat     // 0..1
    let reason: String          // debug/explain
}

func predictConcentration(from bars: [BarResult]) -> Prediction? {
    guard let f = extractFeatures(from: bars) else {
        return nil
    }

    print("extractFeatures: \(f)");
    // Quick “no analyte” rule: only control line
    if f.t2n < 0.08 && f.t3n < 0.05 {
        return Prediction(concentration: .ng0, confidence: 0.95, reason: "T2 and T3 nearly absent vs control")
    }

    // Bar2 monotonic: bigger = higher concentration (your observation)
    // Bar3 non-monotonic: use ratio patterns to disambiguate mid-range

    // High end (strong T2)
    if f.t2n > 0.85 {
        // If T3 not extremely strong, could be hook region
        let conf: CGFloat = min(1.0, 0.6 + 0.4 * f.t2n)
        return Prediction(concentration: .mg1, confidence: conf, reason: "T2 very strong vs control")
    }

    if f.t2n > 0.65 {
        return Prediction(concentration: .mg0_1, confidence: 0.80, reason: "T2 strong vs control")
    }

    // Mid range: use both T2 and T3 behavior
    if f.t2n > 0.45 {
        if f.t3n > 0.35 {
            return Prediction(concentration: .ug10, confidence: 0.75, reason: "T2 mid + T3 still strong")
        } else {
            return Prediction(concentration: .ug1, confidence: 0.70, reason: "T2 mid but T3 weaker")
        }
    }

    // Low range: faint lines
    if f.t2n > 0.20 {
        return Prediction(concentration: .ug0_1, confidence: 0.65, reason: "T2 faint but present")
    }

    // Very low
    return Prediction(concentration: .ng10, confidence: 0.60, reason: "T2 barely present but above blank")
}

struct StripFeatures {
    let c: CGFloat      // control intensity (bar1)
    let t2: CGFloat     // bar2 intensity
    let t3: CGFloat     // bar3 intensity

    let t2n: CGFloat    // normalized: t2 / c
    let t3n: CGFloat    // normalized: t3 / c
    let ratio23: CGFloat // t3 / t2
}

func extractFeatures(from bars: [BarResult]) -> StripFeatures? {
    // Sort by index just in case
    let sorted = bars.sorted { $0.index < $1.index }

    guard sorted.count >= 2 else { return nil }

    let c = sorted.first(where: { $0.index == 1 })?.intensity ?? 0
    let t2 = sorted.first(where: { $0.index == 2 })?.intensity ?? 0
    let t3 = sorted.first(where: { $0.index == 3 })?.intensity ?? 0

    // Control must exist and be strong enough
    guard c > 0.05 else { return nil }

    let t2n = t2 / c
    let t3n = t3 / c
    let ratio23 = (t2 > 0.0001) ? (t3 / t2) : 0

    return StripFeatures(c: c, t2: t2, t3: t3, t2n: t2n, t3n: t3n, ratio23: ratio23)
}

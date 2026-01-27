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

    let t2 = f.t2n
    let t3 = f.t3n
    let r  = f.ratio23
    print("t2: \(t2), t3: \(t3), ratio t3/t2:\(r), basseline: \(baseline)")
    var reason = ""
    
    if t2 > 0.90 {
        reason =  "T2 very strong. "
        if (t3 > 0.80) {
            reason.append("T3 is also strong. ")
            return Prediction(
                concentration: .ug1,
                confidence: 0.95,
                reason: reason
            )
        } else if (t3 < 0.10) {
            reason.append("T3 is barely visible. ")
            return Prediction(
                concentration: .ng0,
                confidence: 0.95,
                reason: reason
            )
        } else {
            reason.append("T3 middle saturation ")
            return Prediction(
                concentration: .ug0_1,
                confidence: 0.95,
                reason: reason
            )
        }
    } else if (t2 < t3) {
        reason = "T3 stronger than t2"
        if (t3 > 0.4) {
            reason.append("T3 still strong")
            return Prediction(
                concentration: .ug10,
                confidence: 0.95,
                reason: reason
            )
        } else if (t3 < 0.1) {
            reason.append("T3 is barely visible")
            return Prediction(
                concentration: .mg1,
                confidence: 0.95,
                reason: reason
            )
        } else if (t3 > 0.2) {
            reason.append("T3 is weaker")
            return Prediction(
                concentration: .ug100,
                confidence: 0.95,
                reason: reason
            )
        } else {
            reason = "L2 classification"
            return Prediction(
                concentration: .error,
                confidence: 0.95,
                reason: reason
            )
        }
    } else if (t2 < 0.05 && t3 < 0.05) {
        reason = "Both T1 and T2 absent"
        return Prediction(
            concentration: .mg5,
            confidence: 0.95,
            reason: reason
        )
    } else {
        reason = "L1 classification"
        return Prediction(
            concentration: .error,
            confidence: 0.95,
            reason: reason
        )
    }
    
    
    

    // 1️⃣ High Consentration (5000 µg/mL)
    if t2 < 0.05 && t3 < 0.05 && baseline < 0.12 {
        return Prediction(
            concentration: .mg5,
            confidence: 0.95,
            reason: "T2/T3 absent and baseline clean"
        )
    }

    // 2️⃣ VERY HIGH CONC (5000 µg/mL) — hook extreme
    if t2 < 0.10 && t3 < 0.10 && baseline > 0.20 {
        return Prediction(
            concentration: .mg1,
            confidence: 0.80,
            reason: "Both test lines suppressed with high baseline (strong hook)"
        )
    }

    // 3️⃣ HIGH CONC (1000 µg/mL)
    if t2 < 0.18 && t3 < 0.10 && baseline > 0.16 {
        return Prediction(
            concentration: .mg1,
            confidence: 0.75,
            reason: "Weak test lines with elevated baseline (hook)"
        )
    }

    // 4️⃣ MID-HIGH (100 µg/mL)
    if t2 > 0.35 && t3 < 0.25 && r < 0.8 {
        return Prediction(
            concentration: .ug100,
            confidence: 0.80,
            reason: "T2 still strong but T3 collapsing"
        )
    }

    // 5️⃣ MID (10 µg/mL)
    if t2 > 0.45 && t3 > 0.30 && r > 0.7 {
        return Prediction(
            concentration: .ug10,
            confidence: 0.85,
            reason: "T2/T3 both strong"
        )
    }

    // 6️⃣ LOW (1 µg/mL)
    if t2 > 0.20 && t3 > 0.25 {
        return Prediction(
            concentration: .ug1,
            confidence: 0.75,
            reason: "T3 dominant over T2"
        )
    }

    // 7️⃣ VERY LOW (0.1 µg/mL)
    if t2 > 0.10 {
        return Prediction(
            concentration: .ug0_1,
            confidence: 0.65,
            reason: "Faint T2 detected"
        )
    }

    // Fallback (rare ambiguity)
    return Prediction(
        concentration: .ug1,
        confidence: 0.50,
        reason: "Ambiguous pattern"
    )
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

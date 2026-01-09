//
//  BuildBarResults.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 1/8/26.
//

import Foundation

func buildBarResults(smoothValues: [CGFloat],
                     regions: [BarRegion]) -> [BarResult] {

    let expected: [CGFloat] = [0.20, 0.50, 0.80] // tune later

    let assigned = assignRegionsToBars(regions: regions,
                                       signalCount: smoothValues.count,
                                       expectedFractions: expected)

    var results: [BarResult] = []

    for barIndex in 1...3 {
        if let region = assigned[barIndex] {
            // better than width: use area/peak vs baseline (recommended)
            let intensity = integratedIntensityPeak(values: smoothValues, region: region.range)
            let n = max(1, smoothValues.count - 1)
            let centerX = CGFloat(region.range.lowerBound + region.range.upperBound) / 2.0
            let centerFrac = centerX / CGFloat(n)
            
            results.append(BarResult(index: barIndex,
                                     intensity: intensity,
                                     color: .systemPink,
                                     centerFrac: centerFrac,
                                     detected: true))
        } else {
            // missing bar
            results.append(BarResult(index: barIndex,
                                     intensity: 0,
                                     color: .systemPink.withAlphaComponent(0.15),
                                     centerFrac: expectedPositions[barIndex-1],
                                     detected: false))
        }
    }

    return results.sorted { $0.index < $1.index }
}

func assignRegionsToBars(regions: [BarRegion],
                         signalCount: Int,
                         expectedFractions: [CGFloat],   // e.g. [0.2, 0.5, 0.8]
                         maxDistanceFraction: CGFloat = 0.12) -> [Int: BarRegion] {

    // barIndex (1-based) -> BarRegion
    var assigned: [Int: BarRegion] = [:]

    // Track which detected regions have already been used
    var usedRegionIDs = Set<UUID>()

    let maxDist = maxDistanceFraction * CGFloat(max(1, signalCount - 1))

    for (slotIdx, frac) in expectedFractions.enumerated() {
        let expectedX = frac * CGFloat(max(1, signalCount - 1))

        // Find closest unused region
        let candidates = regions
            .filter { !usedRegionIDs.contains($0.id) }
            .map { region in
                (region: region,
                 dist: abs(region.center - expectedX))
            }
            .sorted { $0.dist < $1.dist }

        guard let best = candidates.first,
              best.dist <= maxDist
        else {
            continue   // no region close enough → bar missing
        }

        let barIndex = slotIdx + 1   // 1,2,3
        assigned[barIndex] = best.region
        usedRegionIDs.insert(best.region.id)
    }

    return assigned
}


func integratedIntensityPeak(values: [CGFloat],
                             region: ClosedRange<Int>,
                             baselineWindow: Int = 12) -> CGFloat {

    let n = values.count
    let start = max(0, region.lowerBound)
    let end = min(n - 1, region.upperBound)

    // Collect baseline samples from left and right windows
    var baselineSamples: [CGFloat] = []

    let leftStart = max(0, start - baselineWindow)
    let leftEnd = max(0, start - 1)
    if leftEnd >= leftStart {
        baselineSamples += Array(values[leftStart...leftEnd])
    }

    let rightStart = min(n - 1, end + 1)
    let rightEnd = min(n - 1, end + baselineWindow)
    if rightEnd >= rightStart {
        baselineSamples += Array(values[rightStart...rightEnd])
    }

    let baseline = baselineSamples.isEmpty
        ? (values.min() ?? 0)
        : baselineSamples.reduce(0, +) / CGFloat(baselineSamples.count)

    // Integrate area above baseline
    var area: CGFloat = 0
    for x in start...end {
        area += max(0, values[x] - baseline)
    }

    // Optional: normalize by width so blur doesn’t inflate score too much
    // return area / CGFloat(end - start + 1)
    return area
}

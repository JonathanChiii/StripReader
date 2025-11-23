//
//  DetectRedBarRegions.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Foundation

struct BarRegion {
    let startX: Int
    let endX: Int
}

func detectRedBarRegions(values: [CGFloat],
                         rednessThreshold: CGFloat = 30,
                         minWidth: Int = 4) -> [BarRegion] {

    var regions: [BarRegion] = []
    var inBar = false
    var start = 0

    for x in 0..<values.count {
        let isBar = values[x] > rednessThreshold

        if isBar && !inBar {
            inBar = true
            start = x
        }
        else if !isBar && inBar {
            inBar = false
            let width = x - start
            if width >= minWidth {
                regions.append(BarRegion(startX: start, endX: x - 1))
            }
        }
    }

    if inBar {
        let width = values.count - start
        if width >= minWidth {
            regions.append(BarRegion(startX: start, endX: values.count - 1))
        }
    }

    return regions
}

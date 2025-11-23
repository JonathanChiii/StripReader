//
//  DetectBarRegionsByThresholding.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/19/25.
//

import Foundation

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

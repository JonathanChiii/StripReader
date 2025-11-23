//
//  StripAnalysis.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/16/25.
//

import Foundation
import CoreGraphics
import SwiftUI

func analyzeStrip(image: UIImage, debug: AnalyzerDebug? = nil) -> [BarResult] {
    
    
    debug?.reset()
    //debug?.add(label: "Input Image", image: image)
    // 1. Crop center band
    guard let band = cropCenterBand(from: image) else {
        print("Failed to crop center band")
        return []
    }
    // Debug output
    let bandUIImage = uiImage(from: band)
    debug?.add(label: "Center Band Crop", image: bandUIImage)

    
    
    // 2. Extract brightness values column by column
    let redness = computeColumnRedness(from: band)
    // Convert brightness values → graph image
    if let graphImage = brightnessGraphImage(values: redness) {
            debug?.add(label: "Redness Graph", image: graphImage)
        }
    
    
    // 3. Smooth redness (moving average)
    let smoothedRedness = smooth(redness, windowSize: 5)
    if let smoothGraph = brightnessGraphImage(values: smoothedRedness) {
            debug?.add(label: "Smoothed Brightness", image: smoothGraph)
        }

    let regions = detectRedBarRegions(
        values: smoothedRedness,
        rednessThreshold: 30,
        minWidth: 4
    )
    
    // Debug image showing detected segments as vertical bars
    if let maskImage = barMaskImage(size: CGSize(width: band.width, height: band.height),
                                    regions: regions) {
        debug?.add(label: "Detected Bar Mask", image: maskImage)
    }
    
    
    // 5. Compute average color & intensity for each region
    let bars = analyzeBarColors(from: band, regions: regions)
    
    // 6. Crop each bar region & add to debug
        for region in regions {
            if let cropped = cropBarRegion(from: band, region: region) {
                debug?.add(label: "Bar \(region.startX)-\(region.endX)", image: cropped)
            }
        }
    
    
    return bars
}

func uiImage(from cgImage: CGImage) -> UIImage {
    return UIImage(cgImage: cgImage)
}

func brightnessGraphImage(values: [CGFloat]) -> UIImage? {
    let width = values.count
    let height = 120

    UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
    guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

    ctx.setFillColor(UIColor.white.cgColor)
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

    ctx.setStrokeColor(UIColor.black.cgColor)
    ctx.setLineWidth(1)

    ctx.move(to: CGPoint(x: 0, y: height - Int(CGFloat(values[0])) * height))
    for x in 1..<width {
        let y = height - Int(CGFloat(values[x])) * height
        ctx.addLine(to: CGPoint(x: x, y: y))
    }
    ctx.strokePath()

    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img
}

func barMaskImage(size: CGSize, regions: [BarRegion]) -> UIImage? {
    let width = Int(size.width)
    let height = Int(size.height)
    
    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
    guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

    ctx.setFillColor(UIColor.white.cgColor)
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

    ctx.setFillColor(UIColor.red.withAlphaComponent(0.5).cgColor)

    for region in regions {
        let rect = CGRect(x: region.startX,
                          y: 0,
                          width: region.endX - region.startX,
                          height: height)
        ctx.fill(rect)
    }

    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img
}


func cropBarRegion(from cgImage: CGImage, region: BarRegion) -> UIImage? {
    let rect = CGRect(x: region.startX, y: 0,
                      width: region.endX - region.startX,
                      height: cgImage.height)

    if let cropped = cgImage.cropping(to: rect) {
        return UIImage(cgImage: cropped)
    }
    return nil
}

//
//  AnalyzeBarsInCroppedStrip.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/16/25.
//

import Foundation
import CoreGraphics
import SwiftUI
func analyzeBarsInCroppedStrip(cgImage: CGImage, debug: AnalyzerDebug? = nil) -> [BarResult] {

    debug?.add(label: "Input to Pink Analyzer", image: UIImage(cgImage: cgImage))

    // 1. Compute redness per column (pink signal)
    let redValues = computeColumnBrightness(from: cgImage)

    debug?.add(label: "Raw Redness Graph", image:rednessGraphImage(redValues))

    // 2. Smooth the graph to remove noise
    let smoothValues = smooth(redValues)

    debug?.add(label: "Smoothed Redness Graph", image: rednessGraphImage(smoothValues))

    // 3. Detect pink bar regions
    let regions = detectRedBarRegions(from: smoothValues)

    // Optional debug overlay
    debug?.add(label: "Redness Graph + Regions",
               image: drawRegionsOnGraph(values: smoothValues, regions: regions)
    )

    // 4. Produce BarResult entries
    var results: [BarResult] = []

    for (i, region) in regions.enumerated() {
        let intensity = averageIntensity(values: smoothValues, in: region.range)
        let uiColor = UIColor(red: CGFloat(intensity), green: 0.4, blue: 0.6, alpha: 1.0)

        results.append(BarResult(index: i + 1,
                                 intensity: CGFloat(intensity),
                                 color: uiColor))
    }

    return results
}

//func analyzeBarsInCroppedStrip(cgImage: CGImage,
//                               debug: AnalyzerDebug? = nil) -> [BarResult] {
//
//    // Convert to UIImage for debugging
//    debug?.add(label: "Final Cropped Analysis Region", image: UIImage(cgImage: cgImage))
//
//    // 1. Compute redness signal
//    let redness = computeColumnRedness(from: cgImage)
//    debug?.add(label: "Raw Rednes Graph", image: rednessGraphImage(redness))
//
//    // 2. Smooth
//    let smoothed = smooth(redness, windowSize: 5)
//
//    debug?.add(label: "Smoothed Redness Graph", image: rednessGraphImage(smoothed))
//
//    // 3. Detect red bar regions
//    let regions = detectRedBarRegions(values: smoothed,
//                                      rednessThreshold: 30,  // tuned for your strip
//                                      minWidth: 4)
//
//    // Debug mask
//    if let mask = barMaskImage(size: CGSize(width: cgImage.width,
//                                            height: cgImage.height),
//                               regions: regions) {
//        debug?.add(label: "Detected Bar Regions Mask", image: mask)
//    }
//
//    // 4. Compute bar colors
//    let results = analyzeBarColors(from: cgImage, regions: regions)
//
//    // Debug: crop and show each bar region
//    for (i, region) in regions.enumerated() {
//        if let cropped = cropBarRegion(from: cgImage, region: region) {
//            debug?.add(label: "Bar #\(i+1) Crop", image: cropped)
//        }
//    }
//
//    return results
//}
func averageIntensity(values: [CGFloat], in region: ClosedRange<Int>) -> CGFloat {
    let slice = values[region]
    let sum = slice.reduce(0, +)
    return sum / CGFloat(slice.count)
}

func drawRegionsOnGraph(values: [CGFloat],
                        regions: [BarRegion]) -> UIImage {

    let base = rednessGraphImage(values)
    let size = base.size

    UIGraphicsBeginImageContext(size)
    base.draw(at: .zero)

    let ctx = UIGraphicsGetCurrentContext()!
    ctx.setStrokeColor(UIColor.green.withAlphaComponent(0.7).cgColor)
    ctx.setLineWidth(2)

    for region in regions {
        let lower = region.range.lowerBound
        let upper = region.range.upperBound

        ctx.move(to: CGPoint(x: CGFloat(lower), y: 0))
        ctx.addLine(to: CGPoint(x: CGFloat(lower), y: size.height))

        ctx.move(to: CGPoint(x: CGFloat(upper), y: 0))
        ctx.addLine(to: CGPoint(x: CGFloat(upper), y: size.height))
    }

    ctx.strokePath()

    let final = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return final ?? base
}


func uiImage(from cgImage: CGImage) -> UIImage {
    return UIImage(cgImage: cgImage)
}

func rednessGraphImage(_ values: [CGFloat]) -> UIImage {
    let graphHeight: CGFloat = 200
    let size = CGSize(width: CGFloat(values.count), height: graphHeight)

    UIGraphicsBeginImageContext(size)
    guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }

    ctx.setStrokeColor(UIColor.red.cgColor)
    ctx.setLineWidth(1.0)

    for x in 0..<values.count {
        let value = max(0, min(values[x], 1)) // clamp 0-1
        let y = graphHeight * (1 - value)
        ctx.move(to: CGPoint(x: CGFloat(x), y: graphHeight))
        ctx.addLine(to: CGPoint(x: CGFloat(x), y: y))
    }

    ctx.strokePath()

    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return img ?? UIImage()
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
        let rect = CGRect(x: region.start,
                          y: 0,
                          width: region.end - region.start,
                          height: height)
        ctx.fill(rect)
    }

    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img
}


func cropBarRegion(from cgImage: CGImage, region: BarRegion) -> UIImage? {
    let rect = CGRect(x: region.start, y: 0,
                      width: region.end - region.start,
                      height: cgImage.height)

    if let cropped = cgImage.cropping(to: rect) {
        return UIImage(cgImage: cropped)
    }
    return nil
}



//
//  DetectStripRectangle.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Vision
import UIKit
import CoreImage

func detectStripRectangle(from cgInput: CGImage,
                          completion: @escaping (CGImage?) -> Void) {
    
    // 1. Convert CGImage → CIImage so we can blur
    let ciImage = CIImage(cgImage: cgInput)

    // 2. Light blur to help rectangle detection
    let blurred = ciImage.applyingFilter("CIGaussianBlur",
                                         parameters: ["inputRadius": 3])

    // 3. Convert back to CGImage ONCE
    let context = CIContext()
    guard let blurredCG = context.createCGImage(blurred, from: blurred.extent) else {
        completion(nil)
        return
    }

    let visionSize = CGSize(width: blurredCG.width, height: blurredCG.height)

    // 4. Set up Vision rectangle detection
    let request = VNDetectRectanglesRequest { request, error in
        guard let rects = request.results as? [VNRectangleObservation],
              let best = rects.first else {
            completion(nil)
            return
        }

        // 5. Perspective correct + crop the rectangle
        if let corrected = cropRectangle(best, from: cgInput, visionImageSize: visionSize) {
            completion(corrected)
        } else {
            completion(nil)
        }
    }

    // 5. Adjustment for test strip aspect ratio
    request.minimumAspectRatio = 0.9
    request.maximumAspectRatio = 1.1
    request.minimumSize = 0.4
    request.minimumConfidence = 0.7        // relax confidence
    request.quadratureTolerance = 45       // allow non-perfect right angles
    request.maximumObservations = 1        // expect one strip
    
    // 6. Run Vision
    let handler = VNImageRequestHandler(cgImage: blurredCG)
    try? handler.perform([request])
}


//func cropRectangle(_ rect: VNRectangleObservation, from cgImage: CGImage) -> CGImage? {
//    let w = CGFloat(cgImage.width)
//    let h = CGFloat(cgImage.height)
//
//    // Normalize points
//    let tl = CGPoint(x: rect.topLeft.x * w, y: (1 - rect.topLeft.y) * h)
//    let tr = CGPoint(x: rect.topRight.x * w, y: (1 - rect.topRight.y) * h)
//    let bl = CGPoint(x: rect.bottomLeft.x * w, y: (1 - rect.bottomLeft.y) * h)
//    let br = CGPoint(x: rect.bottomRight.x * w, y: (1 - rect.bottomRight.y) * h)
//
//    let ci = CIImage(cgImage: cgImage)
//        .applyingFilter("CIPerspectiveCorrection", parameters: [
//            "inputTopLeft": CIVector(cgPoint: tl),
//            "inputTopRight": CIVector(cgPoint: tr),
//            "inputBottomLeft": CIVector(cgPoint: bl),
//            "inputBottomRight": CIVector(cgPoint: br)
//        ])
//
//    let ctx = CIContext()
//    return ctx.createCGImage(ci, from: ci.extent)
//}
//

func cropRectangle(_ rect: VNRectangleObservation,
                   from source: CGImage,
                   visionImageSize: CGSize) -> CGImage? {

    let W = CGFloat(source.width)
    let H = CGFloat(source.height)

    // convert rectangle corners from normalized Vision coordinates
    // but scaled to the coordinate system Vision actually used (blurred image)
    let scaleX = W / visionImageSize.width
    let scaleY = H / visionImageSize.height

    let tl = CGPoint(x: rect.topLeft.x * W, y: (1 - rect.topLeft.y) * H)
    let tr = CGPoint(x: rect.topRight.x * W, y: (1 - rect.topRight.y) * H)
    let bl = CGPoint(x: rect.bottomLeft.x * W, y: (1 - rect.bottomLeft.y) * H)
    let br = CGPoint(x: rect.bottomRight.x * W, y: (1 - rect.bottomRight.y) * H)

    let ci = CIImage(cgImage: source)

    let corrected = ci.applyingFilter("CIPerspectiveCorrection", parameters: [
        "inputTopLeft": CIVector(cgPoint: tl),
        "inputTopRight": CIVector(cgPoint: tr),
        "inputBottomLeft": CIVector(cgPoint: bl),
        "inputBottomRight": CIVector(cgPoint: br)
    ])

    let ctx = CIContext()
    let correctedCG = ctx.createCGImage(corrected, from: corrected.extent)!

    return correctedCG
    //return source
}

extension CGImage {
    func rotated90Degrees() -> CGImage? {
        let ci = CIImage(cgImage: self)
        let rotated = ci.oriented(.left)
        let ctx = CIContext()
        return ctx.createCGImage(rotated, from: rotated.extent)
    }
}

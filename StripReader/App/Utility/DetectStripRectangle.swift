//
//  DetectStripRectangle.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Vision
import UIKit
import CoreImage
import Vision
import CoreImage

func detectStripRectangle(
    from cgInput: CGImage,
    completion: @escaping (CGImage?) -> Void
) {

    let ciInput = CIImage(cgImage: cgInput)
    let blurred = ciInput.applyingFilter(
        "CIGaussianBlur",
        parameters: ["inputRadius": 3]
    )

    let context = CIContext()
    guard let blurredCG = context.createCGImage(blurred, from: blurred.extent) else {
        completion(nil)
        return
    }

    let request = VNDetectRectanglesRequest { request, _ in
        guard let rects = request.results as? [VNRectangleObservation],
              !rects.isEmpty else {
            completion(nil)
            return
        }

        let bestRect = rects.max { scoreRectangle($0) < scoreRectangle($1) }

        guard let bestRect else {
            completion(nil)
            return
        }

        completion(
            cropCorrectAndDeskew(bestRect, from: cgInput)
        )
    }

    request.minimumAspectRatio = 0.8
    request.maximumAspectRatio = 1.2
    request.minimumSize = 0.3
    request.minimumConfidence = 0.7
    request.maximumObservations = 1
    request.quadratureTolerance = 20

    let handler = VNImageRequestHandler(cgImage: blurredCG)
    try? handler.perform([request])
}

func cropCorrectAndDeskew(
    _ rect: VNRectangleObservation,
    from source: CGImage
) -> CGImage? {

    let W = CGFloat(source.width)
    let H = CGFloat(source.height)

    // ---- Perspective correction ----
    let tl = CGPoint(x: rect.topLeft.x * W, y: (1 - rect.topLeft.y) * H)
    let tr = CGPoint(x: rect.topRight.x * W, y: (1 - rect.topRight.y) * H)
    let bl = CGPoint(x: rect.bottomLeft.x * W, y: (1 - rect.bottomLeft.y) * H)
    let br = CGPoint(x: rect.bottomRight.x * W, y: (1 - rect.bottomRight.y) * H)

    let ci = CIImage(cgImage: source)

    let corrected = ci.applyingFilter(
        "CIPerspectiveCorrection",
        parameters: [
            "inputTopLeft": CIVector(cgPoint: tl),
            "inputTopRight": CIVector(cgPoint: tr),
            "inputBottomLeft": CIVector(cgPoint: bl),
            "inputBottomRight": CIVector(cgPoint: br)
        ]
    )

    let context = CIContext()
    guard let correctedCG = context.createCGImage(
        corrected,
        from: corrected.extent
    ) else { return nil }

    // ---- Rotation recovery ----
    let angle = estimateRotationAngle(
        from: rect,
        imageWidth: W,
        imageHeight: H
    )

    return deskewCGImage(correctedCG, by: angle)
}



func estimateRotationAngle(
    from rect: VNRectangleObservation,
    imageWidth: CGFloat,
    imageHeight: CGFloat
) -> CGFloat {

    // Convert normalized Vision points → image coordinates
    let tl = CGPoint(
        x: rect.topLeft.x * imageWidth,
        y: (1 - rect.topLeft.y) * imageHeight
    )

    let tr = CGPoint(
        x: rect.topRight.x * imageWidth,
        y: (1 - rect.topRight.y) * imageHeight
    )

    let bl = CGPoint(
        x: rect.bottomLeft.x * imageWidth,
        y: (1 - rect.bottomLeft.y) * imageHeight
    )

    // Compute edge vectors
    let topEdge = CGVector(dx: tr.x - tl.x, dy: tr.y - tl.y)
    let leftEdge = CGVector(dx: bl.x - tl.x, dy: bl.y - tl.y)

    // Compute lengths
    let topLen = hypot(topEdge.dx, topEdge.dy)
    let leftLen = hypot(leftEdge.dx, leftEdge.dy)

    // Choose dominant edge
    if topLen >= leftLen {
        // Angle relative to horizontal
        return atan2(topEdge.dy, topEdge.dx)
    } else {
        // Vertical edge → rotate by 90°
        return atan2(leftEdge.dy, leftEdge.dx) - .pi / 2
    }
}

func deskewCGImage(
    _ cgImage: CGImage,
    by angle: CGFloat
) -> CGImage? {

    let ciImage = CIImage(cgImage: cgImage)

    let rotated = ciImage.transformed(
        by: CGAffineTransform(rotationAngle: -angle)
    )

    let context = CIContext()
    return context.createCGImage(rotated, from: rotated.extent)
}


func cropRectangle(_ rect: VNRectangleObservation,
                   from source: CGImage) -> CGImage? {

    let W = CGFloat(source.width)
    let H = CGFloat(source.height)

    let tl = CGPoint(x: rect.topLeft.x * W,
                     y: (1 - rect.topLeft.y) * H)
    let tr = CGPoint(x: rect.topRight.x * W,
                     y: (1 - rect.topRight.y) * H)
    let bl = CGPoint(x: rect.bottomLeft.x * W,
                     y: (1 - rect.bottomLeft.y) * H)
    let br = CGPoint(x: rect.bottomRight.x * W,
                     y: (1 - rect.bottomRight.y) * H)

    let ci = CIImage(cgImage: source)
    let corrected = ci.applyingFilter("CIPerspectiveCorrection", parameters: [
        "inputTopLeft": CIVector(cgPoint: tl),
        "inputTopRight": CIVector(cgPoint: tr),
        "inputBottomLeft": CIVector(cgPoint: bl),
        "inputBottomRight": CIVector(cgPoint: br)
    ])
    //let corrected = ci
    let ctx = CIContext()
    return ctx.createCGImage(corrected, from: corrected.extent)
}


func scoreRectangle(_ r: VNRectangleObservation) -> CGFloat {

    let width: CGFloat = r.boundingBox.width
    let height: CGFloat = r.boundingBox.height

    // Area in normalized Vision coordinates
    let area: CGFloat = width * height

    // Aspect ratio (guard against division by zero)
    let aspect: CGFloat = width / max(height, CGFloat(0.0001))

    // How close to square (1.0 is perfect)
    let squareScore: CGFloat = CGFloat(1.0) - abs(aspect - CGFloat(1.0))

    let confidence: CGFloat = CGFloat(r.confidence)

    // Explicit weights (ALL CGFloat)
    let areaWeight: CGFloat = CGFloat(0.6)
    let squareWeight: CGFloat = CGFloat(0.3)
    let confidenceWeight: CGFloat = CGFloat(0.1)

    let areaTerm: CGFloat = area * areaWeight
    let squareTerm: CGFloat = squareScore * squareWeight
    let confidenceTerm: CGFloat = confidence * confidenceWeight

    let score: CGFloat = areaTerm + squareTerm + confidenceTerm
    return score
}

private func cropAndCorrectRectangle(
    _ rect: VNRectangleObservation,
    from source: CGImage
) -> CGImage? {

    let width = CGFloat(source.width)
    let height = CGFloat(source.height)

    // Convert Vision normalized coordinates → image coordinates
    let topLeft = CGPoint(
        x: rect.topLeft.x * width,
        y: (1 - rect.topLeft.y) * height
    )

    let topRight = CGPoint(
        x: rect.topRight.x * width,
        y: (1 - rect.topRight.y) * height
    )

    let bottomLeft = CGPoint(
        x: rect.bottomLeft.x * width,
        y: (1 - rect.bottomLeft.y) * height
    )

    let bottomRight = CGPoint(
        x: rect.bottomRight.x * width,
        y: (1 - rect.bottomRight.y) * height
    )

    let ciImage = CIImage(cgImage: source)

    let corrected = ciImage.applyingFilter(
        "CIPerspectiveCorrection",
        parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)
        ]
    )

    let context = CIContext()
    return context.createCGImage(corrected, from: corrected.extent)
}

func rotationAngle(from rect: VNRectangleObservation,
                   imageWidth: CGFloat,
                   imageHeight: CGFloat) -> CGFloat {

    let tl = CGPoint(
        x: rect.topLeft.x * imageWidth,
        y: (1 - rect.topLeft.y) * imageHeight
    )

    let tr = CGPoint(
        x: rect.topRight.x * imageWidth,
        y: (1 - rect.topRight.y) * imageHeight
    )

    let dx = tr.x - tl.x
    let dy = tr.y - tl.y

    return atan2(dy, dx)
}


func rotateCGImage(_ cg: CGImage, by angle: CGFloat) -> CGImage? {
    let ciImage = CIImage(cgImage: cg)

    let rotated = ciImage.transformed(
        by: CGAffineTransform(rotationAngle: -angle)
    )

    let context = CIContext()
    return context.createCGImage(rotated, from: rotated.extent)
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



extension CGImage {
    func rotated90Degrees() -> CGImage? {
        let ci = CIImage(cgImage: self)
        let rotated = ci.oriented(.left)
        let ctx = CIContext()
        return ctx.createCGImage(rotated, from: rotated.extent)
    }
}

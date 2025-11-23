//
//  CropCenterBand.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/19/25.
//

import Foundation
import UIKit
import CoreGraphics

// Crop center band
func cropCenterBand(from image: UIImage, relativeHeight: CGFloat = 0.1) -> CGImage? {
    guard let cgImage = image.cgImage else { return nil }

    let width = cgImage.width
    let height = cgImage.height

    let bandHeight = Int(CGFloat(height) * relativeHeight)
    let y = (height - bandHeight) / 2

    let rect = CGRect(x: 0, y: y, width: width, height: bandHeight)
    return cgImage.cropping(to: rect)
}


//
//  CropBarArea.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Foundation
import SwiftUI

func cropMiddleFifth(of cgImage: CGImage) -> CGImage? {
    let width = cgImage.width
    let height = cgImage.height

    let bandHeight = height / 5
    let y = (height - bandHeight) / 2   // vertical center

    let rect = CGRect(x: 0, y: y, width: width, height: bandHeight)
    return cgImage.cropping(to: rect)
}

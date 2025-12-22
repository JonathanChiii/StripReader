//
//  AnalyzeStrip.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Foundation
import SwiftUI

func analyzeStrip(image: UIImage, debug: AnalyzerDebug? = nil, completion: @escaping ([BarResult]) -> Void) {

    debug?.reset()
    debug?.add(label: "Input Image", image: image)

    detectStripRectangle(from: image) { rectImage in
        guard let rectImage else {
            completion([])
            return
        }

        debug?.add(label: "Detected Strip (Perspective Corrected)", image: UIImage(cgImage: rectImage))
        print("Detected Strip (Perspective Corrected)")
        guard let middle = cropMiddleFifth(of: rectImage) else {
            completion([])
            return
        }
        debug?.add(label: "Middle 1/5 Region", image: UIImage(cgImage: middle))
        print("Middle 1/5 Cropped")
        // redness / saturation bar detection
        let results = analyzeBarsInCroppedStrip(cgImage: middle, debug: debug)
//        let results = [
//            BarResult(index: 1, intensity: 0.25, color: .red),
//            BarResult(index: 2, intensity: 0.55, color: .green),
//            BarResult(index: 3, intensity: 0.85, color: .blue)
//        ]
        completion(results)
    }
}

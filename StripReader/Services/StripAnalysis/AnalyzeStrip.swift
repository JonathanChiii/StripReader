//
//  AnalyzeStrip.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Foundation
import SwiftUI

func analyzeStrip(capturedCGImage: CGImage, debug: AnalyzerDebug? = nil, completion: @escaping ([BarResult]) -> Void) {

    debug?.reset()
    //debug?.add(label: "Input Image", image: UIImage(cgImage: capturedCGImage))

    detectStripRectangle(from: capturedCGImage) { rectCGImage in
        guard let rectCGImage else {
            completion([])
            return
        }

        debug?.add(label: "Detected Strip (Perspective Corrected)", image: UIImage(cgImage: rectCGImage))

        guard let croppedMiddleCGImage = cropMiddle(of: rectCGImage, divider: 5.7) else {
            completion([])
            return
        }

        debug?.add(label: "Middle Region with bars", image: UIImage(cgImage: croppedMiddleCGImage))
        print("Middle Cropped")
        // redness / saturation bar detection
        let results = analyzeBarsInCroppedStrip(cgImage: croppedMiddleCGImage, debug: debug)
//        let results = [
//            BarResult(index: 1, intensity: 0.25, color: .red),
//            BarResult(index: 2, intensity: 0.55, color: .green),
//            BarResult(index: 3, intensity: 0.85, color: .blue)
//        ]
        completion(results)
    }
}


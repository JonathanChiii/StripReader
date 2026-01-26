//
//  AnalyzeStrip.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Foundation
import SwiftUI

struct StripAnalysisResult {
    let bars: [BarResult]
    let baseline: CGFloat
    let prediction: Prediction?
}


func analyzeStrip(
    capturedCGImage: CGImage,
    debug: AnalyzerDebug? = nil,
    completion: @escaping (StripAnalysisResult?) -> Void
) {

    debug?.reset()

    detectStripRectangle(from: capturedCGImage) { rectCGImage in
        guard let rectCGImage else {
            completion(nil)
            return
        }

        debug?.add(label: "Detected Strip (Perspective Corrected)",
                   image: UIImage(cgImage: rectCGImage))

        guard let croppedMiddleCGImage = cropMiddle(of: rectCGImage, divider: 5.7) else {
            completion(nil)
            return
        }

        debug?.add(label: "Middle Region with bars",
                   image: UIImage(cgImage: croppedMiddleCGImage))

        let analysis = analyzeBarsInCroppedStrip(cgImage: croppedMiddleCGImage, debug: debug)
        completion(analysis)
    }
}


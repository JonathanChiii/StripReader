//
//  StripAnalysisWithVision.swift
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

        guard let middle = cropMiddleFifth(of: rectImage) else {
            completion([])
            return
        }

        debug?.add(label: "Middle 1/5 Region", image: UIImage(cgImage: middle))

        // redness / saturation bar detection
        let results = analyzeBarsInCroppedStrip(cgImage: middle, debug: debug)
        completion(results)
    }
}

//
//  AnalyzerState.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/19/25.
//

import Foundation

enum AnalyzerState {
    case idle
    case cropping
    case detectingColumns
    case detectingRegions
    case computingResults
    case completed([BarResult])
    case failed(String)

    var message: String {
        switch self {
        case .idle:
            return "Not started"
        case .cropping:
            return "Cropping image"
        case .detectingColumns:
            return "Computing brightness values…"
        case .detectingRegions:
            return "Detecting bar regions…"
        case .computingResults:
            return "Computing bar colors and intensities…"
        case .completed:
            return "Completed!"
        case .failed(let error):
            return "Failed: \(error)"
        }
    }
}



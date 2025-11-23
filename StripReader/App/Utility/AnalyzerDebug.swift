//
//  AnalyzerDebug.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/23/25.
//

import Foundation
import SwiftUI

struct PipelineDebug: Identifiable {
    let id = UUID()
    let label: String
    let image: UIImage
}

class AnalyzerDebug: ObservableObject {
    @Published var stages: [PipelineDebug] = []
    
    func add(label: String, image: UIImage) {
        stages.append(PipelineDebug(label: label, image: image))
    }
    
    func reset() {
        stages.removeAll()
    }
}

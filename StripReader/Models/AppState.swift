//
//  AppState.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/21/25.
//

import Foundation

// EnvironmentObjects that keeps track of application real time state
class AppState: ObservableObject {
    @Published var analyzerState: AnalyzerState = .idle
    @Published var isDebug = AppConfig.isDebug
}

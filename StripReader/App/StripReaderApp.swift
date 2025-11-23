//
//  StripReaderApp.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/9/25.
//

import SwiftUI

@main
struct StripReaderApp: App {
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

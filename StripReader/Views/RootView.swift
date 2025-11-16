//
//  HomeView.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/15/25.
//
import SwiftUI
import Foundation

struct RootView: View {
    
    enum Tab: Hashable {
        case history
        case scanner
        case settings
    }
    
    // Loading tab default to scanner
    @State private var selectedTab: Tab = .scanner
    
    
    var body: some View {
        NavigationStack {
            TabView(selection: self.$selectedTab) {
                
                HistoryView()
                    .tabItem{
                        Label("History", systemImage: "clock")
                    }
                    .tag(Tab.history)
                
                ScannerView()
                    .tabItem{
                        Label("Scanner", systemImage: "camera")
                    }
                    .tag(Tab.scanner)
                
                SettingsView()
                    .tabItem{
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(Tab.settings)
            }
            .navigationTitle("Strip Reader") // Title at the top of the tab
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RootView()
}

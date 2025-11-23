//
//  CameraView.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/15/25.
//

import Foundation
import SwiftUI

struct CameraView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var barResults: [BarResult] = []
    
    var body: some View {
        Text("ContentView")
        NavigationStack {
            Text("Nevigation Stack")
            VStack(spacing: 20) {
                
                // open the camera
                Button {
                    self.showCamera = true
                } label: {
                    Text("Open Camera")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                
                // show captured Image
                if let uiImage = capturedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.4)))
                } else {
                    Text("No images capturd yet")
                        .foregroundStyle(.secondary)
                }
                
                // show anaylyis results
            }
        }
    }
}

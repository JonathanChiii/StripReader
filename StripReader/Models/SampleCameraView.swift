//
//  SampleCameraView.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/15/25.
//

import Foundation
import SwiftUI
import UIKit

struct ScannerViewSample: View {
    @State private var capturedImage: UIImage?
    @State private var barResults: [BarResult] = []
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 16) {

            // MARK: Capture window
            Group {
                if let uiImage = capturedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray.opacity(0.4), lineWidth: 1)
                        )
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .foregroundStyle(.gray.opacity(0.4))

                        Text("Point the camera at a strip\nand tap the shutter to scan.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    .frame(height: 260)
                }
            }
            .padding(.horizontal)

            // MARK: Shutter / X button
            Button {
                if capturedImage == nil {
                    // Start first scan
                    showCamera = true
                } else {
                    // Clear current scan and start a new one
                    capturedImage = nil
                    barResults = []
                    showCamera = true
                }
            } label: {
                Image(systemName: capturedImage == nil ? "camera.circle.fill" : "xmark.circle.fill")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(capturedImage == nil ? .blue : .red)
                    .shadow(radius: 4)
            }
            .padding(.bottom, 4)

            // MARK: Results section
            VStack(alignment: .leading, spacing: 8) {
                Text("Results")
                    .font(.headline)
                    .padding(.horizontal)

                if barResults.isEmpty {
                    Text("No results yet. Capture a strip to analyze.")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                } else {
                    List(barResults) { bar in
                        HStack {
                            Text("Bar \(bar.index)")
                            Spacer()
                            Text(String(format: "Intensity: %.2f", bar.intensity))

                            Rectangle()
                                .fill(Color(bar.color))
                                .frame(width: 24, height: 24)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    .listStyle(.plain)
                }
            }

            Spacer()
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $capturedImage) {
                if let img = capturedImage {
                    //barResults = analyzeStrip(image: img)
                }
            }
            Text("Image Picker")
        }
    }
}

#Preview{
    ScannerViewSample()
}

//
//  ScannerView.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/15/25.
//

import Foundation
import SwiftUI
import Vision

struct ScannerView: View {
    
    // UI General
    let v_stack_spacing = CGFloat(16)
    let h_stack_spacing = CGFloat(8)
    let standard_corner_radius = CGFloat(12)
    let standard_opacity = CGFloat(0.5)

    
    // Scanned Image
    let frame_max_height = CGFloat(400)
    let frame_max_width = CGFloat(200)
    let results_frame_max_width = CGFloat(400)
    let results_frame_max_height = CGFloat(290)

    let overlay_line_width = CGFloat(1)
    
    // Camera View Finder
    let frame_line_width = CGFloat(2)
    let frame_dash_segment = CGFloat(5)
    let text_frame_height = CGFloat(600)
    let text_frame_width = CGFloat(300)
    let text_line_space = CGFloat(10)
    
    // Result Display
    let bar_frame_width = CGFloat(24)
    let bar_frame_height = CGFloat(24)
    
    // Icon
    let icon_width = CGFloat(64)
    let icon_height = CGFloat(64)
    let icon_shadow_radius = CGFloat(4)
    let icon_pedding = CGFloat(4)
    
    // Global vars
    @EnvironmentObject var appState: AppState
    let enableDebug: Bool = AppConfig.isDebug
    
    @State private var capturedImage: UIImage?
    //@State private var capturedImage: UIImage? = UIImage(named: "test_strip")
    @State private var barResults: [BarResult] = []
    @State private var prediction: Prediction?
    @State var debugInfo = AnalyzerDebug()
    @State private var showCamera = true
    @State private var showResult = false
    @StateObject private var cameraService = CameraService()

    
    var body: some View {
        VStack(spacing: self.v_stack_spacing) {
            Group {
                // if image captured, display the scanned image and result
                if let uiImage = self.capturedImage {
                    
                    // Display the scanned image
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        //.scaledToFit()
                        .frame(maxWidth: self.frame_max_width, maxHeight: self.frame_max_height)
                        .clipShape(RoundedRectangle(cornerRadius: self.standard_corner_radius))
                        .overlay(RoundedRectangle(cornerRadius: self.standard_corner_radius)
                            .stroke(.gray.opacity(self.standard_opacity), lineWidth: self.overlay_line_width)
                        )
                    
                    // Display the results
                    VStack(alignment: .leading, spacing: self.h_stack_spacing) {
                        if enableDebug && !debugInfo.stages.isEmpty {
                            // Display the statistics of each debug stage in a scroll view
                            ScrollView {
                                ForEach(debugInfo.stages) { stage in
                                    VStack(alignment: .leading) {
                                        Text(stage.label)
                                            .font(.caption)
                                        Image(uiImage: stage.image)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .padding(.bottom, 12)
                                }
                            }
                            .frame(height: 200)
                        }
                        
                        // Display the final results
                        Text("Analyzed Result:")
                            .font(.headline)
                            .padding(.horizontal)

                        if !self.barResults.isEmpty {
                            List(self.barResults) { bar in
                                HStack {
                                    Text("Bar \(bar.index)")
                                    Spacer()
                                    if(bar.detected) {
                                        Text("Y")
                                    } else {
                                        Text("N")
                                    }
                                    Text(String(format: "Intensity: %.4f", bar.intensity))
                                    
                                    Rectangle()
                                        .fill(Color(bar.color))
                                        .frame(width: self.bar_frame_width, height: self.bar_frame_height)
                                        .clipShape(RoundedRectangle(cornerRadius: self.standard_corner_radius))
                                }
                            }
                            .listStyle(.plain)
                        }
                        
                        // Display the prediction
                        if let prediction {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Predicted: \(prediction.concentration.rawValue)")
                                    .font(.title2)

                                Text("Confidence: \(Int(prediction.confidence * 100))%")
                                    .foregroundStyle(.secondary)

                                if AppConfig.isDebug {
                                    Text("Reason: \(prediction.reason)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }

                    }
                    .frame(maxWidth: self.results_frame_max_width, maxHeight: self.results_frame_max_height)
                    
                        //.padding(.top, 0)
                } else { // if image not captured, display the live camera preview with instruction frame
                    ZStack {
                        CameraPreview(session: cameraService.session)

                        if let rect = cameraService.detectedRectangle {
                            RectangleOverlay(rect: rect)
                        }
                        GuideOverlay()
                    }

                    .frame(height: 630)
                }
            }
            //.padding(.top, 0)
            .padding(.horizontal)
            
            // Shutter Button
            Button {
                if self.capturedImage != nil {
                    // clear current image and start a new scan
                    self.capturedImage = nil
                    self.barResults = []
                    self.showResult = false
                } else {
                    cameraService.capture()
                }
            } label: {
                Image(systemName: cameraService.detectedRectangle == nil
                      ? "circle"
                      : "circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(cameraService.detectedRectangle == nil ? .gray : .white)
            }
            .disabled(cameraService.detectedRectangle == nil)
            .padding(.bottom, self.icon_pedding)
        }
        .onReceive(cameraService.$capturedImage) { inputCGImage in
            guard let inputCGImage else { return }
            
            // Convert to UIImage ONLY if you need UI display
            let uiImage = UIImage(cgImage: inputCGImage, scale: UIScreen.main.scale, orientation: .right)
            self.capturedImage = uiImage

            // Reset previous results
            barResults = []
            prediction = nil
            debugInfo.reset()

            // Call analyzer
            analyzeStrip(capturedCGImage: inputCGImage, debug: debugInfo) { analysis in
                guard let analysis else { return }
                self.barResults = analysis.bars
                self.prediction = analysis.prediction
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    
}

struct GuideOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // Vertical rails
                Path { path in
                    let railOffset = width * 0.47
                    path.move(to: CGPoint(x: railOffset, y: 0))
                    path.addLine(to: CGPoint(x: railOffset, y: height))
                    path.move(to: CGPoint(x: width - railOffset, y: 0))
                    path.addLine(to: CGPoint(x: width - railOffset, y: height))
                }
                .stroke(.green.opacity(0.6), lineWidth: 2)

                // Center band (where bars should be)
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundColor(.green.opacity(0.6))
                    .frame(height: height * 0.35)
            }
        }
        .allowsHitTesting(false)
    }
}

struct RectangleOverlay: View {

    let rect: DetectedRectangle

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let r = rect.boundingBox

                let x = r.origin.x * geo.size.width
                let y = (1 - r.origin.y - r.height) * geo.size.height
                let w = r.width * geo.size.width
                let h = r.height * geo.size.height

                path.addRect(CGRect(x: x, y: y, width: w, height: h))
            }
            .stroke(rect.confidence > 0.8 ? .green : .yellow, lineWidth: 3)
        }
    }
}

#Preview {
    ScannerView()
}

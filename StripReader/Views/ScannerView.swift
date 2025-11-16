//
//  ScannerView.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/15/25.
//

import Foundation
import SwiftUI

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
    
    
    
    @State private var capturedImage: UIImage?
    //@State private var capturedImage: UIImage? = UIImage(named: "test_strip")
    @State private var barResult: [BarResult] = []
    @State private var showCamera = false
    
    var body: some View {
        VStack(spacing: self.v_stack_spacing) {
            Group {
                // Display the scanned image
                if let uiImage = self.capturedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        //.scaledToFit()
                        .frame(maxWidth: self.frame_max_width, maxHeight: self.frame_max_height)
                        .clipShape(RoundedRectangle(cornerRadius: self.standard_corner_radius))
                        .overlay(RoundedRectangle(cornerRadius: self.standard_corner_radius)
                            .stroke(.gray.opacity(self.standard_opacity), lineWidth: self.overlay_line_width)
                        )
                        //.padding(.top, 0)
                    
                        
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: self.standard_corner_radius)
                            .stroke(.orange, style: StrokeStyle(lineWidth: self.frame_line_width, dash: [self.frame_dash_segment]))
                            .foregroundStyle(.gray.opacity(self.standard_opacity))
                        
                        Text("Align test strip in the frame \n then tap the shutter to scan")
                            .bold()
                            .lineSpacing(self.text_line_space)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    .frame(width: self.text_frame_width, height: self.text_frame_height)
                }
            }
            .padding(.top, 0)
            //.padding(.horizontal)
            
            
            // Result display
            if capturedImage != nil {
                VStack(alignment: .leading, spacing: self.h_stack_spacing) {
                    Text("Results")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if !self.barResult.isEmpty {
                        List(self.barResult) { bar in
                            HStack {
                                Text("Bar \(bar.index)")
                                Spacer()
                                Text(String(format: "Color Intensity: %.2f", bar.intensity))
                                
                                Rectangle()
                                    .fill(Color(bar.color))
                                    .frame(width: self.bar_frame_width, height: self.bar_frame_height)
                                    .clipShape(RoundedRectangle(cornerRadius: self.standard_corner_radius))
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .frame(maxWidth: self.results_frame_max_width, maxHeight: self.results_frame_max_height)
            }
            
            
            // Shutter Button
            Button {
                if self.capturedImage != nil {
                    // clear current image and start a new scan
                    self.capturedImage = nil
                    self.barResult = []
                }
                self.showCamera = true
                

            } label: {
                Image(systemName: self.capturedImage == nil ? "camera.circle.fill" : "xmark.circle.fill")
                    .resizable()
                    .frame(width: self.icon_width, height: self.icon_height)
                    .foregroundStyle(capturedImage == nil ? .blue : .red)
                    .shadow(radius: self.icon_shadow_radius)
            }
            .padding(.bottom, self.icon_pedding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $capturedImage) {
                 if let img = capturedImage {
                    self.barResult = analyzeStrip(image: img)
                }
            }
            Text("Image Picker")
        }
    }
    
    
}

#Preview {
    ScannerView()
}

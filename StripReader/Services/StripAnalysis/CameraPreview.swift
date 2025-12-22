////
////  CameraPreview.swift
////  StripReader
////
////  Created by jOnAtHaN Chi on 11/23/25.
////
//
//import Foundation
//import SwiftUI
//import AVFoundation
//
//struct CameraPreview: UIViewRepresentable {
//    let cameraService: CameraService
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//
//        let layer = cameraService.makePreviewLayer()
//        layer.frame = UIScreen.main.bounds
//        view.layer.addSublayer(layer)
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {}
//}

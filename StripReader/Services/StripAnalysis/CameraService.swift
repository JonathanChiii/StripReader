////
////  CameraService.swift
////  StripReader
////
////  Created by jOnAtHaN Chi on 11/23/25.
////
//
//import AVFoundation
//import UIKit
//
//@MainActor
//class CameraService: NSObject, ObservableObject {
//    
//    // MARK: - Published Output
//    @Published var capturedImage: UIImage?
//
//    // MARK: - Capture Session
//    let session = AVCaptureSession()
//    private let output = AVCapturePhotoOutput()
//
//    // Session runs on a dedicated queue (but controlled from main actor)
//    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
//    
//    // MARK: - Init
//    override init() {
//        super.init()
//    }
//    
//    // MARK: - Configure Camera
//    func configure() {
//        sessionQueue.async { [weak self] in
//            guard let self else { return }
//
//            Task { @MainActor in
//                self.setupSession()
//            }
//        }
//    }
//    
//    private func setupSession() {
//        session.beginConfiguration()
//        session.sessionPreset = .photo
//        
//        // Input
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
//                                                   for: .video,
//                                                   position: .back),
//              let input = try? AVCaptureDeviceInput(device: device)
//        else {
//            print("⚠️ Could not create camera input")
//            session.commitConfiguration()
//            return
//        }
//        
//        if session.canAddInput(input) {
//            session.addInput(input)
//        }
//        
//        // Output
//        if session.canAddOutput(output) {
//            session.addOutput(output)
//        }
//
//        output.isHighResolutionCaptureEnabled = true
//        
//        session.commitConfiguration()
//        session.startRunning()
//    }
//    
//    // MARK: - Preview Layer
//    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
//        let layer = AVCaptureVideoPreviewLayer(session: session)
//        layer.videoGravity = .resizeAspectFill
//        return layer
//    }
//    
//    // MARK: - Capture Photo
//    func capturePhoto() {
//        let settings = AVCapturePhotoSettings()
//        settings.flashMode = .off
//        settings.isHighResolutionPhotoEnabled = true
//
//        output.capturePhoto(with: settings, delegate: self)
//    }
//}
//extension CameraService: AVCapturePhotoCaptureDelegate {
//
//    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
//                                 didFinishProcessingPhoto photo: AVCapturePhoto,
//                                 error: Error?) {
//
//        if let data = photo.fileDataRepresentation(),
//           let image = UIImage(data: data) { DispatchQueue.main.async { self.capturedImage = image }
//        }
//    }
//}
//

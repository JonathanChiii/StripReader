//
//  CameraService.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 12/22/25.
//

import AVFoundation
import UIKit

@MainActor
final class CameraService: NSObject, ObservableObject {

    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    @Published var capturedImage: CGImage?

    override init() {
        super.init()
        configure()
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            return
        }

        session.addOutput(output)

        session.commitConfiguration()
        session.startRunning()
    }

    func capture() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {

    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {

        guard
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data),
            let cg = image.cgImage
        else { return }

        Task { @MainActor in
            self.capturedImage = cg
        }
    }
}

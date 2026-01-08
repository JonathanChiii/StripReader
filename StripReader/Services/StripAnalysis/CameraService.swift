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

    private var videoDevice: AVCaptureDevice?

    override init() {
        super.init()
        configure()
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Prefer higher-quality back cameras when available
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera,
                .builtInDualCamera,
                .builtInTelephotoCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .back
        )

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                             for: .video,
                                                             position: .back),
            //let device = discovery.devices.first,
            // uncomment this line if want to use the ultra wide camera digital zoom
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }

        self.videoDevice = device
        session.addInput(input)

        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            return
        }
        session.addOutput(output)

        session.commitConfiguration()
        session.startRunning()
        setZoomFactor(3.0)
    }

    /// Call this whenever you want to change zoom (e.g. default, or slider later).
    func setZoomFactor(_ factor: CGFloat) {
        guard let device = videoDevice else { return }

        let clamped = min(max(factor, device.minAvailableVideoZoomFactor),
                          device.maxAvailableVideoZoomFactor)

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clamped
            device.unlockForConfiguration()
        } catch {
            print("⚠️ Failed to set zoom: \(error)")
        }
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

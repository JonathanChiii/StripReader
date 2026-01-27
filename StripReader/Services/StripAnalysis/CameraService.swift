import AVFoundation
import Vision
import UIKit

// ✅ Sendable value type (do NOT store VNRectangleObservation in @Published)
struct DetectedRectangle: Sendable {
    let boundingBox: CGRect
    let confidence: Float
}

@MainActor
final class CameraService: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let visionQueue = DispatchQueue(label: "vision.queue")

    @Published var capturedImage: CGImage?
    @Published var detectedRectangle: DetectedRectangle?

    override init() {
        super.init()
        configure()
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        // Photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        // Video output for Vision
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.setSampleBufferDelegate(self, queue: visionQueue)

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        // Keep video orientation consistent
        if let conn = videoOutput.connection(with: .video), conn.isVideoOrientationSupported {
            conn.videoOrientation = .portrait
        }

        session.commitConfiguration()
        session.startRunning()
    }

    // Your existing photo capture method can stay as-is.
    func capture() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// ✅ IMPORTANT: this extension MUST be at file scope (not nested),
// and captureOutput MUST be an instance method (not static).
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {

    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectRectanglesRequest { [weak self] request, _ in
            guard let self else { return }

            guard let rect = (request.results as? [VNRectangleObservation])?.first else {
                Task { @MainActor in
                    self.detectedRectangle = nil
                }
                return
            }

            let box = rect.boundingBox
            let aspect = box.width / box.height

//            // ✅ Enforce square AFTER detection
//            let squareTolerance: CGFloat = 0.1
//            guard abs(aspect - 1.0) < squareTolerance else {
//                Task { @MainActor in
//                    self.detectedRectangle = nil
//                }
//                return
//            }

            // Optional size filter
            let area = box.width * box.height
            guard area > 0.05, area < 0.8 else { return }

            let safeRect = DetectedRectangle(
                boundingBox: box,
                confidence: rect.confidence
            )

            Task { @MainActor in
                self.detectedRectangle = safeRect
            }
        }

        request.maximumObservations = 1
        request.minimumConfidence = 0.8
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 1.0
        request.quadratureTolerance = 20

        // Adjust orientation if needed (portrait back camera is commonly .right)
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .right,
                                            options: [:])
        try? handler.perform([request])
    }
}

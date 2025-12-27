//
//  CameraPreview.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 12/22/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait

        view.layer.addSublayer(layer)

        DispatchQueue.main.async {
            layer.frame = view.bounds
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
        layer.frame = uiView.bounds
    }
}


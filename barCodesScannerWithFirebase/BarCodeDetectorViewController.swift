//
//  BarCodeDetectorViewController.swift
//  FirebaseML
//
//  Created by Mohammad Azam on 5/10/18.
//  Copyright © 2018 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Firebase

class BarCodeDetectorViewController : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imageView :UIImageView!
    @IBOutlet weak var barCodeRawValueLabel :UILabel! 
    
    let session = AVCaptureSession()
    lazy var vision = Vision.vision()
    var barcodeDetector :VisionBarcodeDetector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLiveVideo()
        self.barcodeDetector = vision.barcodeDetector()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let format = VisionBarcodeFormat.all
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        
        let visionImage = VisionImage(buffer: sampleBuffer)
        
        barcodeDetector.detect(in: visionImage) { (barcodes, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            for barcode in barcodes! {
                print(barcode.rawValue!)
                self.barCodeRawValueLabel.text = barcode.rawValue!
            }
        }
    }
    
    private func startLiveVideo() {
        
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        captureSession.addOutput(deviceOutput)
        
        let imageLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        imageLayer.frame = CGRect(x: 0, y: 0, width: self.imageView.frame.size.width, height: self.imageView.frame.size.height)
        imageLayer.videoGravity = .resizeAspectFill
        imageView.layer.addSublayer(imageLayer)
        
        self.view.bringSubview(toFront: barCodeRawValueLabel)
    }
    
}

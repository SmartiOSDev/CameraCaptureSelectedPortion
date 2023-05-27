//
//  SecondViewController.swift
//  CustomCameraClassdemo
//
//  Created by Harshad Jadav  on 09/04/23.
//

import UIKit
import AVFoundation

class SecondViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imageView: UIImageView!

    
    var previewLayer: AVCaptureVideoPreviewLayer?
       var captureSession: AVCaptureSession?
       var captureConnection: AVCaptureConnection?
       var cameraDevice: AVCaptureDevice?
       var photoOutput: AVCapturePhotoOutput?
    @IBOutlet weak var capturePhotobtn: UIButton!
    var orientation = UIImage.Orientation.up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
                startSession()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageView.image = nil
    }
    
    @IBAction func button(_ sender: Any) {
        capturePhoto()
    }

}


extension SecondViewController {
    func startSession() {
            if let videoSession = captureSession {
                if !videoSession.isRunning {
                    videoSession.startRunning()
                }
            }
        }
        
        func stopSession() {
            if let videoSession = captureSession {
                if videoSession.isRunning {
                    videoSession.stopRunning()
                }
            }
        }
        
        internal func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
            print("willBeginCaptureFor")
        }
        
       
        
        func capturePhoto() {
            print(captureConnection?.isActive)
            let photoSettings = AVCapturePhotoSettings()
            photoOutput?.capturePhoto(with: photoSettings, delegate: self)
        }
        
        func prepareCamera() {
            photoOutput = AVCapturePhotoOutput()
            captureSession = AVCaptureSession()
            captureSession!.sessionPreset = AVCaptureSession.Preset.photo
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            do {
                let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
                let cameraDevice = deviceDiscoverySession.devices[0]
                let videoInput = try AVCaptureDeviceInput(device: cameraDevice)
                captureSession!.beginConfiguration()
                if captureSession!.canAddInput(videoInput) {
                    print("Adding videoInput to captureSession")
                    captureSession!.addInput(videoInput)
                } else {
                    print("Unable to add videoInput to captureSession")
                }
                if captureSession!.canAddOutput(photoOutput!) {
                    captureSession!.addOutput(photoOutput!)
                    print("Adding videoOutput to captureSession")
                } else {
                    print("Unable to add videoOutput to captureSession")
                }
                captureConnection = AVCaptureConnection(inputPorts: videoInput.ports, output: photoOutput!)
                captureSession!.commitConfiguration()
                if let previewLayer = previewLayer {
                    if ((previewLayer.connection?.isVideoMirroringSupported) != nil) {
                        previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
                        previewLayer.connection?.isVideoMirrored = true
                    }
                    previewLayer.frame = view.bounds
                    view.layer.addSublayer(previewLayer)
                    view.bringSubviewToFront(capturePhotobtn)
                    
                    imageView.layer.borderWidth = 4
                    imageView.layer.borderColor = UIColor.green.cgColor
                    self.view.bringSubviewToFront(imageView)

                }
                captureSession!.startRunning()
            } catch {
                print(error.localizedDescription)
            }
        }
    
    }


extension SecondViewController {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("didFinishProcessingPhoto")
        
        guard let data = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: data) else { return }
       
        let sideLength = min(
            image.size.width,
            image.size.height
        )

        let sourceSize = image.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral

        let sourceCGImage = image.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!
        let ima = UIImage(cgImage: croppedCGImage)
        imageView.image = ima
        
        UIImageWriteToSavedPhotosAlbum(ima, self, nil, nil)

    }
    
    
}


extension UIImage {
  func cropped(to size: CGSize) -> UIImage? {
    guard let cgImage = cgImage?
        .cropping(to: .init(origin: .init(x: (self.size.width-size.width)/2,
                                          y: (self.size.height-size.height)/2),
                            size: size)) else { return nil }
    let format = imageRendererFormat
    return UIGraphicsImageRenderer(size: size, format: format).image {
        _ in
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
            .draw(in: .init(origin: .zero, size: size))
    }

 }
}

//
//  ViewController.swift
//  CustomCameraClassdemo
//
//  Created by Harshad Jadav  on 09/04/23.
//

import UIKit
import AVFoundation
class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var capturePhoto: UIButton!
    var session = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var captureDevice : AVCaptureDevice!
    var stillImageOutput =  AVCapturePhotoOutput()
    let outPut = AVCaptureMetadataOutput()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //stillImageOutput = AVCapturePhotoOutput()
        
        guard let captureDeive = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDeive)
            session.addInput(input)
            session.addOutput(outPut)
        } catch {
            print(error.localizedDescription)
        }
        session.sessionPreset = AVCaptureSession.Preset.photo
       
        
        
       // outPut.setMetadataObjectsDelegate(self, queue: .main)

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.green.cgColor
        self.view.bringSubviewToFront(imageView)

        self.view.bringSubviewToFront(capturePhoto)

        
        session.startRunning()
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
    }
     
    
    @IBAction func capturePhotoAction(_ sender: UIButton) {
        stillImageOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)

    }


    func getImageFromSampleBuffer(buffer:CMSampleBuffer, orientation: UIImage.Orientation) -> UIImage? {
            if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext()
                let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))

                if let image = context.createCGImage(ciImage, from: imageRect) {
                    return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: orientation)

                }

            }
            return nil
        }
    
}
extension ViewController: AVCapturePhotoCaptureDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                           didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("s")
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("output")


        var orientation = UIImage.Orientation.up
        if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer, orientation: orientation) {

            DispatchQueue.main.async {
                let newImage = image.imageByCropToRect(rect: self.imageView.frame, scale: true)
                self.session.stopRunning()
                self.previewLayer.removeFromSuperlayer()
                debugPrint(newImage)

            }
        }

    }
}

extension UIImage {
    func imageByCropToRect(rect:CGRect, scale:Bool) -> UIImage {
        var rect = rect
        var scaleFactor: CGFloat = 1.0
        if scale  {
            scaleFactor = self.scale
            rect.origin.x *= scaleFactor
            rect.origin.y *= scaleFactor
            rect.size.width *= scaleFactor
            rect.size.height *= scaleFactor
        }

        var image: UIImage? = nil;
        if rect.size.width > 0 && rect.size.height > 0 {
            let imageRef = self.cgImage!.cropping(to: rect)
            image = UIImage(cgImage: imageRef!, scale: scaleFactor, orientation: self.imageOrientation)
        }

        return image!
    }
}

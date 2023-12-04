//
//  MaterialCreaterViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/12/4.
//

import UIKit
import AVFoundation
import OSLog
import CoreImage
import Vision

class MaterialCreaterViewController: UIViewController,UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    @IBOutlet weak var photoImageView: UIImageView!
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    let segmentationModel: DeepLabV3 = {
        do {
            let config = MLModelConfiguration()
            return try DeepLabV3(configuration: config)
        } catch {
            Logger().error("Error loading model.")
            abort()
        }
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            Logger().error("Could not create request.")
            abort()
        }
    }
    // 設定選擇照片後的動作為顯示圖片及關掉視窗
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
        }
        dismiss(animated: true)
    }
    @IBAction func gallery(_ sender: Any) {
        // 選擇圖庫照片
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        present(controller, animated: true)
    }
    @IBAction func camera(_ sender: Any) {
        // 檢查相機是否可用
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("相機不可用")
            return
        }
        // 檢查是否有相機許可權
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .authorized:
            // 有相機許可權，執行相機操作
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        case .notDetermined:
            // 尚未詢問用戶許可權，執行詢問用戶
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // 用戶同意許可權，執行相機操作（這個在主線程執行）
                    DispatchQueue.main.async {
                        self.camera(self)
                    }
                } else {
                    // 用戶拒絕許可權，提供提示
                    print("相機許可權被拒絕")
                }
            }
        case .denied, .restricted:
            // 用戶拒絕或限制許可權，提供提示
            print("相機許可權被拒絕或受限")
        }
    }
    @IBAction func removeBG(_ sender: Any) {
        Logger().info("Start: \(Date(), privacy: .public)")
        if let uiImage = photoImageView.image {
            predict(with: uiImage.cgImage)
        } else {
            print("沒有成功轉成cgImage")
        }
    }
    func predict(with cgImage: CGImage?) {
        guard let request = request else { fatalError() }
        guard let cgImage = cgImage else {
            return
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    fileprivate func applyBackgroundMask(_ image: UIImage) {
        if let uiImage = photoImageView.image {
               let mainImage = CIImage(cgImage: uiImage.cgImage!)
               let originalSize = mainImage.extent.size
               let maskUIImage = image.resized(to: originalSize)
               var maskImage = CIImage(cgImage: maskUIImage.cgImage!)
               DispatchQueue.main.async {
                   // Scale the mask image to fit the bounds of the video frame.
                   maskImage = maskImage.applyingGaussianBlur(sigma: 3.0)
                   // Resize maskImage to match the original image size
                   let resizedMaskImage = maskImage.transformed(by: CGAffineTransform(scaleX: originalSize.width / maskImage.extent.width, y: originalSize.height / maskImage.extent.height))
                   let background = CIImage(cgImage: (UIImage(color: .clear, size: originalSize)?.cgImage)!)
                   let filter = CIFilter(name: "CIBlendWithMask")
                   // Use resizedMaskImage in the filter
                   filter?.setValue(resizedMaskImage, forKey: kCIInputMaskImageKey)
                   filter?.setValue(background, forKey: kCIInputBackgroundImageKey)
                   filter?.setValue(mainImage, forKey: kCIInputImageKey)
                   if let outputImage = filter?.outputImage {
                       // Crop the output image to the original size
                       let croppedOutputImage = outputImage.cropped(to: mainImage.extent)
                       self.photoImageView.image = UIImage(ciImage: croppedOutputImage)
                       Logger().info("Done: \(Date(), privacy: .public)")
                   } else {
                       print("Failed to create output image")
                   }
               }
           }
    }
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
           let segmentationmap = observations.first?.featureValue.multiArrayValue {
            guard let maskUIImage = segmentationmap.image(min: 0.0, max: 1.0) else { return }
            applyBackgroundMask(maskUIImage)
        }
    }
}
extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        if let cgImage = image.cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}

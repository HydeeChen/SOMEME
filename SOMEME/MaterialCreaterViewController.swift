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
import FirebaseCore
import FirebaseFirestore
import Lottie

class MaterialCreaterViewController: UIViewController,UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var workButtonOutlet: UIButton!
    @IBOutlet weak var cuteButtonOutlet: UIButton!
    @IBOutlet weak var animalButtonOutlet: UIButton!
    @IBOutlet weak var usualButtonOutlet: UIButton!
    @IBOutlet weak var newsButtonOutlet: UIButton!
    @IBOutlet weak var meansButtonOutlet: UIButton!
    @IBOutlet weak var animeButtonOutlet: UIButton!
    @IBOutlet weak var kusoButtonOutlet: UIButton!
    @IBOutlet weak var funnyButtonOutlet: UIButton!
    var workButtonFill = false
    var cuteButtonFill = false
    var animalButtonFill = false
    var usuallButtonFill = false
    var newsButtonFill = false
    var meansButtonFill = false
    var animeButtonFill = false
    var kusoButtonFill = false
    var funnyButtonFill = false
    let fullCircleImage = UIImage(systemName: "circle.fill")
    let emptyCircleImage = UIImage(systemName: "circle")
    var hashTagArray: [String] = []
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    @IBOutlet weak var hashTagView: UIView!
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
        hashTagView.isHidden = true
        if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            Logger().error("Could not create request.")
            abort()
        }
        // 設定手勢
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                view.addGestureRecognizer(tapGesture)
    }
    // 收起鍵盤
    @objc func handleTap() {
           view.endEditing(true)
       }

    // 設定選擇照片後的動作為顯示圖片及關掉視窗
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
        }
        dismiss(animated: true)
    }
    @IBAction func uploadMaterial(_ sender: Any) {
        hashTagView.isHidden = false
        //
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
        let AnimationView = LottieAnimationView()
        let Animation = LottieAnimation.named("spark")
        AnimationView.animation = Animation
        AnimationView.frame = CGRect(x: -50, y: 40, width: 500, height: 500)
        view.addSubview(AnimationView)
        AnimationView.play()
        AnimationView.play(fromProgress: 0.0, toProgress: 0.7, loopMode: .none) { (completed) in
            if completed {
                AnimationView.removeFromSuperview()
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
    
    @IBAction func uploadMemes(_ sender: Any) {
        // 清空 hashTagArray
        hashTagArray = []
        // 根據按鈕的狀態，將相應的標籤附加到 hashTagArray
        if workButtonFill {
            hashTagArray.append("工作")
        }
        if cuteButtonFill {
            hashTagArray.append("可愛")
        }
        if animalButtonFill {
            hashTagArray.append("動物")
        }
        if usuallButtonFill {
            hashTagArray.append("日常")
        }
        if newsButtonFill {
            hashTagArray.append("時事")
        }
        if meansButtonFill {
            hashTagArray.append("嗆人")
        }
        if animeButtonFill {
            hashTagArray.append("動畫")
        }
        if kusoButtonFill {
            hashTagArray.append("惡搞")
        }
        if funnyButtonFill {
            hashTagArray.append("搞笑")
        }
        hashTagArray.append("\(textFieldOutlet.text ?? " ")")
        print(hashTagArray)
        //         檢查是否有選擇圖片
        guard let selectedImage = photoImageView.image else {
            print("請選擇一張照片")
            return
        }
        // 呼叫 UpLoadStorage 類別的 uploadPhoto 函式上傳照片
        let uploadStorage = UpLoadStorage()
        uploadStorage.uploadPhoto(image: selectedImage) { result in
            switch result {
            case .success(let url):
                print("照片上傳成功，下載連結：\(url)")
                // 取得url後上傳到firebase
                let uuid = UUID().uuidString
                let db = Firestore.firestore()
                let documentRef = db.collection("material").document(uuid)
                documentRef.setData([
                    "id": uuid,
                    "hashtag": self.hashTagArray,
                    "url": "\(url)",
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(uuid)")
                    }
                }
            case .failure(let error):
                print("照片上傳失敗，錯誤：\(error.localizedDescription)")
                // 這裡可以進行其他相關的處理，例如顯示錯誤提示
            }
        }
        hashTagView.isHidden = true
        let AnimationView = LottieAnimationView()
        let Animation = LottieAnimation.named("rocketDog")
        AnimationView.animation = Animation
        AnimationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        AnimationView.center = view.center
        view.addSubview(AnimationView)
        AnimationView.play()
        AnimationView.play(fromProgress: 0.0, toProgress: 0.4, loopMode: .none) { (completed) in
            if completed {
                AnimationView.removeFromSuperview()
            }
        }
    }
    @IBAction func funnyButtonAction(_ sender: Any) {
        if funnyButtonFill == false {
            funnyButtonOutlet.setImage(fullCircleImage, for: .normal)
            funnyButtonFill = true
        } else {
            funnyButtonOutlet.setImage(emptyCircleImage, for: .normal)
            funnyButtonFill = false
        }
    }
    @IBAction func kusoButtonAction(_ sender: Any) {
        if kusoButtonFill == false {
            kusoButtonOutlet.setImage(fullCircleImage, for: .normal)
            kusoButtonFill = true
        } else {
            kusoButtonOutlet.setImage(emptyCircleImage, for: .normal)
            kusoButtonFill = false
        }
    }
    @IBAction func animeButtonAction(_ sender: Any) {
        if animeButtonFill == false {
            animeButtonOutlet.setImage(fullCircleImage, for: .normal)
            animeButtonFill = true
        } else {
            animeButtonOutlet.setImage(emptyCircleImage, for: .normal)
            animeButtonFill = false
        }
    }
    @IBAction func meansButtonAction(_ sender: Any) {
        if meansButtonFill == false {
            meansButtonOutlet.setImage(fullCircleImage, for: .normal)
            meansButtonFill = true
        } else {
            meansButtonOutlet.setImage(emptyCircleImage, for: .normal)
            meansButtonFill = false
        }
    }
    @IBAction func newsButtonAction(_ sender: Any) {
        if newsButtonFill == false {
            newsButtonOutlet.setImage(fullCircleImage, for: .normal)
            newsButtonFill = true
        } else {
            newsButtonOutlet.setImage(emptyCircleImage, for: .normal)
            newsButtonFill = false
        }
    }
    @IBAction func usualButtonAction(_ sender: Any) {
        if usuallButtonFill == false {
            usualButtonOutlet.setImage(fullCircleImage, for: .normal)
            usuallButtonFill = true
        } else {
            usualButtonOutlet.setImage(emptyCircleImage, for: .normal)
            usuallButtonFill = false
        }
    }
    @IBAction func animalButtonAction(_ sender: Any) {
        if animalButtonFill == false {
            animalButtonOutlet.setImage(fullCircleImage, for: .normal)
            animalButtonFill = true
        } else {
            animalButtonOutlet.setImage(emptyCircleImage, for: .normal)
            animalButtonFill = false
        }
    }
    @IBAction func cuteButtonAction(_ sender: Any) {
        if cuteButtonFill == false {
            cuteButtonOutlet.setImage(fullCircleImage, for: .normal)
            cuteButtonFill = true
        } else {
            cuteButtonOutlet.setImage(emptyCircleImage, for: .normal)
            cuteButtonFill = false
        }
    }
    @IBAction func workButtonAction(_ sender: Any) {
        if workButtonFill == false {
            workButtonOutlet.setImage(fullCircleImage, for: .normal)
            workButtonFill = true
        } else {
            workButtonOutlet.setImage(emptyCircleImage, for: .normal)
            workButtonFill = false
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

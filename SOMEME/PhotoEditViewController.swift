//
//  PhotoEditViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/16.
//

import UIKit
import AVFoundation

class PhotoEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //  拉陰影
    @IBOutlet weak var shadowOfCreate: UIView!
    @IBOutlet var shadowOfEdit: UIView!
    @IBOutlet var shadowOfCamera: UIView!
    @IBOutlet var shadowOfGallery: UIView!
    // 照片顯示
    @IBOutlet var photoImageView: UIImageView!
    // 尚未選取照片的label
    @IBOutlet var unselectLabel: UILabel!
    // 開始編輯紅色鈕ui
    @IBOutlet var redViewOfEdit: UIView!
    @IBOutlet var editButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定照片陰影
        shadowOfCreate.layer.cornerRadius = CGFloat(30)
        shadowOfCreate.layer.shadowOpacity = Float(1)
        shadowOfCreate.layer.shadowRadius = CGFloat(15)
        shadowOfCreate.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        shadowOfEdit.layer.cornerRadius = CGFloat(30)
        shadowOfEdit.layer.shadowOpacity = Float(1)
        shadowOfEdit.layer.shadowRadius = CGFloat(15)
        shadowOfEdit.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        shadowOfCamera.layer.cornerRadius = CGFloat(30)
        shadowOfCamera.layer.shadowOpacity = Float(1)
        shadowOfCamera.layer.shadowRadius = CGFloat(15)
        shadowOfCamera.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        shadowOfGallery.layer.cornerRadius = CGFloat(30)
        shadowOfGallery.layer.shadowOpacity = Float(1)
        shadowOfGallery.layer.shadowRadius = CGFloat(15)
        shadowOfGallery.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        // 初始時設定開始編輯ui為隱藏
        shadowOfEdit.isHidden = true
        redViewOfEdit.isHidden = true
        editButtonOutlet.isHidden = true
    }

    @IBAction func openGallery(_: Any) {
        // 開始編輯ui顯示設定
        shadowOfEdit.isHidden = false
        redViewOfEdit.isHidden = false
        editButtonOutlet.isHidden = false
        // 選擇圖庫照片
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        present(controller, animated: true)
        // 尚未選擇照片文字隱藏
        unselectLabel.isHidden = true
    }

    // 設定選擇照片後的動作為顯示圖片及關掉視窗
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
        }
        dismiss(animated: true)
    }

    @IBAction func takePhoto(_: Any) {
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
                // 開始編輯ui顯示設定
                shadowOfEdit.isHidden = false
                redViewOfEdit.isHidden = false
                editButtonOutlet.isHidden = false
                // 尚未選擇照片文字隱藏
                unselectLabel.isHidden = true
            case .notDetermined:
                // 尚未詢問用戶許可權，執行詢問用戶
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        // 用戶同意許可權，執行相機操作（這個在主線程執行）
                        DispatchQueue.main.async {
                            self.takePhoto(self)
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
    @IBAction func creativeMode(_ sender: Any) {
        let st = UIStoryboard(name: "Main", bundle: nil)
               let editVC = st.instantiateViewController(withIdentifier: "EditingViewController") as! EditingViewController
               // 設定全螢幕呈現模式
               editVC.modalPresentationStyle = .fullScreen
               self.present(editVC, animated: true)
    }
    @IBAction func startToEdit(_ sender: Any) {
        if let photo = photoImageView.image {
                let st = UIStoryboard(name: "Main", bundle: nil)
                let editVC = st.instantiateViewController(withIdentifier: "EditingViewController") as! EditingViewController
                // 傳遞圖片給 EditingViewController
                editVC.imageViewLoad = photo
                // 設定全螢幕呈現模式
                editVC.modalPresentationStyle = .fullScreen
                self.present(editVC, animated: true)
            }
    }
}

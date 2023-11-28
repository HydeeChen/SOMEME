//
//  PhotoEditViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/16.
//

import UIKit

class PhotoEditViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    //  拉陰影
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
    }

    @IBSegueAction func passData(_ coder: NSCoder) -> EditingViewController? {
        let photo = photoImageView.image!
        let controller = EditingViewController(coder: coder)
        controller?.imageViewLoad = photo
        return controller
    }
}

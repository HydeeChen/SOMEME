//
//  EditingViewControllerExtension.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/12/12.
//

import Kingfisher
import UIKit
import TOCropViewController
import CoreImage
import FirebaseCore
import FirebaseFirestore
import Lottie
import Hover

extension EditingViewController {
    func setupImageGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        rotationGesture.delegate = self
        photoView.addGestureRecognizer(rotationGesture)
        photoView.addGestureRecognizer(panGesture)
        photoView.addGestureRecognizer(pinchGesture)
        imageGestures.append(rotationGesture)
        imageGestures.append(panGesture)
        imageGestures.append(pinchGesture)
    }
    func setupLabelGestures() {
        let labelPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLabelPanGesture(_:)))
        labelPanGesture.delegate = self
        let labelPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleLabelPinchGesture(_:)))
        labelPinchGesture.delegate = self
        let labelRotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleLabelRotationGesture(_:)))
        labelRotationGesture.delegate = self
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 1
        doubleTapGesture.delegate = self
        photoView.addGestureRecognizer(labelRotationGesture)
        photoView.addGestureRecognizer(labelPanGesture)
        photoView.addGestureRecognizer(labelPinchGesture)
        photoView.addGestureRecognizer(doubleTapGesture)
        labelGestures.append(labelRotationGesture)
        labelGestures.append(labelPanGesture)
        labelGestures.append(labelPinchGesture)
        labelGestures.append(doubleTapGesture)
    }
    // 開始文字編輯
    func startEditing(label: UILabel) {
        textColorButton.isHidden = false
        // 建立一個 UITextView 並放置在與 label 相同位置
        let textView = UITextView(frame: label.frame)
        textView.text = label.text
        textView.textAlignment = label.textAlignment
        textView.textColor = label.textColor
        textView.font = label.font
        textView.backgroundColor = .clear
        // 將 UITextView 添加到畫面中
        contentImageView.addSubview(textView)
        addedTextViews.append(textView)
        addedTextLabel.append(label)
        textView.tag = label.tag
        // 將選定的 label 隱藏
        label.isHidden = true
        // 設定選定的 UITextView
        selectedTextView = textView
        // 讓 UITextView 成為第一回應者，開始編輯
        textView.becomeFirstResponder()
    }
    func endEditing() {
        textColorButton.isHidden = true
        // 如果有選定的 UITextView，結束編輯
        if let textView = selectedTextView {
            textView.resignFirstResponder()
            // 將 UITextView 的內容套用到對應的 label 上
            if let label = addedTextLabel.first(where: { $0.tag == selectedTextView?.tag }) {
                label.text = textView.text
                label.isHidden = false
            }
            // 移除 UITextView
            selectedTextView?.removeFromSuperview()
            selectedTextView = nil
        }
    }
    // UITextViewDelegate 方法，用於結束編輯時的處理
    func textViewDidEndEditing(_: UITextView) {
        endEditing()
    }
    func loadMemeData() {
        // 設定 API 的 URL
        let url = URL(string: "https://memes.tw/wtf/api")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // 發送 API 請求
        URLSession.shared.dataTask(with: request) { data, _, error in
            print("Error API: \(String(describing: error))")
            if let data,
               let content = String(data: data, encoding: .utf8)
            {
                // 解碼 JSON 格式的資料
                //                print(content)
                let decoder = JSONDecoder()
                do {
                    let memes = try decoder.decode([MemeLoadDatum].self, from: data)
                    // 將取得的飲料資料存入 items 陣列
                    self.items = memes
                    self.updateCollectionView() // 成功就更新collectionView
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
            // 開始 API 請求
        }.resume()
    }
    func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension EditingViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        // 在這裡處理裁切後的圖片
        photoImageView.image = image
        // 關閉 TOCropViewController
        cropViewController.dismiss(animated: true, completion: nil)
        imageViewLoad = image
    }
    // 裁剪取消時的回調
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        // 關閉 TOCropViewController
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
extension EditingViewController: UIColorPickerViewControllerDelegate {
    // 新增顏色選擇工具
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedTextView?.textColor = viewController.selectedColor
        selectedLabel?.textColor = viewController.selectedColor
    }
}

extension EditingViewController: UICollectionViewDelegateFlowLayout {
    // 調整collectionView的大小
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100) // 調整 cell 大小
    }
}
extension EditingViewController: EditingCollectionViewCellDelegate {
    func didTapImage(imageView: UIImageView) {
        addImageViewToImageView(imageView: imageView)
    }
}

extension EditingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer
    }
}
extension  EditingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditingCollectionViewCell", for: indexPath) as? EditingCollectionViewCell else {
            fatalError("Unable to dequeue EditingCollectionViewCell")
        }
        if  isMaterialCollectionView == true  && isSearchMaterial == true {
            let material = searchMemeResult[indexPath.row]
            cell.delegate = self
            if let url = URL(string: material.url) {
                cell.memeImage.kf.setImage(with: url)
            }
        } else if isMaterialCollectionView == true && isSearchMaterial == false {
            let material = firebaseMeme[indexPath.row]
            cell.delegate = self
            if let url = URL(string: material.url) {
                cell.memeImage.kf.setImage(with: url)
            }
        } else if isMaterialCollectionView == false && isSearchMaterial == false {
            let item = items[indexPath.row]
            cell.delegate = self
            cell.memeImage.kf.setImage(with: item.src)
            cell.update(meme: item)
        }
        return cell
    }
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if  isMaterialCollectionView == true  && isSearchMaterial == true {
            return searchMemeResult.count
        } else if isMaterialCollectionView == true && isSearchMaterial == false {
            return firebaseMeme.count
        } else if isMaterialCollectionView == false && isSearchMaterial == false {
            return items.count
        }
        return 0
    }
}

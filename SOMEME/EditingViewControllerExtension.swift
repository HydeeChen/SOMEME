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

    // 設定viewDidLoad的功能
    override func viewDidLoad() {
        super.viewDidLoad()
        doodleLabelOutlet.isHidden = true
        // 設定初始搜尋outlet隱藏
        searchTextFieldOutlet.isHidden = true
        searchButtonOutlet.isHidden = true
        // 設定儲存outlet隱藏
        saveOutlet.isHidden = saveOutletIsHidden
        moveOutlet.isHidden = moveOutletIsHidden
        // 設定手勢
        setupImageGestures()
        setupLabelGestures()
        photoView.layer.cornerRadius = 30
        photoView.layer.shadowOpacity = Float(1)
        photoView.layer.shadowRadius = CGFloat(15)
        photoView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        doodleView.clipsToBounds = true
        doodleView.isMultipleTouchEnabled = false
        tabBarController?.tabBar.isHidden = false
        // 設定顯示傳值過來的圖片
        photoImageView.image = imageViewLoad
        // 梗圖collectionView設定
        let layoutPersonal = UICollectionViewFlowLayout()
        layoutPersonal.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        layoutPersonal.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.scrollDirection = UICollectionView.ScrollDirection.vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutPersonal)
        // collectionView資料源設定
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EditingCollectionViewCell.self, forCellWithReuseIdentifier: EditingCollectionViewCell.cellID)
        collectionView.backgroundColor = UIColor(hex: 0x6BB6A1)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        // 把myCollectioniew加到畫面裡
        view.addSubview(collectionView)
        // 自動調整關閉
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // CollectionView的限制
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 40),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20)
        ])
        // 初始畫面並無梗圖標示
        collectionView.isHidden = true
        // 初始字體顏色按鈕隱藏
        textColorButton.isHidden = true
        // 設定水平滑動的 scrollView
        view.addSubview(imageScrollView)
        NSLayoutConstraint.activate([
            imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -170),
            imageScrollView.heightAnchor.constraint(equalToConstant: 80) // 設定高度
        ])
        // 在 scrollView 內新增 imageView
        for (index, imageName) in picArray.enumerated() {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10  // 設置圓角半徑
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageScrollView.addSubview(imageView)
            // Add a UILabel for picName
            let label = UILabel()
            label.text = picName[index]
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(label)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 80), // 設定 imageView 寬度
                imageView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
                // Positioning the label within the imageView
                label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
            if index == 0 {
                imageView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor).isActive = true
            } else {
                imageView.leadingAnchor.constraint(equalTo: imageScrollView.subviews[index - 1].trailingAnchor, constant: 10).isActive = true // 加上一些間距
            }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            imageView.isUserInteractionEnabled = true
            imageView.tag = index
            // Add imageView to the array
            imageViews.append(imageView)
            // 設定 contentSize，確保可以左右滑動
            imageScrollView.contentSize = CGSize(width: CGFloat(picArray.count) * 90, height: 80)
            imageScrollView.isHidden = true
            rotateOutlet.isHidden = true
            doodleView.isUserInteractionEnabled = false
        }
        // 設定滑動按鈕
        let configuration = HoverConfiguration(image: UIImage(systemName: "trash.fill")?.withTintColor(UIColor(hex: 0x8B0000), renderingMode: .alwaysOriginal), color: .gradient(top: UIColor(hex: 0xD6D0AE), bottom: UIColor(hex: 0xDF6033)))
        let items = [
            HoverItem(title: "刪除文字", image: UIImage(systemName: "textformat")? .withConfiguration(UIImage.SymbolConfiguration(pointSize: 1, weight: .regular)), color: .gradient(top: .white, bottom: UIColor(hex: 0x6BB6A1))) { self.hoverRemoveText() },
            HoverItem(title: "刪除圖片及素材", image: UIImage(systemName: "photo.artframe"), color: .gradient(top: .white, bottom: UIColor(hex: 0xD6D0Ae))) { self.hoverRemoveImageView() },
            HoverItem(title: "刪除塗鴉", image: UIImage(systemName: "pencil.tip.crop.circle.fill"), color: .gradient(top: .white, bottom: UIColor(hex: 0xF5E68B))) { self.hoverRemoveDoodle()}
        ]
        let hoverView = HoverView(with: configuration, items: items)
        view.addSubview(hoverView)
        // 將hover移到最頂
        view.bringSubviewToFront(hoverView)
        hoverView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                hoverView.topAnchor.constraint(equalTo: view.topAnchor),
                hoverView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hoverView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        )
    }
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

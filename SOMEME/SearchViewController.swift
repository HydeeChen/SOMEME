//
//  SearchViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/22.
//

import UIKit
import Lottie

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var searchResult = [MemeLoadDatum]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResult.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as? SearchCollectionViewCell else {
            fatalError("Unable to dequeue EditingCollectionViewCell")
        }
        let item = searchResult[indexPath.row]
        cell.memeImage.kf.setImage(with: item.src)
        cell.update(meme: item)
        cell.delegate = self
        return cell
    }
    // 調整collectionView的大小
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150) // 調整 cell 大小
    }
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    //  點了會有放大圖的神奇功能
    var expandedImageView: UIImageView?
    // 設定collectionView
    var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // collectionView資料源設定
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SOMEME.SearchCollectionViewCell.self as AnyClass, forCellWithReuseIdentifier: SOMEME.SearchCollectionViewCell.cellID)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        // 把myCollectioniew加到畫面裡
        view.addSubview(collectionView)
        // 自動調整關閉
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // CollectionView的限制
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
    }
    // 點了放大
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = searchResult[indexPath.row]
        if let existingExpandedImageView = expandedImageView {
            existingExpandedImageView.removeFromSuperview()
            expandedImageView = nil
            return
        }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 350, height: 500))
        imageView.center = view.center
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: selectedItem.src)
        // Add tap gesture to remove the imageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeExpandedImageView))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        // Add the imageView to the view
        view.addSubview(imageView)
        // Set the expandedImageView property
        expandedImageView = imageView
    }
    @objc func removeExpandedImageView() {
        // Remove the expandedImageView when tapped
        expandedImageView?.removeFromSuperview()
        expandedImageView = nil
    }
    @IBAction func searchButton(_: Any) {
        view.endEditing(true)
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            // 處理空搜尋文字
            return
        }
        MemeService.searchMemesByHashtag(hashtag: searchText) { [weak self] memes in
            DispatchQueue.main.async {
                let animationView = LottieAnimationView()
                let animation = LottieAnimation.named("cat")
                animationView.animation = animation
                animationView.frame = CGRect(x: 20, y: 100, width: 400, height: 500)
                self?.view.addSubview(animationView)
                animationView.play()
                animationView.play(fromProgress: 0.0, toProgress: 1, loopMode: .none) { [weak self, weak animationView] (completed) in
                    if completed {
                        animationView?.removeFromSuperview()
                    }
                }
                if let memes = memes {
                    // 過濾包含指定 hashtag 關鍵字的結果
                    self?.searchResult = memes.filter { $0.hashtag.contains(searchText) }
                    self?.collectionView.reloadData()
                    self?.resultLabel.text = "找到\(self!.searchResult.count)個結果！"
                } else {
                    // 處理 API 請求錯誤
                    print("Error fetching memes")
                }
            }
        }
    }
}
extension SearchViewController: SearchCollectionViewCellDelegate {
    func SearchCollectionViewCell(_Cell: SearchCollectionViewCell, didPressShareButton Button: Any) {
        if let indexPath = collectionView.indexPath(for: _Cell) {
            let selectedItem = searchResult[indexPath.row]
            let renderer = UIGraphicsImageRenderer(size: _Cell.memeImage.bounds.size)
            let editedImage = renderer.image { _ in
                _Cell.memeImage.drawHierarchy(in: _Cell.memeImage.bounds, afterScreenUpdates: true)
            }
            let activityViewController = UIActivityViewController(activityItems: [editedImage], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }
    func SearchCollectionViewCell(_Cell: SearchCollectionViewCell, didPressEditButton Button: Any, withImage image: UIImage?) {
        let st = UIStoryboard(name: "Main", bundle: nil)
               let editVC = st.instantiateViewController(withIdentifier: "EditingViewController") as! EditingViewController
               // 傳遞圖片給 EditingViewController
               editVC.imageViewLoad = image
               // 設定全螢幕呈現模式
               editVC.modalPresentationStyle = .fullScreen
               self.present(editVC, animated: true)
    }    
    func SearchCollectionViewCell(_Cell: SearchCollectionViewCell, didPressLikeButton Button: Any) {
        // 將圖片轉換為 Data
            if let image = _Cell.memeImage.image, let imageData = image.jpegData(compressionQuality: 1.0) {
                // 生成一個唯一的名稱，可以使用 UUID
                let photoName = "EditedPhoto_" + UUID().uuidString
                // 將圖片名稱和圖片數據保存到 UserDefaults
                FavoritesManager.shared.addFavorite(photoName, imageData: imageData)
                // 顯示成功添加的提示
                showAlert(title: "成功", message: "已將照片添加到收藏夾")
            } else {
                // 處理圖片為空的情況
                showAlert(title: "錯誤", message: "無法將圖片轉換為數據")
            }
        // 提取的提示框處理函數
           func showAlert(title: String, message: String) {
               let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
               present(alert, animated: true, completion: nil)
           }
    }
    }

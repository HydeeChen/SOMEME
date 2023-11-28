//
//  MyCollectionViewController.swift
//  Pods
//
//  Created by Hydee Chen on 2023/11/20.
//

import UIKit
import Kingfisher

class MyCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditingCollectionViewCellDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return FavoritesManager.shared.favoritePhotos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as? MyCollectionViewCell else {
            fatalError("Unable to dequeue CollectionViewCell")
        }
        // 使用FavoritesManager的favoritePhotos來取得相片名稱陣列
        let photoNames = FavoritesManager.shared.favoritePhotos
        // 檢查索引是否在範圍內
        guard indexPath.item < photoNames.count else {
            // 處理索引超出範圍的情況，例如顯示預設圖片
            cell.memeImage.image = UIImage(named: "")
            cell.delegate = self
            return cell
        }
        let photoName = photoNames[indexPath.item]
        // Retrieve the image from FavoritesManager
        if let image = FavoritesManager.shared.getImage(for: photoName) {
            cell.memeImage.image = image
        } else {
            // Handle the case where the image is not available
            cell.memeImage.image = UIImage(named: "")
        }
        cell.delegate = self
        return cell
    }
    func didTapImage(imageView _: UIImageView) {
        //
    }
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 170) // 調整 cell 大小
    }
    @IBOutlet var shadowVIew: UIView!
    //  點了會有放大圖的神奇功能
    var expandedImageView: UIImageView?
    // 設定collectionview outlet
    var collectionView: UICollectionView!
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    // 點了會有放大圖的神奇功能
        func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // 檢查索引是否在範圍內
                guard indexPath.item < FavoritesManager.shared.favoritePhotos.count else {
                    return
                }

            let selectedItem = FavoritesManager.shared.favoritePhotos[indexPath.item]

            // Create a new imageView and set its image
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 350, height: 500))
            imageView.center = view.center
            imageView.contentMode = .scaleAspectFit

            if let image = FavoritesManager.shared.getImage(for: selectedItem) {
                imageView.image = image
            } else {
                // Handle the case where the image is not available
                imageView.image = UIImage(named: "")
            }

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
    override func viewDidLoad() {
        super.viewDidLoad()
        let layoutPersonal = UICollectionViewFlowLayout()
        layoutPersonal.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        layoutPersonal.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.scrollDirection = UICollectionView.ScrollDirection.vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutPersonal)
        
        // collectionView資料源設定
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SOMEME.MyCollectionViewCell.self as AnyClass, forCellWithReuseIdentifier: SOMEME.MyCollectionViewCell.cellID)
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        // 把myCollectioniew加到畫面裡
        view.addSubview(collectionView)
        
        // 自動調整關閉
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // CollectionView的限制
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 250),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
        ])
        
        // 設定背景陰影
        shadowVIew.layer.cornerRadius = CGFloat(30)
        shadowVIew.layer.shadowOpacity = Float(1)
        shadowVIew.layer.shadowRadius = CGFloat(15)
        shadowVIew.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
extension MyCollectionViewController: MyCollectionViewCellDelegate {
    func MyCollectionViewCell(_Cell: MyCollectionViewCell, didPressShareButton Button: Any) {
        if let indexPath = collectionView.indexPath(for: _Cell) {
            let selectedItem = FavoritesManager.shared.favoritePhotos[indexPath.row]
            let renderer = UIGraphicsImageRenderer(size: _Cell.memeImage.bounds.size)
            let editedImage = renderer.image { _ in
                _Cell.memeImage.drawHierarchy(in: _Cell.memeImage.bounds, afterScreenUpdates: true)
            }
            let activityViewController = UIActivityViewController(activityItems: [editedImage], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }

    func MyCollectionViewCell(_Cell: MyCollectionViewCell, didPressRemoveButton Button: Any) {
        if let indexPath = collectionView.indexPath(for: _Cell) {
                    let selectedItem = FavoritesManager.shared.favoritePhotos[indexPath.row]

                    // 建立一個確認刪除的提示框
                    let alertController = UIAlertController(title: "確認刪除", message: "確定要從收藏夾中刪除這張照片嗎？", preferredStyle: .alert)

                    // 增加確認按鈕
                    alertController.addAction(UIAlertAction(title: "確定", style: .destructive) { _ in
                        // 執行刪除邏輯
                        FavoritesManager.shared.removeFavorite(selectedItem)
                        // 重新載入 collectionView 數據
                        self.collectionView.reloadData()
                    })

                    // 增加取消按鈕
                    alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

                    // 顯示提示框
                    present(alertController, animated: true, completion: nil)
                }
    }
}

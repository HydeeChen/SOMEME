//
//  MyCollectionViewController.swift
//  Pods
//
//  Created by Hydee Chen on 2023/11/20.
//

import UIKit
import Kingfisher

class MyCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditingCollectionViewCellDelegate {
    var overlayView = UIView()
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
        return CGSize(width: 160, height: 160) // 調整 cell 大小
    }
    var shareButton: UIButton!
    var removeButton: UIButton!
    var EditButton: UIButton!
    var selectedCell: MyCollectionViewCell?
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
        selectedCell = collectionView.cellForItem(at: indexPath) as? MyCollectionViewCell
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
        overlayView.isHidden = false
        // 新增分享按鈕
        shareButton = UIButton(type: .system)
        shareButton.setTitle("分享", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = .color
        shareButton.layer.cornerRadius = 5
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        overlayView.addSubview(shareButton)
        // 新增編輯按鈕
        EditButton = UIButton(type: .system)
        EditButton.setTitle("編輯", for: .normal)
        EditButton.setTitleColor(.white, for: .normal)
        EditButton.backgroundColor = .color
        EditButton.layer.cornerRadius = 5
        EditButton.addTarget(self, action: #selector(EditButtonTapped), for: .touchUpInside)
        overlayView.addSubview(EditButton)
        // 新增移除收藏按鈕
        removeButton = UIButton(type: .system)
        removeButton.setTitle("刪除", for: .normal)
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.backgroundColor = .color
        removeButton.layer.cornerRadius = 5
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        overlayView.addSubview(removeButton)
        // 設定按鈕的 constraints
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        EditButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 20),
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            shareButton.widthAnchor.constraint(equalToConstant: 60), // 設定寬度
            shareButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度
            EditButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 10),
            EditButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            EditButton.widthAnchor.constraint(equalToConstant: 60), // 設定寬度
            EditButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度
            removeButton.leadingAnchor.constraint(equalTo: EditButton.trailingAnchor, constant: 10),
            removeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            removeButton.widthAnchor.constraint(equalToConstant: 60), // 設定寬度
            removeButton.heightAnchor.constraint(equalToConstant: 30) // 設定高度
        ])
    }
    @objc func shareButtonTapped() {
        // Ensure the expandedImageView has a valid size
           guard let expandedImageView = expandedImageView else {
               return
           }
           // Capture the image from the expandedImageView with its actual size
           let editedImage = UIGraphicsImageRenderer(size: expandedImageView.bounds.size).image { _ in
               // Draw the expandedImageView's image directly
               expandedImageView.image?.draw(in: expandedImageView.bounds)
           }
           let activityViewController = UIActivityViewController(activityItems: [editedImage], applicationActivities: nil)
           present(activityViewController, animated: true, completion: nil)
    }
    @objc func EditButtonTapped() {
        guard let image = expandedImageView?.image else {
               return
           }
           let st = UIStoryboard(name: "Main", bundle: nil)
           let editVC = st.instantiateViewController(withIdentifier: "EditingViewController") as! EditingViewController
           // 傳遞圖片給 EditingViewController
           editVC.imageViewLoad = image
           // 設定全螢幕呈現模式
           editVC.modalPresentationStyle = .fullScreen
           self.present(editVC, animated: true)
    }
    @objc func removeButtonTapped() {
        if let indexPath = collectionView.indexPath(for: selectedCell!) {
               let selectedItem = FavoritesManager.shared.favoritePhotos[indexPath.row]
                // 建立一個確認刪除的提示框
                let alertController = UIAlertController(title: "確認刪除", message: "確定要從收藏夾中刪除這張照片嗎？", preferredStyle: .alert)
                // 增加確認按鈕
                alertController.addAction(UIAlertAction(title: "確定", style: .destructive) { _ in
                    // 執行刪除邏輯
                    FavoritesManager.shared.removeFavorite(selectedItem)
                    // 重新載入 collectionView 數據
                    self.collectionView.reloadData()
                    self.removeExpandedImageView()
                })
                // 增加取消按鈕
                alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                // 顯示提示框
                present(alertController, animated: true, completion: nil)
            }
       
    }
    @objc func removeExpandedImageView() {
        // Remove the expandedImageView when tapped
        expandedImageView?.removeFromSuperview()
        expandedImageView = nil
        overlayView.isHidden = true
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
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        // 設定背景陰影
        shadowVIew.layer.cornerRadius = CGFloat(30)
        shadowVIew.layer.shadowOpacity = Float(1)
        shadowVIew.layer.shadowRadius = CGFloat(15)
        shadowVIew.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // 黑色底平常為隱藏
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.9
        overlayView.isHidden = true
        view.addSubview(overlayView)
    }
}

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
        return cell
    }
    // 調整collectionView的大小
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 175, height: 175) // 調整 cell 大小
    }
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    // 黑色背景
    var overlayView = UIView()
    //  點了會有放大圖的神奇功能
    var expandedImageView: UIImageView?
    // 設定collectionView
    var collectionView: UICollectionView!
    var shareButton: UIButton!
    var EditButton: UIButton!
    var likeButton: UIButton!
    var selectedCell: MyCollectionViewCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // collectionView資料源設定
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SOMEME.SearchCollectionViewCell.self as AnyClass, forCellWithReuseIdentifier: SOMEME.SearchCollectionViewCell.cellID)
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
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 170),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
        // 黑色底平常為隱藏
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.9
        overlayView.isHidden = true
        view.addSubview(overlayView)
        // 新增分享按鈕
        shareButton = UIButton(type: .system)
        shareButton.setTitle("share", for: .normal)
        shareButton.titleLabel?.font = UIFont(name: "chalkduster", size: 16)
        shareButton.setTitleColor(.systemTeal, for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .systemTeal
        shareButton.backgroundColor = .color3
        shareButton.layer.cornerRadius = 40
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        overlayView.addSubview(shareButton)
        // 新增編輯按鈕
        EditButton = UIButton(type: .system)
        EditButton.setTitle("edit", for: .normal)
        EditButton.titleLabel?.font = UIFont(name: "chalkduster", size: 16)
        EditButton.setImage(UIImage(systemName: "pencil.and.scribble"), for: .normal)
        EditButton.tintColor = .systemTeal
        EditButton.setTitleColor(.systemTeal, for: .normal)
        EditButton.backgroundColor = .color3
        EditButton.layer.cornerRadius = 40
        EditButton.addTarget(self, action: #selector(EditButtonTapped), for: .touchUpInside)
        overlayView.addSubview(EditButton)
        // 新增收藏按鈕
        likeButton = UIButton(type: .system)
        likeButton.setTitle("add", for: .normal)
        likeButton.titleLabel?.font = UIFont(name: "chalkduster", size: 16)
        likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        likeButton.tintColor = .systemTeal
        likeButton.setTitleColor(.systemTeal, for: .normal)
        likeButton.backgroundColor = .color3
        likeButton.layer.cornerRadius = 40
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        overlayView.addSubview(likeButton)
        // 設定按鈕的 constraints
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        EditButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 20),
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            shareButton.widthAnchor.constraint(equalToConstant: 80), // 設定寬度
            shareButton.heightAnchor.constraint(equalToConstant: 80), // 設定高度
            EditButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 10),
            EditButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            EditButton.widthAnchor.constraint(equalToConstant: 80), // 設定寬度
            EditButton.heightAnchor.constraint(equalToConstant: 80), // 設定高度
            likeButton.leadingAnchor.constraint(equalTo: EditButton.trailingAnchor, constant: 10),
            likeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            likeButton.widthAnchor.constraint(equalToConstant: 80), // 設定寬度
            likeButton.heightAnchor.constraint(equalToConstant: 80) // 設定高度
        ])
    }
    @objc func likeButtonTapped() {
        // 確認 expandedImageView 不為 nil
        guard let expandedImageView = expandedImageView else {
            return
        }
        // 檢查 expandedImageView 是否為 UIImageView 對象
        if let image = expandedImageView.image, let imageData = image.jpegData(compressionQuality: 1.0) {
            // 生成一個唯一的名稱，可以使用 UUID
            let photoName = "EditedPhoto_" + UUID().uuidString
            // 將圖片名稱和圖片數據保存到 UserDefaults
            FavoritesManager.shared.addFavorite(photoName, imageData: imageData)
            // 新增收藏動畫
            let starAnimationView = LottieAnimationView()
            let starAnimation = LottieAnimation.named("star")
            starAnimationView.animation = starAnimation
            starAnimationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            starAnimationView.center = view.center
            view.addSubview(starAnimationView)
            starAnimationView.play()
            starAnimationView.play(fromProgress: 0.0, toProgress: 1.0, loopMode: .none) { (completed) in
                if completed {
                    starAnimationView.removeFromSuperview()
                }
            }
        }
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
    // 點了放大
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        overlayView.isHidden = false
        selectedCell = collectionView.cellForItem(at: indexPath) as? MyCollectionViewCell
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
        overlayView.isHidden = true
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


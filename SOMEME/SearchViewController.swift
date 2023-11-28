//
//  SearchViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/22.
//

import UIKit

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
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            // 處理空搜尋文字
            return
        }
        
        MemeService.searchMemesByHashtag(hashtag: searchText) { [weak self] memes in
            DispatchQueue.main.async {
                if let memes = memes {
                    // 過濾包含指定 hashtag 關鍵字的結果
                    self?.searchResult = memes.filter { $0.hashtag.contains(searchText) }
                    self?.collectionView.reloadData()
                    self?.resultLabel.text = "找到\(self!.searchResult.count)個結果！"
                    self?.view.endEditing(true)
                } else {
                    // 處理 API 請求錯誤
                    print("Error fetching memes")
                }
            }
        }
    }
}

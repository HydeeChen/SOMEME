//
//  SearchCollectionViewCell.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/27.
//

import UIKit
import Kingfisher

class SearchCollectionViewCell: UICollectionViewCell {
    static let cellID: String = "SearchCollectionViewCell"
    var memeImage: UIImageView!
    var shareButton: UIButton!
    var EditButton: UIButton!
    var likeButton: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func configure() {
        // 初始化 imageView
        memeImage = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width*0.7, height: contentView.frame.height*0.5))
        memeImage.center = CGPoint(x: contentView.center.x, y: contentView.frame.height / 2)
        memeImage.contentMode = .scaleAspectFit
        contentView.addSubview(memeImage)
        // 新增分享按鈕
        shareButton = UIButton(type: .system)
        shareButton.setTitle("分享", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = .red
        shareButton.layer.cornerRadius = 5
//        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        contentView.addSubview(shareButton)
        // 新增編輯按鈕
        EditButton = UIButton(type: .system)
        EditButton.setTitle("編輯", for: .normal)
        EditButton.setTitleColor(.white, for: .normal)
        EditButton.backgroundColor = .red
        EditButton.layer.cornerRadius = 5
//        EditButton.addTarget(self, action: #selector(EditButtonTapped), for: .touchUpInside)
        contentView.addSubview(EditButton)
        // 新增收藏按鈕
        likeButton = UIButton(type: .system)
        likeButton.setTitle("收藏", for: .normal)
        likeButton.setTitleColor(.white, for: .normal)
        likeButton.backgroundColor = .red
        likeButton.layer.cornerRadius = 5
//        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        contentView.addSubview(likeButton)
        // 設定按鈕的 constraints
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        EditButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            shareButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            shareButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度
            EditButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 5),
            EditButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            EditButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            EditButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度
            likeButton.leadingAnchor.constraint(equalTo: EditButton.trailingAnchor, constant: 5),
            likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            likeButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            likeButton.heightAnchor.constraint(equalToConstant: 30) // 設定高度
        ])
    }

    func update(meme: MemeLoadDatum) {
        memeImage.kf.setImage(with: meme.src)
    }
}
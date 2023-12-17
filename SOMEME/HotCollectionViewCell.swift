//
//  HotCollectionViewCell.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/21.
//

import UIKit

// 設定cell的protocal
protocol HotCollectionViewCellDelegate: AnyObject {
    func HotCollectionViewCell(_Cell: HotCollectionViewCell, didPressShareButton Button: Any)
    func HotCollectionViewCell(_Cell: HotCollectionViewCell, didPressEditButton Button: Any, withImage image: UIImage?)
    func HotCollectionViewCell(_Cell: HotCollectionViewCell, didPressLikeButton Button: Any)
}

class HotCollectionViewCell: UICollectionViewCell {
    static let cellID: String = "HotCollectionViewCell"
    var memeImage: UIImageView!
    var frameImage: UIImageView!
    var shareButton: UIButton!
    var EditButton: UIButton!
    var likeButton: UIButton!
    weak var delegate: HotCollectionViewCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure() {
        // 初始化 imageView
        memeImage = UIImageView(frame: CGRect(x: 75, y: 35, width: 230, height: 230))
        memeImage.layer.cornerRadius = 15
        memeImage.layer.masksToBounds = true
        memeImage.contentMode = .scaleAspectFill
        contentView.addSubview(memeImage)
        // 新增邊框imageView
        frameImage = UIImageView(frame: CGRect(x: 40, y: 0, width: 300, height: 290))
        frameImage.image = UIImage(named: "frame3")
        frameImage.contentMode = .scaleToFill
        contentView.addSubview(frameImage)
        // 新增分享按鈕
        shareButton = UIButton(type: .system)
        shareButton.setTitle("", for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .color
        shareButton.setTitleColor(.color, for: .normal)
        shareButton.backgroundColor = .color1
        shareButton.layer.cornerRadius = 20
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        contentView.addSubview(shareButton)
        // 新增編輯按鈕
        EditButton = UIButton(type: .system)
        EditButton.setTitle("", for: .normal)
        EditButton.setImage(UIImage(systemName: "pencil.and.scribble"), for: .normal)
        EditButton.tintColor = .color
        EditButton.setTitleColor(.color, for: .normal)
        EditButton.backgroundColor = .color1
        EditButton.layer.cornerRadius = 20
        EditButton.addTarget(self, action: #selector(EditButtonTapped), for: .touchUpInside)
        contentView.addSubview(EditButton)
        // 新增收藏按鈕
        likeButton = UIButton(type: .system)
        likeButton.setTitle("", for: .normal)
        likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        likeButton.setTitleColor(.white, for: .normal)
        likeButton.backgroundColor = .color1
        likeButton.tintColor = .color
        likeButton.layer.cornerRadius = 20
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        contentView.addSubview(likeButton)
        // 設定按鈕的 constraints
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        EditButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            shareButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 90),
            shareButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            shareButton.heightAnchor.constraint(equalToConstant: 40), // 設定高度
            EditButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            EditButton.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 5),
            EditButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            EditButton.heightAnchor.constraint(equalToConstant: 40), // 設定高度
            likeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            likeButton.topAnchor.constraint(equalTo: EditButton.bottomAnchor, constant: 5),
            likeButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            likeButton.heightAnchor.constraint(equalToConstant: 40) // 設定高度
        ])
    }

    func update(meme: MemeLoadDatum) {
        memeImage.kf.setImage(with: meme.src)
    }

    @objc func shareButtonTapped() {
        delegate?.HotCollectionViewCell(_Cell: self, didPressShareButton: shareButton ?? "")
    }
    @objc func EditButtonTapped() {
        delegate?.HotCollectionViewCell(_Cell: self, didPressEditButton: shareButton ?? "", withImage: memeImage.image)
    }
    @objc func likeButtonTapped() {
        delegate?.HotCollectionViewCell(_Cell: self, didPressLikeButton: shareButton ?? "")
    }
}

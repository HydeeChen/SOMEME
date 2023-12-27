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
        shareButton = createButton(imageName: "square.and.arrow.up", action: #selector(shareButtonTapped))
        // 新增編輯按鈕
        EditButton = createButton(imageName: "pencil.and.scribble", action: #selector(EditButtonTapped))
        // 新增收藏按鈕
        likeButton = createButton(imageName: "star.fill", action: #selector(likeButtonTapped))
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
    func createButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.setTitle("", for: .normal)
        button.tintColor = .color
        button.setTitleColor(.color, for: .normal)
        button.backgroundColor = .color1
        button.layer.cornerRadius = 20
        button.addTarget(self, action: action, for: .touchUpInside)
        contentView.addSubview(button)
        return button
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

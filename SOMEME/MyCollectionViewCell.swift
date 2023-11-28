//
//  MyCollectionViewCell.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/20.
//

import UIKit

protocol MyCollectionViewCellDelegate: AnyObject {
    func MyCollectionViewCell(_Cell: MyCollectionViewCell, didPressShareButton Button: Any)
    func MyCollectionViewCell(_Cell: MyCollectionViewCell, didPressRemoveButton Button: Any)
}
class MyCollectionViewCell: UICollectionViewCell {
    static let cellID: String = "MyCollectionViewCell"
    var memeImage: UIImageView!
    var shareButton: UIButton!
    var removeButton: UIButton!
    weak var delegate: MyCollectionViewController?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure() {
        // 初始化 imageView
        memeImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        memeImage.center = CGPoint(x: contentView.center.x, y: contentView.frame.height / 2)
        memeImage.contentMode = .scaleToFill
        contentView.addSubview(memeImage)
        // 新增分享按鈕
        shareButton = UIButton(type: .system)
        shareButton.setTitle("分享", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = .red
        shareButton.layer.cornerRadius = 5
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        contentView.addSubview(shareButton)
        // 新增移除收藏按鈕
        removeButton = UIButton(type: .system)
        removeButton.setTitle("移除", for: .normal)
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.backgroundColor = .red
        removeButton.layer.cornerRadius = 5
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        contentView.addSubview(removeButton)
        // 設定按鈕的 constraints
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            shareButton.widthAnchor.constraint(equalToConstant: 60), // 設定寬度
            shareButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度
            removeButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 5),
            removeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            removeButton.widthAnchor.constraint(equalToConstant: 60), // 設定寬度
            removeButton.heightAnchor.constraint(equalToConstant: 30) // 設定高度
        ])
    }
    @objc func shareButtonTapped() {
        delegate?.MyCollectionViewCell(_Cell: self, didPressShareButton: shareButton )
    }
    @objc func removeButtonTapped() {
        delegate?.MyCollectionViewCell(_Cell: self, didPressRemoveButton: removeButton)
    }
}

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
    func MyCollectionViewCell(_Cell: MyCollectionViewCell, didPressEditButton Button: UIButton, withImage image: UIImage?)
}
class MyCollectionViewCell: UICollectionViewCell {
    static let cellID: String = "MyCollectionViewCell"
    var memeImage: UIImageView!
    var shareButton: UIButton!
    var removeButton: UIButton!
    var EditButton: UIButton!
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
        shareButton.setTitle("", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        let iconImage = UIImage(systemName: "square.and.arrow.up.fill")?.withTintColor(UIColor(hex: 0xCA0D1F))
        shareButton.imageView?.alpha = 0.5
        shareButton.setImage(iconImage, for: .normal)
        shareButton.backgroundColor = .clear
//        shareButton.layer.cornerRadius = 5
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
//        shareButton.titleLabel?.font = UIFont(name: "Mamelon", size: 13)
        shareButton.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        contentView.addSubview(shareButton)
        // 新增編輯按鈕
        EditButton = UIButton(type: .system)
        EditButton.setTitle("", for: .normal)
        EditButton.setTitleColor(.white, for: .normal)
        let iconImage2 = UIImage(systemName: "pencil.circle.fill")?.withTintColor(UIColor(hex: 0xCA0D1F))
        EditButton.imageView?.alpha = 0.5
        EditButton.setImage(iconImage2, for: .normal)
        EditButton.backgroundColor = .clear
        EditButton.layer.cornerRadius = 5
        EditButton.addTarget(self, action: #selector(EditButtonTapped), for: .touchUpInside)
//        EditButton.titleLabel?.font = UIFont(name: "Mamelon", size: 16)
        contentView.addSubview(EditButton)
        // 新增移除收藏按鈕
        removeButton = UIButton(type: .system)
        removeButton.setTitle("", for: .normal)
        removeButton.setTitleColor(.white, for: .normal)
        let iconImage3 = UIImage(systemName: "trash.fill")?.withTintColor(UIColor(hex: 0xCA0D1F))
        removeButton.setImage(iconImage3, for: .normal)
        removeButton.backgroundColor = .clear
        removeButton.layer.cornerRadius = 5
        removeButton.imageView?.alpha = 0.5
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
//        removeButton.titleLabel?.font = UIFont(name: "Mamelon", size: 16)
        contentView.addSubview(removeButton)
        // 設定按鈕的 constraints
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        EditButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            shareButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            shareButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度
            EditButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 5),
            EditButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            EditButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            EditButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度
            removeButton.leadingAnchor.constraint(equalTo: EditButton.trailingAnchor, constant: 5),
            removeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            removeButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            removeButton.heightAnchor.constraint(equalToConstant: 30) // 設定高度
        ])
    }
    @objc func shareButtonTapped() {
        delegate?.MyCollectionViewCell(_Cell: self, didPressShareButton: shareButton )
    }
    @objc func EditButtonTapped() {
        delegate?.MyCollectionViewCell(_Cell: self, didPressEditButton: EditButton, withImage: memeImage.image)
    }
    @objc func removeButtonTapped() {
        delegate?.MyCollectionViewCell(_Cell: self, didPressRemoveButton: removeButton)
    }
}
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

//
//  SearchCollectionViewCell.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/27.
//

import UIKit
import Kingfisher

// 設定cell的protocal
protocol SearchCollectionViewCellDelegate: AnyObject {
    func SearchCollectionViewCell(_Cell: SearchCollectionViewCell, didPressShareButton Button: Any)
    func SearchCollectionViewCell(_Cell: SearchCollectionViewCell, didPressEditButton Button: Any, withImage image: UIImage?)
    func SearchCollectionViewCell(_Cell: SearchCollectionViewCell, didPressLikeButton Button: Any)
}
class SearchCollectionViewCell: UICollectionViewCell {
    static let cellID: String = "SearchCollectionViewCell"
    var memeImage: UIImageView!
    var frameImage: UIImageView!
    var moreImage: UIImageView!
    weak var delegate: SearchCollectionViewCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func configure() {
        // 初始化 imageView
        memeImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 140))
        memeImage.center = CGPoint(x: contentView.center.x, y: contentView.frame.height / 2)
        memeImage.contentMode = .scaleToFill
        memeImage.layer.cornerRadius = 20
        memeImage.layer.masksToBounds = true
        contentView.addSubview(memeImage)
        // 新增frame
        frameImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 180))
        frameImage.image = UIImage(named: "frame2")
        frameImage.center = CGPoint(x: contentView.center.x, y: contentView.frame.height / 2)
        frameImage.contentMode = .scaleToFill
        contentView.addSubview(frameImage)
        // 新增more的標誌
        moreImage =  UIImageView(frame: CGRect(x: 130, y: 20, width: 20, height: 20))
        moreImage.image = UIImage(named: "more")
        contentView.addSubview(moreImage)
    }
    func update(meme: MemeLoadDatum) {
        memeImage.kf.setImage(with: meme.src)
    }
    @objc func shareButtonTapped() {
//        delegate?.SearchCollectionViewCell(_Cell: self, didPressShareButton: shareButton ?? "")
    }
    @objc func EditButtonTapped() {
//        delegate?.SearchCollectionViewCell(_Cell: self, didPressEditButton: EditButton, withImage: memeImage.image)
    }
    @objc func likeButtonTapped() {
//        delegate?.SearchCollectionViewCell(_Cell: self, didPressLikeButton: likeButton ?? "")
    }
}

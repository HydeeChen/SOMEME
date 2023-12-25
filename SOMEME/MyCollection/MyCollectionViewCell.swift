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
    var frameImage: UIImageView!
    var moreImage: UIImageView!
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
        moreImage =  UIImageView(frame: CGRect(x: 120, y: 20, width: 20, height: 20))
        moreImage.image = UIImage(named: "more")
        contentView.addSubview(moreImage)
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

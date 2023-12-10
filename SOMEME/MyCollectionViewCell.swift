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
        contentView.addSubview(memeImage)

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

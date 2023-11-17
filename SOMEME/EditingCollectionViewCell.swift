//
//  EditingCollectionViewCell.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/16.
//

import UIKit

protocol EditingCollectionViewCellDelegate: AnyObject {
    func didTapImage(image: UIImage)
}
class EditingCollectionViewCell: UICollectionViewCell {
    static let cellID: String = "EditingCollectionViewCell"
    var memeImage: UIImageView!
    weak var delegate: EditingCollectionViewCellDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
//        新增手勢觸發動作
        addGestureRecognizer()
    }
    
    func addGestureRecognizer() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
            memeImage.isUserInteractionEnabled = true
            memeImage.addGestureRecognizer(tapGesture)
        }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        if let image = memeImage.image {
                  delegate?.didTapImage(image: image)
              }
        }
    
    func configure(){
        // 初始化 imageView
        memeImage = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height))
            memeImage.contentMode = .scaleToFill
            contentView.addSubview(memeImage)
                    
    }
    
    func update(meme: MemeLoadDatum) {
        memeImage.kf.setImage(with: meme.src)
    }
}

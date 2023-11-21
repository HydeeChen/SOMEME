//
//  HotCollectionViewCell.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/21.
//

import UIKit

class HotCollectionViewCell: UICollectionViewCell {
    static let cellID: String = "HotCollectionViewCell"
    var memeImage: UIImageView!
    var shareButton: UIButton!
    var removeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(){
        // 初始化 imageView
        memeImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 220, height: 220))
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
        
        // 新增移除收藏按鈕
        removeButton = UIButton(type: .system)
        removeButton.setTitle("編輯", for: .normal)
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.backgroundColor = .red
        removeButton.layer.cornerRadius = 5
//        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        contentView.addSubview(removeButton)
        
        // 設定按鈕的 constraints
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
               shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 90),
               shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
               shareButton.widthAnchor.constraint(equalToConstant: 60), // 設定寬度
               shareButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度

               removeButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 5),
               removeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
               removeButton.widthAnchor.constraint(equalToConstant: 60), // 設定寬度
               removeButton.heightAnchor.constraint(equalToConstant: 30), // 設定高度
           ])
    }
    
    func update(meme: MemeLoadDatum) {
        memeImage.kf.setImage(with: meme.src)
    }
}

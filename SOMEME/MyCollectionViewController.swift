//
//  MyCollectionViewController.swift
//  Pods
//
//  Created by Hydee Chen on 2023/11/20.
//

import UIKit

class MyCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditingCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as? MyCollectionViewCell else {
            fatalError("Unable to dequeue CollectionViewCell")
        }
        cell.delegate = self
        cell.memeImage.image = UIImage(named: mockData[indexPath.row])
        return cell
    }
    
    func didTapImage(imageView: UIImageView) {
        //
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 170) // 調整 cell 大小
    }
    
    //設定假資料
    var mockData = ["duck", "duck", "duck", "duck", "duck"]
    
    
    @IBOutlet weak var shadowVIew: UIView!
    
    //設定collectionview outlet
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layoutPersonal: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutPersonal.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        layoutPersonal.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.scrollDirection = UICollectionView.ScrollDirection.vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutPersonal)
        
        //collectionView資料源設定
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.cellID)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        //把myCollectioniew加到畫面裡
        self.view.addSubview(collectionView)
        
        //自動調整關閉
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        //CollectionView的限制
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 250),
            collectionView.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
        
        //設定背景陰影
        shadowVIew.layer.cornerRadius = CGFloat(30)
        shadowVIew.layer.shadowOpacity = Float(1)
        shadowVIew.layer.shadowRadius = CGFloat(15)
        shadowVIew.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
}

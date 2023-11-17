//
//  EditingViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/16.
//

import UIKit
import Kingfisher

class EditingViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditingCollectionViewCellDelegate, UIGestureRecognizerDelegate{
    
    func didTapImage(image: UIImage) {
        addLayerToImageView(image: image)
    }
    //設置存放圖層的array
    var addedLayers: [CALayer] = []
    
    // 設定接前頁傳值資料
    var imageViewLoad: UIImage?
    
    //追蹤圖層
    var selectedLayer: CALayer?
    
    //設定本頁顯示圖片outlet
    @IBOutlet weak var photoImageView: UIImageView!
    var collectionView: UICollectionView!
    
    //設定假資料顯示內容
    //    var mockData = ["duck", "duck", "duck", "duck", "duck", "duck", "duck", "duck", "duck", "duck"]
    var items = [MemeLoadDatum]() // 儲存從api取得銷售品資料
    
    //新增打叉view
    var deleteImageView: UIImageView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    // 設定collectionView內容的來源
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditingCollectionViewCell", for: indexPath) as? EditingCollectionViewCell else {
            fatalError("Unable to dequeue EditingCollectionViewCell")
        }
        let item = items[indexPath.row]
        cell.delegate = self
        cell.memeImage.kf.setImage(with: item.src)
        cell.update(meme: item)
        return cell
    }
    // 調整collectionView的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100) // 調整 cell 大小
    }
    
    //    設定viewDidLoad的功能
    override func viewDidLoad() {
        super.viewDidLoad()
        //設定顯示傳值過來的圖片
        photoImageView.image = imageViewLoad
        
        //梗圖collectionView設定
        let layoutPersonal: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutPersonal.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        layoutPersonal.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.scrollDirection = UICollectionView.ScrollDirection.vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutPersonal)
        
        //collectionView資料源設定
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(EditingCollectionViewCell.self, forCellWithReuseIdentifier: EditingCollectionViewCell.cellID)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        //把myCollectioniew加到畫面裡
        self.view.addSubview(collectionView)
        
        //自動調整關閉
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        //CollectionView的限制
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo:  photoImageView.bottomAnchor, constant: 30),
            collectionView.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor, constant: 20)
        ])
        
        //初始畫面並無梗圖標示
        collectionView.isHidden = true
        
        //設定手勢功能
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(pinchGesture)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 不允許同時識別多手勢
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //防止與其他手勢衝突
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer
    }
    
    func bringLayerToFront() {
        guard let selectedLayer = selectedLayer else { return }
        // 移動到最上層
        selectedLayer.removeFromSuperlayer() // 先將圖層移除
        photoImageView.layer.addSublayer(selectedLayer) // 再將圖層加回去，即可置於最上層
    }

    
    //調整位置
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let selectedLayer = selectedLayer else { return }
        let translation = sender.translation(in: photoImageView)
        let newPositionX = selectedLayer.position.x + translation.x
        let newPositionY = selectedLayer.position.y + translation.y
        let minX = selectedLayer.bounds.width / 2
        let maxX = photoImageView.bounds.width - minX
        let minY = selectedLayer.bounds.height / 2
        let maxY = photoImageView.bounds.height - minY
        selectedLayer.position.x = min(maxX, max(minX, newPositionX))
        selectedLayer.position.y = min(maxY, max(minY, newPositionY))
        sender.setTranslation(.zero, in: photoImageView)
        
    }
    
    //調整大小
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let selectedLayer = selectedLayer else { return }
        let scale = sender.scale
        var currentTransform = selectedLayer.transform
        currentTransform = CATransform3DScale(currentTransform, scale, scale, 1.0)
        selectedLayer.transform = currentTransform
        sender.scale = 1.0
    }
    
    func loadMemeData() {
        // 設定 API 的 URL
        let url = URL(string: "https://memes.tw/wtf/api?contest=33")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // 發送 API 請求
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Error API: \(String(describing: error))")
            if let data,
               let content = String(data: data, encoding: .utf8) {
                // 解碼 JSON 格式的資料
                //                print(content)
                let decoder = JSONDecoder()
                do {
                    let  memes = try decoder.decode([MemeLoadDatum].self, from: data)
                    // 將取得的飲料資料存入 items 陣列
                    self.items = memes
                    self.updateCollectionView() //成功就更新collectionView
                } catch {
                    print("Error decoding JSON: \(error)")
                }
                
            }
            // 開始 API 請求
        }.resume()
    }
    
    func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func addMeme(_ sender: Any) {
        collectionView.isHidden = false
        loadMemeData()
        updateCollectionView()
        
    }
    
    //    新增圖層的行為
    func addLayerToImageView(image: UIImage) {
        let newLayer = CALayer()
            newLayer.contents = image.cgImage
            newLayer.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
            newLayer.position = CGPoint(x: photoImageView.bounds.midX, y: photoImageView.bounds.midY)
            photoImageView.layer.addSublayer(newLayer)
            addedLayers.append(newLayer)

            // 新增 deleteImageView
            let deleteImageViewForLayer = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
            deleteImageViewForLayer.tintColor = UIColor.red
            deleteImageViewForLayer.isUserInteractionEnabled = true

            // 設定 tap 手勢
            let deleteTapGestureForLayer = UITapGestureRecognizer(target: self, action: #selector(deleteLayer))
            deleteImageViewForLayer.addGestureRecognizer(deleteTapGestureForLayer)

            // 加到 newLayer 上的 photoImageView 上
            photoImageView.addSubview(deleteImageViewForLayer)

            // 設定 deleteImageView 位置
            deleteImageViewForLayer.translatesAutoresizingMaskIntoConstraints = false
            
            let topConstraint = deleteImageViewForLayer.topAnchor.constraint(
                equalTo: photoImageView.topAnchor,
                constant: newLayer.position.y - newLayer.bounds.height / 2 - 8
            )
            
            let trailingConstraint = deleteImageViewForLayer.trailingAnchor.constraint(
                equalTo: photoImageView.leadingAnchor,
                constant: newLayer.position.x + newLayer.bounds.width / 2 + 8
            )
            
            let widthConstraint = deleteImageViewForLayer.widthAnchor.constraint(equalToConstant: 30)
            let heightConstraint = deleteImageViewForLayer.heightAnchor.constraint(equalToConstant: 30)

            NSLayoutConstraint.activate([
                topConstraint,
                trailingConstraint,
                widthConstraint,
                heightConstraint
            ])

            //選定新增的圖層
            selectedLayer = newLayer
    }
    @objc func deleteLayer() {
        guard let selectedLayer = selectedLayer else { return }

        // 從 addedLayers 中移除選定的圖層
        if let index = addedLayers.firstIndex(of: selectedLayer) {
            addedLayers.remove(at: index)
        }

        // 移除圖層
        selectedLayer.removeFromSuperlayer()

        // 清空 selectedLayer
        self.selectedLayer = nil
    }
}

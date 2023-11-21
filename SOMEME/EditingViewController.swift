//
//  EditingViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/16.
//

import UIKit
import Kingfisher

class EditingViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditingCollectionViewCellDelegate, UIGestureRecognizerDelegate, UIColorPickerViewControllerDelegate{
    func didTapImage(imageView: UIImageView) {
        addImageViewToImageView(imageView: imageView)
    }
    
    var selectedTextView: UITextView?
    
    var textView: UITextView?
    
    // 新增存放UIImageView的array
    var addedImageViews: [UIImageView] = []
    
    // 新增存放UIImageView的array
    var addedTextLabel: [UILabel] = []
    //新增存放uitextview的array
    var addedTextViews: [UITextView] = []
    
    
    // 設定接前頁傳值資料
    var imageViewLoad: UIImage?
    
    // 追蹤圖層
    var selectedImageView: UIImageView?
    
    //追蹤label
    var selectedLabel: UILabel?
    
    //新增view把photoImage包起來
    @IBOutlet weak var photoView: UIView!
    
    //設定本頁顯示圖片outlet
    @IBOutlet weak var photoImageView: UIImageView!
    
    var collectionView: UICollectionView!
    
    //設定假資料顯示內容
    var textData = ["恐龍扛狼", "要確欸", "哇酷哇酷", "芭比 Q 了", "注意看，這個男人太狠了", "我沒了", "UCCU", "歸剛欸", "YYDS", "萊納，你坐啊！"]
    var items = [MemeLoadDatum]() // 儲存從api取得銷售品資料
    
    //文字顏色按鈕
    @IBOutlet weak var textColorButton: UIButton!
    
    //collectionView欄位設定
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
    
    //設定viewDidLoad的功能
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
        
        //設定圖片手勢功能
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        rotationGesture.delegate = self
        
        photoView.addGestureRecognizer(rotationGesture)
        photoView.addGestureRecognizer(panGesture)
        photoView.addGestureRecognizer(pinchGesture)
        
        // 設定 label 手勢功能
        let labelPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLabelPanGesture(_:)))
        labelPanGesture.delegate = self
        let labelPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleLabelPinchGesture(_:)))
        labelPinchGesture.delegate = self
        let labelRotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleLabelRotationGesture(_:)))
        labelRotationGesture.delegate = self
        
        //點一下進行編輯、點旁邊一下結束編輯
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 1
        doubleTapGesture.delegate = self
        
        photoView.addGestureRecognizer(labelRotationGesture)
        photoView.addGestureRecognizer(labelPanGesture)
        photoView.addGestureRecognizer(labelPinchGesture)
        photoView.addGestureRecognizer(doubleTapGesture)
        
        
        //初始字體顏色按鈕隱藏
        textColorButton.isHidden = true
        
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: photoImageView)
            
            // 檢查是否點擊在 label 上
            for label in addedTextLabel {
                if label.frame.contains(location) {
                    // 進行文字編輯
                    startEditing(label: label)
                    return
                }
            }
            // 若點擊在 label 以外的地方，結束編輯
            endEditing()
        }
    }
    
    // 開始文字編輯
    func startEditing(label: UILabel) {
        // 建立一個 UITextView 並放置在與 label 相同位置
        let textView = UITextView(frame: label.frame)
        textView.text = label.text
        textView.textAlignment = label.textAlignment
        textView.textColor = label.textColor
        textView.font = label.font
        textView.backgroundColor = .clear
        
        // 將 UITextView 添加到畫面中
        photoImageView.addSubview(textView)
        addedTextViews.append(textView)
        
        
        // 將選定的 label 隱藏
        label.isHidden = true
        
        // 設定選定的 UITextView
        selectedTextView = textView
        
        // 讓 UITextView 成為第一回應者，開始編輯
        textView.becomeFirstResponder()
    }
    
    func endEditing() {
        // 如果有選定的 UITextView，結束編輯
        if let textView = selectedTextView {
            textView.resignFirstResponder()
            
            // 將 UITextView 的內容套用到對應的 label 上
            if let label = addedTextLabel.first(where: { $0.tag == selectedTextView?.tag }) {
                label.text = textView.text
                label.isHidden = false
            }
            
            // 移除 UITextView
            selectedTextView?.removeFromSuperview()
            selectedTextView = nil
        }
    }
    
    // UITextViewDelegate 方法，用於結束編輯時的處理
    func textViewDidEndEditing(_ textView: UITextView) {
        endEditing()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //允許同時識別多手勢
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //防止與其他手勢衝突
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer
    }
    
    //調整位置
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let selectedImageView = selectedImageView else { return }
        let translation = sender.translation(in: photoImageView)
        selectedImageView.center = CGPoint(x: selectedImageView.center.x + translation.x, y: selectedImageView.center.y + translation.y)
        sender.setTranslation(.zero, in: photoImageView)
    }
    
    //調整大小
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let selectedImageView = selectedImageView else { return }
        let scale = sender.scale
        selectedImageView.transform = selectedImageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1.0
    }
    
    //旋轉
    @objc func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
        guard let selectedImageView = selectedImageView else { return }
        
        if sender.state == .began || sender.state == .changed {
            selectedImageView.transform = selectedImageView.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
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
    
    // 新增圖層
    func addImageViewToImageView(imageView: UIImageView) {
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        newImageView.center = CGPoint(x: photoImageView.bounds.midX, y: photoImageView.bounds.midY)
        newImageView.isUserInteractionEnabled = true
        photoImageView.addSubview(newImageView)
        //新增tag
        newImageView.tag = addedImageViews.count
        
        // 添加到陣列
        addedImageViews.append(newImageView)
        
        // 選定新增的圖層
        selectedImageView = newImageView
        
        // 添加手勢
        //                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        //                    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        //                    newImageView.addGestureRecognizer(panGesture)
        //                    newImageView.addGestureRecognizer(pinchGesture)
        
        //新增打叉按鈕
        //        let closeButton = UIButton(type: .system)
        //        closeButton.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        //        closeButton.tintColor = .red
        //        closeButton.translatesAutoresizingMaskIntoConstraints = false
        //        closeButton.tag = newImageView.tag
        //        closeButton.isUserInteractionEnabled = true
        //        newImageView.addSubview(closeButton)
        //
        //        //新增功能
        //        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        //
        //        NSLayoutConstraint.activate([
        //            closeButton.topAnchor.constraint(equalTo: newImageView.topAnchor, constant: 5),
        //            closeButton.trailingAnchor.constraint(equalTo: newImageView.trailingAnchor, constant: -5),
        //            closeButton.widthAnchor.constraint(equalToConstant: 30),
        //            closeButton.heightAnchor.constraint(equalToConstant: 30)
        //        ])
    }
    
    
    
    //新增label
    @IBAction func addText(_ sender: Any) {
        collectionView.isHidden = true
        textColorButton.isHidden = false
        //Create a new label
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        label.center = CGPoint(x: photoImageView.bounds.midX, y: photoImageView.bounds.midY)
        label.text = "點一下進行編輯"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        photoImageView.addSubview(label)
        
        // Add close button
        //        addCloseButton(to: label)
        
        //新增tag
        label.tag = addedTextLabel.count
        
        // 添加到陣列
        addedTextLabel.append(label)
        
        // 選定新增的圖層
        selectedLabel = label
        
        // 添加手勢
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLabelPanGesture(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleLabelPinchGesture(_:)))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleLabelRotationGesture(_:)))
        
        label.addGestureRecognizer(panGesture)
        label.addGestureRecognizer(pinchGesture)
        label.addGestureRecognizer(rotationGesture)
        
        // Ensure that subviews of the label also respond to user interaction
        for subview in label.subviews {
            subview.isUserInteractionEnabled = true
        }
    }
    
    func addCloseButton(to label: UILabel) {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        closeButton.tintColor = .red
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        label.addSubview(closeButton)
        
        //新增target功能
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: label.topAnchor, constant: 5),
            closeButton.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: -5),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func handleLabelPanGesture(_ sender: UIPanGestureRecognizer) {
        guard let selectedLabel = selectedLabel else { return }
        let translation = sender.translation(in: photoImageView)
        selectedLabel.center = CGPoint(x: selectedLabel.center.x + translation.x, y: selectedLabel.center.y + translation.y)
        sender.setTranslation(.zero, in: photoImageView)
    }
    
    @objc func handleLabelPinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let selectedLabel = selectedLabel else { return }
        let scale = sender.scale
        selectedLabel.transform = selectedLabel.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1.0
    }
    
    @objc func handleLabelRotationGesture(_ sender: UIRotationGestureRecognizer) {
        guard let selectedLabel = selectedLabel else { return }
        if sender.state == .began || sender.state == .changed {
            selectedLabel.transform = selectedLabel.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
    
    @IBAction func changeTextColor(_ sender: Any) {
        let controller = UIColorPickerViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    //新增顏色
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedTextView?.textColor = viewController.selectedColor
            selectedLabel?.textColor = viewController.selectedColor
    }
    
    //imageView和label共用移除功能（目前fail~）
    @objc func closeButtonTapped(_ sender: UIButton) {
        if let imageView = addedImageViews.first(where: { $0.tag == sender.tag }) {
            imageView.removeFromSuperview()
            addedImageViews.removeAll { $0.tag == sender.tag }
            selectedImageView = nil
        }
        
        if let label = addedTextLabel.first(where: { $0.tag == sender.tag }) {
            label.removeFromSuperview()
            addedTextLabel.removeAll { $0.tag == sender.tag }
            selectedLabel = nil
        }
    }
    
    @IBAction func removeText(_ sender: Any) {
        for label in addedTextLabel {
            label.removeFromSuperview()
        }
        addedTextLabel.removeAll()
        selectedLabel = nil
        
        for textView in addedTextViews {
            textView.removeFromSuperview()
        }
        addedTextViews.removeAll()
        selectedTextView = nil
    }
    
    @IBAction func removeImageView(_ sender: Any) {
        for imageView in addedImageViews {
            imageView.removeFromSuperview()
        }
        addedImageViews.removeAll()
        selectedImageView = nil
    }
    
    @IBAction func shareOrSave(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size:    photoView.bounds.size)
            let editedImage = renderer.image { UIGraphicsImageRendererContext in
                photoView.drawHierarchy(in: photoView.bounds, afterScreenUpdates: true)
            }
            let activityViewController = UIActivityViewController(activityItems: [editedImage], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
    }
    
}


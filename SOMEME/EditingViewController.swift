//
//  EditingViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/16.
//

import Kingfisher
import UIKit
import TOCropViewController
import CoreImage

class EditingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditingCollectionViewCellDelegate, UIGestureRecognizerDelegate, UIColorPickerViewControllerDelegate, TOCropViewControllerDelegate {
    func didTapImage(imageView: UIImageView) {
        addImageViewToImageView(imageView: imageView)
    }
    var flipCounts = 0
    var oneDegree = (CGFloat).pi/180
    var isFlipHorizontal = false
    var isFlipUpDown = false
    @IBOutlet weak var rotateOutlet: UIStackView!
    var imageViews: [UIImageView] = []
    var selectedImage: UIImage?
    var selectedTextView: UITextView?
    var textView: UITextView?
    // 新增存放UIImageView的array
    var addedImageViews: [UIImageView] = []
    // 新增存放UIImageView的array
    var addedTextLabel: [UILabel] = []
    // 新增存放uitextview的array
    var addedTextViews: [UITextView] = []
    // 設定接前頁傳值資料
    var imageViewLoad: UIImage?
    // 追蹤圖層
    var selectedImageView: UIImageView?
    // 追蹤label
    var selectedLabel: UILabel?
    // 新增view把photoImage包起來
    @IBOutlet var photoView: UIView!
    // 設定本頁顯示圖片outlet
    @IBOutlet var photoImageView: UIImageView!
    var collectionView: UICollectionView!
    var isMaterialCollectionView = false
    @IBOutlet weak var doodleView: DoodleView!
    // 設定假資料顯示內容
    var textData = ["恐龍扛狼", "要確欸", "哇酷哇酷", "芭比 Q 了", "注意看，這個男人太狠了", "我沒了", "UCCU", "歸剛欸", "YYDS", "萊納，你坐啊！"]
    var materialData = ["cool guy", "talk", "wacu", "我就爛", "技安", "是在哭", "柴犬", "煙", "貓", "鴨1", "鴨2", "鴨3", "黑人問號"]
    let filterArray = ["","CIPhotoEffectTonal","CIPhotoEffectMono","CIPhotoEffectTransfer", "CIPhotoEffectInstant","CIPhotoEffectFade","CIPhotoEffectProcess", "CIPhotoEffectChrome","CIFalseColor","CIColorPosterize","CILineOverlay","CIComicEffect"]
    let picArray = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11"]
    let picName = ["Original", "Tonal", "Mono", "Transfer", "Instant", "Fade", "Process", "Chrome", "False", "Poster", "Line", "Comic"]
    var materialCollectionView: UICollectionView!
    var items = [MemeLoadDatum]() // 儲存從api取得資料
    // 文字顏色按鈕
    @IBOutlet var textColorButton: UIButton!
    var photoViewGestures: [UIGestureRecognizer] = []
    // collectionView欄位設定
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if isMaterialCollectionView {
            return materialData.count
        } else {
            return items.count
        }
    }
    // 設定collectionView內容的來源
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditingCollectionViewCell", for: indexPath) as? EditingCollectionViewCell else {
            fatalError("Unable to dequeue EditingCollectionViewCell")
        }
        if isMaterialCollectionView == true {
            // materialCollectionView 的設置
                let materialName = materialData[indexPath.row]
                if let materialImage = UIImage(named: materialName) {
                    cell.memeImage.image = materialImage
                    //少了delegate，protocal就沒有辦法啟用喔！
                    cell.delegate = self
            } else {
                print("Index out of range for materialData")
            }
        } else {
                let item = items[indexPath.row]
                cell.delegate = self
                cell.memeImage.kf.setImage(with: item.src)
                cell.update(meme: item)
        }
        return cell
    }
    // 調整collectionView的大小
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100) // 調整 cell 大小
    }
    // 新增水平滑動的 scrollView
    let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    // 設定viewDidLoad的功能
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.layer.cornerRadius = 30
        photoView.layer.shadowOpacity = Float(1)
        photoView.layer.shadowRadius = CGFloat(15)
        photoView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        doodleView.clipsToBounds = true
        doodleView.isMultipleTouchEnabled = false
        tabBarController?.tabBar.isHidden = false
        // 設定顯示傳值過來的圖片
        photoImageView.image = imageViewLoad
        // 梗圖collectionView設定
        let layoutPersonal = UICollectionViewFlowLayout()
        layoutPersonal.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        layoutPersonal.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.scrollDirection = UICollectionView.ScrollDirection.vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutPersonal)
        // collectionView資料源設定
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EditingCollectionViewCell.self, forCellWithReuseIdentifier: EditingCollectionViewCell.cellID)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        // 把myCollectioniew加到畫面裡
        view.addSubview(collectionView)
        // 自動調整關閉
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // CollectionView的限制
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 30),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20)
        ])
        // 初始畫面並無梗圖標示
        collectionView.isHidden = true
        // 設定圖片手勢功能
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        rotationGesture.delegate = self
        photoView.addGestureRecognizer(rotationGesture)
        photoView.addGestureRecognizer(panGesture)
        photoView.addGestureRecognizer(pinchGesture)
        photoViewGestures.append(rotationGesture)
        photoViewGestures.append(panGesture)
        photoViewGestures.append(pinchGesture)
        // 設定 label 手勢功能
        let labelPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLabelPanGesture(_:)))
        labelPanGesture.delegate = self
        let labelPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleLabelPinchGesture(_:)))
        labelPinchGesture.delegate = self
        let labelRotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleLabelRotationGesture(_:)))
        labelRotationGesture.delegate = self
        // 點一下進行編輯、點旁邊一下結束編輯
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 1
        doubleTapGesture.delegate = self
        photoView.addGestureRecognizer(labelRotationGesture)
        photoView.addGestureRecognizer(labelPanGesture)
        photoView.addGestureRecognizer(labelPinchGesture)
        photoView.addGestureRecognizer(doubleTapGesture)
        photoViewGestures.append(labelRotationGesture)
        photoViewGestures.append(labelPanGesture)
        photoViewGestures.append(labelPinchGesture)
        photoViewGestures.append(doubleTapGesture)
        // 初始字體顏色按鈕隱藏
        textColorButton.isHidden = true
        // 設定水平滑動的 scrollView
        view.addSubview(imageScrollView)
        NSLayoutConstraint.activate([
            imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100), // 與上方的 filterScrollView 空出一些間距
            imageScrollView.heightAnchor.constraint(equalToConstant: 80) // 設定高度
        ])
        // 在 scrollView 內新增 imageView
        for (index, imageName) in picArray.enumerated() {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageScrollView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 80), // 設定 imageView 寬度
                imageView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor)
            ])
            if index == 0 {
                imageView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor).isActive = true
            } else {
                imageView.leadingAnchor.constraint(equalTo: imageScrollView.subviews[index - 1].trailingAnchor, constant: 10).isActive = true // 加上一些間距
            }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            imageView.isUserInteractionEnabled = true
            imageView.tag = index
            // Add imageView to the array
            imageViews.append(imageView)
            // 設定 contentSize，確保可以左右滑動
            imageScrollView.contentSize = CGSize(width: CGFloat(picArray.count) * 90, height: 80)
            imageScrollView.isHidden = true
            rotateOutlet.isHidden = true
            doodleView.isUserInteractionEnabled = false
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    @objc func imageViewTapped(_ gesture: UITapGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView {
            applyFilter(to: imageView, filterIndex: imageView.tag)
        }
    }
    // 使用 Core Image 應用濾鏡
    func applyFilter(to imageView: UIImageView, filterIndex: Int) {
        guard filterIndex < filterArray.count else {
            return
        }
        // 移除之前的濾鏡效果
        photoImageView.image = imageViewLoad
        // 取得濾鏡名稱
        let filterName = filterArray[filterIndex]
        // 使用 Core Image 框架來應用濾鏡效果
        if let image = photoImageView.image, let ciImage = CIImage(image: image) {
            if let filter = CIFilter(name: filterName) {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                if let outputCIImage = filter.outputImage {
                    // 將 Core Image 的輸出轉換為 UIImage 並設定到 photoImageView
                    let context = CIContext(options: nil)
                    if let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                        let filteredImage = UIImage(cgImage: outputCGImage)
                        photoImageView.image = filteredImage
                    }
                }
            }
        }
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
    func textViewDidEndEditing(_: UITextView) {
        endEditing()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 防止與其他手勢衝突
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer
    }
    // 調整位置
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let selectedImageView = selectedImageView else { return }
        let translation = sender.translation(in: photoImageView)
        selectedImageView.center = CGPoint(x: selectedImageView.center.x + translation.x, y: selectedImageView.center.y + translation.y)
        sender.setTranslation(.zero, in: photoImageView)
    }
    // 調整大小
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let selectedImageView = selectedImageView else { return }
        let scale = sender.scale
        selectedImageView.transform = selectedImageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1.0
    }
    // 旋轉
    @objc func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
        guard let selectedImageView = selectedImageView else { return }
        if sender.state == .began || sender.state == .changed {
            selectedImageView.transform = selectedImageView.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
    func loadMemeData() {
        // 設定 API 的 URL
        let url = URL(string: "https://memes.tw/wtf/api")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // 發送 API 請求
        URLSession.shared.dataTask(with: request) { data, _, error in
            print("Error API: \(String(describing: error))")
            if let data,
               let content = String(data: data, encoding: .utf8)
            {
                // 解碼 JSON 格式的資料
                //                print(content)
                let decoder = JSONDecoder()
                do {
                    let memes = try decoder.decode([MemeLoadDatum].self, from: data)
                    // 將取得的飲料資料存入 items 陣列
                    self.items = memes
                    self.updateCollectionView() // 成功就更新collectionView
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
    @IBAction func addMeme(_: Any) {
        rotateOutlet.isHidden = true
        imageScrollView.isHidden = true
        isMaterialCollectionView = false
        collectionView.isHidden = false
        loadMemeData()
        updateCollectionView()
        textColorButton.isHidden = true
        doodleView.isUserInteractionEnabled = false
        for gesture in photoViewGestures {
            gesture.isEnabled = true
        }
    }
    // 新增圖層
    func addImageViewToImageView(imageView: UIImageView) {
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        newImageView.center = CGPoint(x: photoImageView.bounds.midX, y: photoImageView.bounds.midY)
        newImageView.isUserInteractionEnabled = true
        photoImageView.addSubview(newImageView)
        // 新增tag
        newImageView.tag = addedImageViews.count
        // 添加到陣列
        addedImageViews.append(newImageView)
        // 選定新增的圖層
        selectedImageView = newImageView
    }
    // 新增label
    @IBAction func addText(_: Any) {
        rotateOutlet.isHidden = true
        imageScrollView.isHidden = true
        collectionView.isHidden = true
        textColorButton.isHidden = false
        // Create a new label
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        label.center = CGPoint(x: photoImageView.bounds.midX, y: photoImageView.bounds.midY)
        label.text = "點一下進行編輯"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        photoImageView.addSubview(label)
        // 新增tag
        label.tag = addedTextLabel.count
        // 添加到陣列
        addedTextLabel.append(label)
        // 選定新增的圖層
        selectedLabel = label
        // Ensure that subviews of the label also respond to user interaction
        for subview in label.subviews {
            subview.isUserInteractionEnabled = true
        }
        doodleView.isUserInteractionEnabled = false
        for gesture in photoViewGestures {
            gesture.isEnabled = true
        }
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
    @IBAction func changeTextColor(_: Any) {
        let controller = UIColorPickerViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    // 新增顏色
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedTextView?.textColor = viewController.selectedColor
        selectedLabel?.textColor = viewController.selectedColor
    }
    @IBAction func removeText(_: Any) {
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
    @IBAction func removeImageView(_: Any) {
        for imageView in addedImageViews {
            imageView.removeFromSuperview()
        }
        addedImageViews.removeAll()
        selectedImageView = nil
    }
    @IBAction func shareOrSave(_: Any) {
        textColorButton.isHidden = true
        let renderer = UIGraphicsImageRenderer(size: photoView.bounds.size)
        let editedImage = renderer.image { _ in
            photoView.drawHierarchy(in: photoView.bounds, afterScreenUpdates: true)
        }
        let activityViewController = UIActivityViewController(activityItems: [editedImage], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        doodleView.isUserInteractionEnabled = false
        for gesture in photoViewGestures {
            gesture.isEnabled = true
        }
    }
    @IBAction func showMaterial(_: Any) {
        imageScrollView.isHidden = true
        textColorButton.isHidden = true
        textColorButton.isHidden = true
        isMaterialCollectionView = true
        collectionView.isHidden = false
        rotateOutlet.isHidden = true
        updateCollectionView()
        doodleView.isUserInteractionEnabled = false
        for gesture in photoViewGestures {
            gesture.isEnabled = true
        }
    }
    @IBAction func addMyfavorite(_ sender: Any) {
        // 使用 UIGraphicsImageRenderer 將 photoView 畫成一張圖片
        let renderer = UIGraphicsImageRenderer(size: photoView.bounds.size)
        let editedImage = renderer.image { _ in
            photoView.drawHierarchy(in: photoView.bounds, afterScreenUpdates: true)
        }
        // 將圖片轉換為 Data
        if let imageData = editedImage.jpegData(compressionQuality: 1.0) {
            // 生成一個唯一的名稱，可以使用 UUID
            let photoName = "EditedPhoto_" + UUID().uuidString
            // 將圖片名稱和圖片數據保存到 UserDefaults
            FavoritesManager.shared.addFavorite(photoName, imageData: imageData)
            // 你可以選擇性地顯示成功添加的提示，例如一個提示框
            let alert = UIAlertController(title: "成功", message: "已將照片添加到收藏夾", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            // 處理圖片轉換為 Data 失敗的情況
            let alert = UIAlertController(title: "錯誤", message: "無法將圖片轉換為數據", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func flipLeft(_ sender: Any) {
        flipCounts -= 1
        photoImageView.transform = CGAffineTransform(rotationAngle: oneDegree * 90 * CGFloat(flipCounts))
    }
    @IBAction func flipRight(_ sender: Any) {
        flipCounts += 1
        photoImageView.transform = CGAffineTransform(rotationAngle: oneDegree * 90 * CGFloat(flipCounts))
    }
    @IBAction func flipHorizantal(_ sender: Any) {
        if isFlipHorizontal {
            if photoImageView.transform == CGAffineTransform(scaleX: -1, y: 1) {
                photoImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                isFlipHorizontal = false
            }
            if photoImageView.transform == CGAffineTransform(scaleX: -1, y: -1) {
                photoImageView.transform = CGAffineTransform(scaleX: 1, y: -1)
                isFlipHorizontal = false
            }
        } else {
            if photoImageView.transform == CGAffineTransform(scaleX: 1, y: 1) {
                photoImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                isFlipHorizontal = true
            }
            if photoImageView.transform == CGAffineTransform(scaleX: 1, y: -1) {
                photoImageView.transform = CGAffineTransform(scaleX: -1, y: -1)
                isFlipHorizontal = true
            }
        }
    }
    @IBAction func flipVertical(_ sender: Any) {
        if isFlipUpDown == true {
            if photoImageView.transform == CGAffineTransform(scaleX: 1, y: -1) {
                photoImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                isFlipUpDown = false
            }
            if photoImageView.transform == CGAffineTransform(scaleX: -1, y: -1) {
                photoImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                isFlipUpDown = false
            }
        }
        else {
            if photoImageView.transform == CGAffineTransform(scaleX: 1, y: 1) {
                photoImageView.transform = CGAffineTransform(scaleX: 1, y: -1)
                isFlipUpDown = true
            }
            if photoImageView.transform == CGAffineTransform(scaleX: -1, y: 1) {
                photoImageView.transform = CGAffineTransform(scaleX: -1, y: -1)
                isFlipUpDown = true
            }
        }
    }
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        // 在這裡處理裁切後的圖片
        photoImageView.image = image
        // 關閉 TOCropViewController
        cropViewController.dismiss(animated: true, completion: nil)
    }
    // 裁剪取消時的回調
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        // 關閉 TOCropViewController
        cropViewController.dismiss(animated: true, completion: nil)
    }
    @IBAction func cropImageView(_ sender: Any) {
        imageScrollView.isHidden = true
        collectionView.isHidden = true
        rotateOutlet.isHidden = true
        textColorButton.isHidden = true
        doodleView.isUserInteractionEnabled = false
        for gesture in photoViewGestures {
            gesture.isEnabled = true
        }
        guard let image = photoImageView.image else {
            // 如果沒有圖片，不進行裁切
            return
        }
        // 初始化 TOCropViewController
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = self
        // 呈現 TOCropViewController
        present(cropViewController, animated: true, completion: nil)
    }
    @IBAction func filter(_ sender: Any) {
        imageScrollView.isHidden = false
        collectionView.isHidden = true
        rotateOutlet.isHidden = true
        textColorButton.isHidden = true
        doodleView.isUserInteractionEnabled = false
        for gesture in photoViewGestures {
            gesture.isEnabled = true
        }
    }
    @IBAction func rotateImage(_ sender: Any) {
        rotateOutlet.isHidden = false
        imageScrollView.isHidden = true
        collectionView.isHidden = true
        textColorButton.isHidden = true
        doodleView.isUserInteractionEnabled = false
        for gesture in photoViewGestures {
            gesture.isEnabled = true
        }
    }
    @IBAction func doodle(_ sender: Any) {
        collectionView.isHidden = true
        doodleView.isUserInteractionEnabled = true
        for gesture in photoViewGestures {
            gesture.isEnabled = false
        }
    }
    @IBAction func removeDoodle(_ sender: Any) {
        doodleView.clearCanvas()
    }
    @IBAction func removeBG(_ sender: Any) {
        //        guard let image = photoImageView.image else {
        //            // 確保有圖片可供去背
        //            return
        //        }
        //        // 調用 RemoveBGManager 進行去背
        //        RemoveBGManager.shared.removeImageBg(uiImage: image) { removedImage in
        //            if let removedImage = removedImage {
        //                // 成功處理去背後的圖片
        //                DispatchQueue.main.async {
        //                    self.photoImageView.image = removedImage
        //                }
        //            } else {
        //                // 處理失敗的情況
        //                print("Error removing background")
        //            }
        //        }
    }
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mlRemoveBG(_ sender: Any) {
        
    }
}

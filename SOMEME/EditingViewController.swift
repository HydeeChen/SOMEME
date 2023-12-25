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
import FirebaseCore
import FirebaseFirestore
import Lottie
import Hover

class EditingViewController: UIViewController, UICollectionViewDelegate {
    var rotationCounts: CGFloat = 0
    var isFlippedHorizontally: Bool = false
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
    @IBOutlet weak var saveOutlet: UIView!
    let filterArray = ["","CIPhotoEffectTonal","CIPhotoEffectMono","CIPhotoEffectTransfer", "CIPhotoEffectInstant","CIPhotoEffectFade","CIPhotoEffectProcess", "CIPhotoEffectChrome","CIFalseColor","CIColorPosterize","CILineOverlay","CIComicEffect"]
    let picArray = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11"]
    let picName = ["Original", "Tonal", "Mono", "Transfer", "Instant", "Fade", "Process", "Chrome", "False", "Poster", "Line", "Comic"]
    var materialCollectionView: UICollectionView!
    var items = [MemeLoadDatum]() // 儲存從api取得資料
    var firebaseMeme = [MaterialData]() // 儲存從firebase取得的資料
    // 文字顏色按鈕
    @IBOutlet var textColorButton: UIButton!
    var photoViewGestures: [UIGestureRecognizer] = []
    @IBOutlet weak var moveLabelOutlet: UISwitch!
    @IBOutlet weak var movePicOutlet: UISwitch!
    var imageGestures: [UIGestureRecognizer] = []
    var labelGestures: [UIGestureRecognizer] = []
    @IBOutlet weak var moveOutlet: UIView!
    // 設定移動outlet是隱藏的變數
    var moveOutletIsHidden: Bool = true
    // 設定儲存outlet是隱藏的變數
    var saveOutletIsHidden: Bool = true
    // 新增水平滑動的 scrollView
    let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    @IBOutlet weak var contentImageView: UIImageView!
    // 搜尋textField
    @IBOutlet weak var searchTextFieldOutlet: UITextField!
    // 搜尋按鈕outlet
    @IBOutlet weak var searchButtonOutlet: UIButton!
    var isSearchMaterial: Bool = false
    var searchMemeResult : [ MaterialData] = []
    @IBOutlet weak var doodleLabelOutlet: UILabel!
    var undoMng = UndoManager()
    // 設定viewWillAppear內容
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseLoadManager.fetchMaterialData { [weak self] (data, error) in
            if let error = error {
                print("Error fetching data: \(error)")
            } else if let data = data {
                self?.firebaseMeme = data
                self?.collectionView.reloadData()
            }
        }
    }
    @objc func imageViewTapped(_ gesture: UITapGestureRecognizer) {
        guard !undoMng.isUndoing else {
            return
        }
        if let imageView = gesture.view as? UIImageView {
            let oldFilterIndex = imageView.tag
            let oldImage = imageView.image
            applyFilter(to: imageView, filterIndex: imageView.tag)
            undoMng.registerUndo(withTarget: self) { [weak self] targetSelf in
                imageView.tag = oldFilterIndex
                imageView.image = oldImage
            }
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
        let AnimationView = LottieAnimationView()
        let Animation = LottieAnimation.named("spark")
        AnimationView.animation = Animation
        AnimationView.frame = CGRect(x: -50, y: 100, width: 500, height: 500)
        view.addSubview(AnimationView)
        AnimationView.play()
        AnimationView.play(fromProgress: 0.0, toProgress: 1, loopMode: .none) { (completed) in
            if completed {
                AnimationView.removeFromSuperview()
            }
        }
    }
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: contentImageView)
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
    // 調整位置
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let selectedImageView = selectedImageView else { return }
        let translation = sender.translation(in: contentImageView)
        selectedImageView.center = CGPoint(x: selectedImageView.center.x + translation.x, y: selectedImageView.center.y + translation.y)
        sender.setTranslation(.zero, in: contentImageView)
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
    @IBAction func openSaveOutlet(_ sender: Any) {
        UIView.transition(with: saveOutlet, duration: 0.4, options: .transitionCrossDissolve, animations: {
            if self.saveOutletIsHidden {
                self.saveOutlet.isHidden = false
                self.saveOutletIsHidden = false
            } else {
                self.saveOutlet.isHidden = true
                self.saveOutletIsHidden = true
            }
        }, completion: nil)
    }
    @IBAction func openMoveOutlet(_ sender: Any) {
        UIView.transition(with: moveOutlet, duration: 0.4, options: .transitionCrossDissolve, animations: {
            if self.moveOutletIsHidden {
                self.moveOutlet.isHidden = false
                self.moveOutletIsHidden = false
            } else {
                self.moveOutlet.isHidden = true
                self.moveOutletIsHidden = true
            }
        }, completion: nil)
    }
    @IBAction func addMeme(_: Any) {
        doodleLabelOutlet.isHidden = true
        searchTextFieldOutlet.isHidden = true
        searchButtonOutlet.isHidden = true
        rotateOutlet.isHidden = true
        imageScrollView.isHidden = true
        isMaterialCollectionView = false
        isSearchMaterial = false
        self.collectionView.reloadData()
        collectionView.isHidden = false
        loadMemeData()
        updateCollectionView()
        textColorButton.isHidden = true
        doodleView.isUserInteractionEnabled = false
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = false
        }
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = true
        }
    }
    // 把圖片新增到圖層
    func addImageViewToImageView(imageView: UIImageView) {
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        newImageView.center = CGPoint(x: contentImageView.bounds.midX, y: contentImageView.bounds.midY)
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        contentImageView.addSubview(newImageView)
        // 新增tag
        newImageView.tag = addedImageViews.count
        // 添加到陣列
        addedImageViews.append(newImageView)
        // 選定新增的圖層
        selectedImageView = newImageView
    }
    // 新增label
    @IBAction func addText(_: Any) {
        doodleLabelOutlet.isHidden = true
        searchTextFieldOutlet.isHidden = true
        searchButtonOutlet.isHidden = true
        rotateOutlet.isHidden = true
        imageScrollView.isHidden = true
        collectionView.isHidden = true
        textColorButton.isHidden = false
        // Create a new label
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        label.center = CGPoint(x: contentImageView.bounds.midX, y: contentImageView.bounds.midY)
        label.text = "點擊文字編輯"
        label.textAlignment = .center
        label.textColor = .color
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17)
        label.isUserInteractionEnabled = true
        // 使用 `UIFont` 設定黑體加粗
        label.font = UIFont.boldSystemFont(ofSize:17)
        // 設定文字的外框
        let attributedString = NSMutableAttributedString(string: label.text!)
        attributedString.addAttribute(.strokeWidth, value: -3, range: NSMakeRange(0, attributedString.length))
        // 加入外框顏色
        attributedString.addAttribute(.strokeColor, value: UIColor.black, range: NSMakeRange(0, attributedString.length) )
        label.attributedText = attributedString
        contentImageView.addSubview(label)
        // 新增tag
        label.tag = addedTextLabel.count
        // 添加到陣列
        addedTextLabel.append(label)
        // 選定新增的圖層
        selectedLabel = label
        doodleView.isUserInteractionEnabled = false
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = true
        }
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = false
        }
    }
    @objc func handleLabelPanGesture(_ sender: UIPanGestureRecognizer) {
        guard let selectedLabel = selectedLabel else { return }
        let translation = sender.translation(in: contentImageView)
        selectedLabel.center = CGPoint(x: selectedLabel.center.x + translation.x, y: selectedLabel.center.y + translation.y)
        sender.setTranslation(.zero, in: contentImageView)
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
    func hoverRemoveText() {
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
    func hoverRemoveImageView() {
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
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = true
        }
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = true
        }
    }
    @IBAction func showMaterial(_: Any) {
        doodleLabelOutlet.isHidden = true
        // 設定初始搜尋outlet隱藏
        searchTextFieldOutlet.isHidden = false
        searchButtonOutlet.isHidden = false
        imageScrollView.isHidden = true
        textColorButton.isHidden = true
        textColorButton.isHidden = true
        isMaterialCollectionView = true
        isSearchMaterial = false
        self.collectionView.reloadData()
        collectionView.isHidden = false
        rotateOutlet.isHidden = true
        updateCollectionView()
        doodleView.isUserInteractionEnabled = false
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = false
        }
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = true
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
            // 新增收藏動畫
            let starAnimationView = LottieAnimationView()
            let starAnimation = LottieAnimation.named("star")
            starAnimationView.animation = starAnimation
            starAnimationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            starAnimationView.center = view.center
            view.addSubview(starAnimationView)
            starAnimationView.play()
            starAnimationView.play(fromProgress: 0.0, toProgress: 1.0, loopMode: .none) { (completed) in
                if completed {
                    starAnimationView.removeFromSuperview()
                }
            }
        }
    }
    @IBAction func flipLeft(_ sender: Any) {
        rotationCounts -= 1
        photoImageView.transform = CGAffineTransform(rotationAngle: oneDegree * 90 * rotationCounts)
    }
    @IBAction func flipRight(_ sender: Any) {
        rotationCounts += 1
        photoImageView.transform = CGAffineTransform(rotationAngle: oneDegree * 90 * rotationCounts)
    }
    @IBAction func flipHorizantal(_ sender: Any) {
        if isFlippedHorizontally {
            photoImageView.transform = photoImageView.transform.scaledBy(x: -1, y: 1)
        } else {
            photoImageView.transform = photoImageView.transform.scaledBy(x: 1, y: 1)
        }
        isFlippedHorizontally = !isFlippedHorizontally
    }
    @IBAction func flipVertical(_ sender: Any) {
        photoImageView.transform = photoImageView.transform.scaledBy(x: 1, y: -1)
    }
    @IBAction func cropImageView(_ sender: Any) {
        doodleLabelOutlet.isHidden = true
        searchTextFieldOutlet.isHidden = true
        searchButtonOutlet.isHidden = true
        imageScrollView.isHidden = true
        collectionView.isHidden = true
        rotateOutlet.isHidden = true
        textColorButton.isHidden = true
        doodleView.isUserInteractionEnabled = false
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = true
        }
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = true
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
        doodleLabelOutlet.isHidden = true
        searchTextFieldOutlet.isHidden = true
        searchButtonOutlet.isHidden = true
        imageScrollView.isHidden = false
        collectionView.isHidden = true
        rotateOutlet.isHidden = true
        textColorButton.isHidden = true
        doodleView.isUserInteractionEnabled = false
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = true
        }
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = true
        }
    }
    @IBAction func rotateImage(_ sender: Any) {
        doodleLabelOutlet.isHidden = true
        searchTextFieldOutlet.isHidden = true
        searchButtonOutlet.isHidden = true
        rotateOutlet.isHidden = false
        imageScrollView.isHidden = true
        collectionView.isHidden = true
        textColorButton.isHidden = true
        doodleView.isUserInteractionEnabled = true
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = true
        }
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = true
        }
    }
    @IBAction func doodle(_ sender: Any) {
        doodleLabelOutlet.isHidden = false
        textColorButton.isHidden = true
        rotateOutlet.isHidden = true
        searchTextFieldOutlet.isHidden = true
        searchButtonOutlet.isHidden = true
        collectionView.isHidden = true
        doodleView.isUserInteractionEnabled = true
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = false
        }
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = false
        }
    }
    func hoverRemoveDoodle() {
        doodleView.clearCanvas()
    }
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func moveLabel(_ sender: Any) {
        for gestureRecognizer in labelGestures {
            gestureRecognizer.isEnabled = (sender as AnyObject).isOn
        }
    }
    @IBAction func movePic(_ sender: Any) {
        for gestureRecognizer in imageGestures {
            gestureRecognizer.isEnabled = (sender as AnyObject).isOn
        }
    }
    @IBAction func searchMaterial(_ sender: Any) {
        view.endEditing(true)
        isSearchMaterial = true
        guard let searchText = searchTextFieldOutlet.text, !searchText.isEmpty else {
            isSearchMaterial = true
            isMaterialCollectionView = true
            self.collectionView.reloadData()
            return
        }
        let db = Firestore.firestore()
        let materialsCollection = db.collection("material")
        // 查詢 hashtag 中包含搜尋文字的資料
        materialsCollection.whereField("hashtag", arrayContains: searchText).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                // 可以採取相應的處理方式
            } else {
                // 清空之前的搜索結果
                self.searchMemeResult.removeAll()
                // 處理查詢結果
                for document in querySnapshot!.documents {
                    do {
                        // 將 Firestore 中的資料轉換為 MaterialData 物件
                        let materialData = try document.data(as: MaterialData.self)
                        self.searchMemeResult.append(materialData)
                        self.collectionView.reloadData()
                    } catch {
                        print("Error decoding document: \(error)")
                        // 可以採取相應的處理方式
                    }
                }
                // 在這裡可以更新你的 UI，顯示搜尋結果
                print("Search result: \(self.searchMemeResult)")
            }
        }
    }
    @IBAction func undo(_ sender: Any) {

    }
    @IBAction func redo(_ sender: Any) {
    }
}

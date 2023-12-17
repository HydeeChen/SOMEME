//
//  HotViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/20.
//

import Kingfisher
import UIKit
import Lottie

class HotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var selectedCategoryIndex: Int?
    @IBOutlet var photoImageView: UIImageView!
    var expandedImageView: UIImageView?
    @IBOutlet var nowPosition: UILabel!
    var overlayView = UIView()
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HotCollectionViewCell", for: indexPath) as? HotCollectionViewCell else {
            fatalError("Unable to dequeue EditingCollectionViewCell")
        }
        let item = items[indexPath.row]
        cell.memeImage.kf.setImage(with: item.src)
        cell.update(meme: item)
        cell.delegate = self
        return cell
    }
    // 設定collectionView
    var collectionView: UICollectionView!
    // 儲存從api取得資料
    var items = [MemeLoadDatum]()
    @IBOutlet var shadowView: UIView!
    // 製作彈出視窗
    var burgerButton = UIButton()
    let burgerTableView = UITableView()
    let burgerTransparentView = UIView()
    @IBOutlet var selectOptionButton: UIButton!
    @IBAction func popBurgerList(_: Any) {
        burgerButton = selectOptionButton
        addBurgerTransparentView(frames: selectOptionButton.frame)
        burgerTableView.reloadData()
    }
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        // Check if expandedImageView is already present, remove it if it is
        overlayView.isHidden = false
        if let existingExpandedImageView = expandedImageView {
            existingExpandedImageView.removeFromSuperview()
            expandedImageView = nil
            return
        }
        // Create a new imageView and set its image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 350, height: 500))
        imageView.center = view.center
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: selectedItem.src)
        // Add tap gesture to remove the imageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeExpandedImageView))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        // Add the imageView to the view
        view.addSubview(imageView)
        // Set the expandedImageView property
        expandedImageView = imageView
    }
    @objc func removeExpandedImageView() {
        // Remove the expandedImageView when tapped
        expandedImageView?.removeFromSuperview()
        expandedImageView = nil
        overlayView.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定背景陰影
        shadowView.layer.cornerRadius = CGFloat(30)
        shadowView.layer.shadowOpacity = Float(1)
        shadowView.layer.shadowRadius = CGFloat(15)
        shadowView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // 彈出視窗
        setBurgerTableView()
        // 設定collectionView
        let layoutPersonal = UICollectionViewFlowLayout()
        layoutPersonal.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        layoutPersonal.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.scrollDirection = UICollectionView.ScrollDirection.vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutPersonal)
        // collectionView資料源設定
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SOMEME.HotCollectionViewCell.self as AnyClass, forCellWithReuseIdentifier: SOMEME.HotCollectionViewCell.cellID)
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        // 把myCollectioniew加到畫面裡
        view.addSubview(collectionView)
        // 自動調整關閉
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // CollectionView的限制
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
        if let initialApiUrl = URL(string: "https://memes.tw/wtf/api") {
            loadMemeData(apiUrl: initialApiUrl)
        }
        // 黑色底平常為隱藏
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.9
        overlayView.isHidden = true
        view.addSubview(overlayView)
    }
    @objc func photoImageViewTapped() {
        // Hide the photoImageView when tapped
        photoImageView.isHidden = true
    }
    // 漢堡頁面設定
    func setBurgerTableView() {
        burgerTableView.delegate = self
        burgerTableView.dataSource = self
        burgerTableView.isScrollEnabled = false
        burgerTableView.register(HotTableViewCell.self, forCellReuseIdentifier: "HotTableViewCell")
        burgerTableView.separatorStyle = .none
    }
    // 漢堡頁面設定
    func addBurgerTransparentView(frames: CGRect) {
        let window = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }.first
        // 設定漢堡頁背景透明視圖的背景色
        burgerTransparentView.backgroundColor = .color
        burgerTransparentView.frame = window?.frame ?? view.frame
        view.addSubview(burgerTransparentView)
        burgerTableView.frame = CGRect(x: view.bounds.minX - 10,
                                       y: frames.origin.y + selectOptionButton.frame.height,
                                       width: 0,
                                       height: view.frame.height / 1.3)
        view.addSubview(burgerTableView)
        burgerTableView.layer.cornerRadius = 10
        burgerTableView.alpha = 0.8
        burgerTransparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        burgerTableView.reloadData()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeBurgerTransparentView))
        burgerTransparentView.addGestureRecognizer(tapGesture)
        burgerTransparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .overrideInheritedCurve, animations: {
            self.burgerTransparentView.alpha = 0.1
            self.burgerTableView.frame = CGRect(x: self.view.bounds.minX - 10, y: frames.origin.y + self.selectOptionButton.frame.height, width: self.view.frame.width / 2 + 10, height: self.view.frame.height / 1.3)
        }, completion: nil)
    }
    // 收起漢堡頁面
    @objc func removeBurgerTransparentView() {
        let frames = burgerButton.frame
        UIView.animate(withDuration: 1.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .overrideInheritedCurve, animations: {
            self.burgerTransparentView.alpha = 0
            self.burgerTableView.frame = CGRect(x: self.view.bounds.minX - 10, y: frames.origin.y + self.selectOptionButton.frame.height, width: 0, height: self.view.frame.height / 1.3)
        }, completion: nil)
    }
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return memeCategories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HotTableViewCell", for: indexPath)
        cell.textLabel?.text = memeCategories[indexPath.row].name
        cell.textLabel?.textAlignment = .center
        let fontUrl = Bundle.main.url(forResource: "Mamelon", withExtension: "otf")! as CFURL
        CTFontManagerRegisterFontsForURL(fontUrl, .process, nil)
        cell.textLabel?.font = UIFont(name: "Mamelon", size: 18) ?? UIFont.systemFont(ofSize: 18)
        if indexPath.row == selectedCategoryIndex {
            cell.textLabel?.textColor = .blue // Set your desired highlight color
        } else {
            cell.textLabel?.textColor = .black // Set your default color
        }
        return cell
    }
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 43
    }
    // 串接api
    func loadMemeData(apiUrl: URL) {
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        // 發送 API 請求
        URLSession.shared.dataTask(with: request) { data, _, error in
            print("Error API: \(String(describing: error))")
            if let data {
                // 解碼 JSON 格式的資料
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
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 300) // 調整 cell 大小
    }
    func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedApiUrl = memeCategories[indexPath.row].apiUrl
        loadMemeData(apiUrl: selectedApiUrl)
        removeBurgerTransparentView()
        // 移到 collectionView 的第一個 cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: firstIndexPath, at: .top, animated: true)
        nowPosition.text = " \(memeCategories[indexPath.row].name)"
    }
}

extension HotViewController: HotCollectionViewCellDelegate {
    func HotCollectionViewCell(_Cell Cell: HotCollectionViewCell, didPressShareButton _: Any) {
        if let indexPath = collectionView.indexPath(for: Cell) {
            let selectedItem = items[indexPath.row]
            let renderer = UIGraphicsImageRenderer(size: Cell.memeImage.bounds.size)
            let editedImage = renderer.image { _ in
                Cell.memeImage.drawHierarchy(in: Cell.memeImage.bounds, afterScreenUpdates: true)
            }
            let activityViewController = UIActivityViewController(activityItems: [editedImage], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }
    func HotCollectionViewCell(_Cell Cell: HotCollectionViewCell, didPressEditButton _: Any, withImage image: UIImage? ) {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let editVC = st.instantiateViewController(withIdentifier: "EditingViewController") as! EditingViewController
        // 傳遞圖片給 EditingViewController
        editVC.imageViewLoad = image
        // 設定全螢幕呈現模式
        editVC.modalPresentationStyle = .fullScreen
        self.present(editVC, animated: true)
    }
    func HotCollectionViewCell(_Cell Cell: HotCollectionViewCell, didPressLikeButton _: Any) {
        // 將圖片轉換為 Data
        if let image = Cell.memeImage.image, let imageData = image.jpegData(compressionQuality: 1.0) {
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
                }}
        } else {
            // 處理圖片為空的情況
            showAlert(title: "錯誤", message: "無法將圖片轉換為數據")
        }
        // 提取的提示框處理函數
        func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

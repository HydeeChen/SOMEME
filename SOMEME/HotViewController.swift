//
//  HotViewController.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/20.
//

import UIKit
import Kingfisher

class HotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var selectedCategoryIndex: Int?
    
    
    @IBOutlet weak var nowPosition: UILabel!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HotCollectionViewCell", for: indexPath) as? HotCollectionViewCell else {
            fatalError("Unable to dequeue EditingCollectionViewCell")
        }
        let item = items[indexPath.row]
        cell.memeImage.kf.setImage(with: item.src)
        cell.update(meme: item)
        return cell
    }
    
    //設定collectionView
    var collectionView: UICollectionView!
    // 儲存從api取得資料
    var items = [MemeLoadDatum]()
    @IBOutlet weak var shadowView: UIView!
    
    //製作彈出視窗
    var burgerButton = UIButton()
    let burgerTableView = UITableView()
    let burgerTransparentView = UIView()
    @IBOutlet weak var selectOptionButton: UIButton!
    
    @IBAction func popBurgerList(_ sender: Any) {
        burgerButton = selectOptionButton
        addBurgerTransparentView(frames: selectOptionButton.frame)
        burgerTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //設定背景陰影
        shadowView.layer.cornerRadius = CGFloat(30)
        shadowView.layer.shadowOpacity = Float(1)
        shadowView.layer.shadowRadius = CGFloat(15)
        shadowView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        //彈出視窗
        setBurgerTableView()
        
        //設定collectionView
        
        let layoutPersonal: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutPersonal.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        layoutPersonal.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.scrollDirection = UICollectionView.ScrollDirection.vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutPersonal)
        
        //collectionView資料源設定
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(HotCollectionViewCell.self, forCellWithReuseIdentifier: "HotCollectionViewCell")
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
            collectionView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 200),
            collectionView.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
        
        if let initialApiUrl = URL(string: "https://memes.tw/wtf/api") {
                loadMemeData(apiUrl: initialApiUrl)
            }
    }
    
    //漢堡頁面設定
    func setBurgerTableView() {
        burgerTableView.delegate = self
        burgerTableView.dataSource = self
        burgerTableView.isScrollEnabled = false
        burgerTableView.register(HotTableViewCell.self, forCellReuseIdentifier: "HotTableViewCell")
        burgerTableView.separatorStyle = .none
    }
    
    //漢堡頁面設定
    func addBurgerTransparentView(frames: CGRect) {
        let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        burgerTransparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(burgerTransparentView)
        
        burgerTableView.frame = CGRect(x: self.view.bounds.minX - 10
                                       , y: frames.origin.y + self.selectOptionButton.frame.height
                                       , width: 0
                                       , height: self.view.frame.height / 1.3)
        self.view.addSubview(burgerTableView)
        burgerTableView.layer.cornerRadius = 10
        burgerTableView.alpha = 0.8
        
        burgerTransparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        burgerTableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeBurgerTransparentView))
        burgerTransparentView.addGestureRecognizer(tapGesture)
        burgerTransparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .overrideInheritedCurve, animations: {
            self.burgerTransparentView.alpha = 0.1
            self.burgerTableView.frame = CGRect(x: self.view.bounds.minX - 10 , y: frames.origin.y + self.selectOptionButton.frame.height, width: self.view.frame.width / 2 + 10, height: self.view.frame.height / 1.3)
        }, completion: nil)
        
    }
    
    //收起漢堡頁面
    @objc func removeBurgerTransparentView() {
        let frames = burgerButton.frame
        UIView.animate(withDuration: 1.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .overrideInheritedCurve, animations: {
            self.burgerTransparentView.alpha = 0
            self.burgerTableView.frame = CGRect(x: self.view.bounds.minX - 10 , y: frames.origin.y +  self.selectOptionButton.frame.height, width: 0, height: self.view.frame.height / 1.3)
        }, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memeCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HotTableViewCell", for: indexPath)
            cell.textLabel?.text = memeCategories[indexPath.row].name
            cell.textLabel?.textAlignment = .center
            
            if indexPath.row == selectedCategoryIndex {
                cell.textLabel?.textColor = .blue // Set your desired highlight color
            } else {
                cell.textLabel?.textColor = .black // Set your default color
            }
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43
    }
    
    //串接api
    func loadMemeData(apiUrl: URL) {
        var request = URLRequest(url: apiUrl)
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height:300) // 調整 cell 大小
    }
    
    func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedApiUrl = memeCategories[indexPath.row].apiUrl
        loadMemeData(apiUrl: selectedApiUrl)
        removeBurgerTransparentView()
        
        nowPosition.text = " \(memeCategories[indexPath.row].name)"
    }
    
}



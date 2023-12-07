//
//  FavoritesManager.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/23.
//

import Foundation
import UIKit

class FavoritesManager {
    static let shared = FavoritesManager()

    private let favoritesKey = "FavoritePhotos"

    private init() {}

    var favoritePhotos: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: favoritesKey)
        }
    }

    func addFavorite(_ photoName: String, imageData: Data) {
        var favorites = favoritePhotos
        favorites.append(photoName)
        favoritePhotos = favorites
        UserDefaults.standard.set(imageData, forKey: photoName)
    }

    func removeFavorite(_ photoName: String) {
        var favorites = favoritePhotos
        if let index = favorites.firstIndex(of: photoName) {
            favorites.remove(at: index)
            favoritePhotos = favorites
            UserDefaults.standard.removeObject(forKey: photoName)
        }
    }
// 取得相片的方法，接收相片名稱作為參數，回傳相應的 UIImage
    func getImage(for photoName: String) -> UIImage? {
        if let imageData = UserDefaults.standard.data(forKey: photoName) {
            return UIImage(data: imageData)
        }
        return nil
    }
}

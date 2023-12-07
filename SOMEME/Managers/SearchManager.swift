//
//  SearchManager.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/28.
//

import Foundation

class MemeService {
    static func searchMemesByHashtag(hashtag: String, completion: @escaping ([MemeLoadDatum]?) -> Void) {
        guard let searchURL = URL(string: "https://memes.tw/wtf/api?hashtag=\(hashtag)") else {
            print("Error creating search URL")
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: searchURL) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let memes = try decoder.decode([MemeLoadDatum].self, from: data)
                completion(memes)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

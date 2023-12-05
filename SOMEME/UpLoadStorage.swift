//
//  UpLoadStorage.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/12/4.
//
import Foundation
import FirebaseStorage

class UpLoadStorage {
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".png")
        if let data = image.pngData() {
            fileReference.putData(data, metadata: nil) { result in
                switch result {
                case .success:
                    fileReference.downloadURL(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

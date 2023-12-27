//
//  RemoveBGManager.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/12/1.
//

import UIKit
import Alamofire

struct RemoveBGManager {
    static let shared = RemoveBGManager()

    func removeImageBg(uiImage: UIImage, completion: @escaping (UIImage?) -> Void) {
        let headers: HTTPHeaders = [
            "X-Api-Key": "rDc7uiRo7Kfq2tX2GxNRGCAn"
        ]
        AF.upload(multipartFormData: { data in
            let imageData = uiImage.jpegData(compressionQuality: 0.9)
            data.append(imageData!, withName: "image_file", fileName: UUID().uuidString, mimeType: "image/jpeg")
        }, to: "https://api.remove.bg/v1.0/removebg", headers: headers).responseData { response in
            if let data = response.data,
               let image = UIImage(data: data) {
                // Save as PNG with transparency
                if let pngData = image.pngData() {
                    if let pngImage = UIImage(data: pngData) {
                        completion(pngImage)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
}

//
//  FirebaseLoadManager.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/12/5.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseLoadManager {
    static func fetchMaterialData(completion: @escaping ([MaterialData]?, Error?) -> Void) {
           let db = Firestore.firestore()
           db.collection("material").getDocuments { (querySnapshot, error) in
               if let error = error {
                   completion(nil, error)
               } else {
                   var firebaseMeme = [MaterialData]()
                   for document in querySnapshot!.documents {
                       if let materialData = try? document.data(as: MaterialData.self) {
                           firebaseMeme.append(materialData)
                       }
                   }
                   completion(firebaseMeme, nil)
               }
           }
       }
}

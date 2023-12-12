//
//  MemeLoadStruct.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/16.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct MemeLoadDatum: Codable {
    let id: Int
    let url: URL
    let src: URL
    let author: Author
    let title: String
    let pageview: Int
    let totalLikeCount: Int
    let createdAt: CreatedAt
    let hashtag: String
    let contest: Contest
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case src
        case author
        case title
        case pageview
        case totalLikeCount = "total_like_count"
        case createdAt = "created_at"
        case hashtag
        case contest
    }
    struct Author: Codable {
        let id: Int
        let name: String
    }
    struct CreatedAt: Codable {
        let timestamp: TimeInterval
        let dateTimeString: String
        enum CodingKeys: String, CodingKey {
            case timestamp
            case dateTimeString = "date_time_string"
        }
    }
    struct Contest: Codable {
        let id: Int
        let name: String
    }
}

struct MaterialData: Codable {
    let id: String
    let hashtag: [String]
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case hashtag
        case url
    }
}

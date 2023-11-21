//
//  HotAPIstruct.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/21.
//

import Foundation

struct MemeCategory {
    let name: String
    let apiUrl: URL
}

let memeCategories: [MemeCategory] = [
    MemeCategory(name: "今日熱門", apiUrl: URL(string: "https://memes.tw/wtf/api")!),
    MemeCategory(name: "靠北工程師", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=12")!),
    MemeCategory(name: "校園生活", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=11")!),
    MemeCategory(name: "憂鬱星期一", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=5")!),
    MemeCategory(name: "垃圾話", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=6")!),
    MemeCategory(name: "兩性", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=9")!),
    MemeCategory(name: "廢物大學生", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=19")!),
    MemeCategory(name: "常常想", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=20")!),
    MemeCategory(name: "嗆人", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=21")!),
    MemeCategory(name: "出社會", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=24")!),
    MemeCategory(name: "日常生活", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=29")!),
    MemeCategory(name: "地獄梗", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=30")!),
    MemeCategory(name: "春節", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=32")!),
    MemeCategory(name: "我就爛", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=33")!),
    MemeCategory(name: "時事", apiUrl: URL(string: "https://memes.tw/wtf/api?contest=35")!)
]


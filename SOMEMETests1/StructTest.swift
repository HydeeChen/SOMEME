//
//  StructTest.swift
//  SOMEMETests1
//
//  Created by Hydee Chen on 2023/12/25.
//

import XCTest
@testable import SOMEME

// 測試struct
final class StructTest: XCTestCase { 
    func testMemeCategoryInitialization() {
           let apiUrl = URL(string: "https://memes.tw/wtf/api")!
           let memeCategory = MemeCategory(name: "Test Category", apiUrl: apiUrl)

           // 確保屬性正確初始化
           XCTAssertEqual(memeCategory.name, "Test Category")
           XCTAssertEqual(memeCategory.apiUrl, apiUrl)
       }
}

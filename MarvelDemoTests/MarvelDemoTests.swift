//
//  MarvelDemoTests.swift
//  MarvelDemoTests
//
//  Created by Berkay Sebat on 3/19/20.
//  Copyright © 2020 marvel. All rights reserved.
//

import XCTest
import CommonCrypto

class MarvelDemoTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWebserviceResponse() {
        
        let session = URLSession.shared
        
        let apiKey = "effb80dc84b84faad35bc2aae6d301bf"
        let privateKey = "471a9d5978e4083d11629f3ef22bec8b660480bb"
        let timeStamp = String(Date().timeIntervalSince1970)
        let expect = expectation(description: "Download marvel files and parse")
               guard let hash = MD5(timeStamp+privateKey+apiKey) else {
                  XCTFail()
                   return
               }
               let urlString = "http://gateway.marvel.com/v1/public/comics/1003?ts=\(timeStamp)&apikey=\(apiKey)&hash=\(hash)"
               guard let url = URL.init(string:urlString) else {
                  XCTFail()
                   return
               }
        var task = URLSessionDownloadTask.init()
               task = session.downloadTask(with: url, completionHandler: { (tempUrl, response, error) in
                   guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                     XCTFail()
                       return
                   }
                   guard let fileLocation = tempUrl else {
                    XCTFail()
                    return}
                   guard let data = try? Data.init(contentsOf: fileLocation) else {
                      XCTFail()
                       return}
                   do {
                       if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                           guard let jsonData = json["data"] as? [String:Any] else {
                           XCTFail()
                               return}
                           let jsonObj = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
                        _ = try JSONDecoder().decode(MarvelObj.self, from: jsonObj)
                        expect.fulfill()
                       } else {
                           XCTFail()
                       }
                   } catch _ as NSError {
                       XCTFail()
                   }
               })
               
               task.resume()
        
        wait(for: [expect], timeout: 15)
    }
    
    private func MD5(_ string: String) -> String? {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            var digest = [UInt8](repeating: 0, count: length)
            if let d = string.data(using: .utf8) { _ = d.withUnsafeBytes { body -> String in CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)
                return ""
                }
            }
            return (0..<length).reduce("") { $0 + String(format: "%02x", digest[$1]) } }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

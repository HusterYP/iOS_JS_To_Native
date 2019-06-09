//
//  JSManager.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/9.
//  Copyright © 2019 yuanping. All rights reserved.
//
import Foundation

class JSManager {
    public static let shared: JSManager = JSManager()

    private init() {
    }

    public func fetchJSContent() -> String {
        if let path = Bundle.main.path(forResource: "Resouce/JS.js", ofType: nil) {
            return (try? String(contentsOfFile: path)) ?? ""
        }
        return ""
    }
}

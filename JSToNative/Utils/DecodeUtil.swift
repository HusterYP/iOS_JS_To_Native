//
//  DecodeUtil.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/10.
//  Copyright © 2019 yuanping. All rights reserved.
//

import Foundation

class DecodeUtil {
    public static let shared: DecodeUtil = DecodeUtil()

    public func decodeParamFrom(url: String) -> [String: String]  {
        var dic = [String : String]()
        guard let queryItems = URLComponents(string: url)?.queryItems else { return dic }
        queryItems.forEach {
            dic[$0.name] = $0.value
        }
        return dic
    }
}

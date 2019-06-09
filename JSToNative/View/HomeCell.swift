//
//  HomeCell.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/9.
//  Copyright © 2019 yuanping. All rights reserved.
//
import UIKit

enum HomeCellType: Int {
    case BlockUrl // 拦截url方式
    case JavaScriptCore
    case WKScriptMessageHandler
    case WebViewJavascriptBridge
}

class HomeCell: UITableViewCell {
    private lazy var content: UILabel = {
        let content = UILabel(frame: .zero)
        content.font = UIFont.systemFont(ofSize: 14)
        content.numberOfLines = 0
        content.textAlignment = .center
        return content
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(content)
        content.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
    }

    public func updateContent(type: HomeCellType) {
        switch type {
        case .BlockUrl:
            content.text = "拦截URL（适用于UIWebView和WKWebView）"
        case .JavaScriptCore:
            content.text = "JavaScriptCore（只适用于UIWebView，iOS7+）"
        case .WKScriptMessageHandler:
            content.text = "WKScriptMessageHandler（只适用于WKWebView，iOS8+）"
        case .WebViewJavascriptBridge:
            content.text = "WebViewJavascriptBridge（适用于UIWebView和WKWebView，属于第三方框架）"
        }
    }
}

//
//  BlockUrlController.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/9.
//  Copyright © 2019 yuanping. All rights reserved.
//

import UIKit
import WebKit

/*
 * 拦截Url
 * 适合于UIWebView和WKWebView，这里以WKWebView为例
 */
class BlockUrlController: UIViewController {
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.layer.cornerRadius = 4
        webView.layer.borderColor = UIColor.gray.cgColor
        webView.layer.borderWidth = 1
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        navigationController?.isNavigationBarHidden = true
        let titleNavBar = TitleNavBar()
        view.addSubview(titleNavBar)
        titleNavBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
        titleNavBar.setTitle(title: "拦截Url")
        titleNavBar.hideBackImage(hide: false)
        titleNavBar.backTapped = ({ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })

        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(titleNavBar.snp.bottom).offset(20)
            make.height.equalTo(300)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        let htmlPath = Bundle.main.path(forResource: "Resouce/blockurl.html", ofType: nil)
        if let path = htmlPath {
            let htmlUrl = URL(fileURLWithPath: path)
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
        }

        let button = UIButton(frame: .zero)
        button.layer.borderWidth = 1 / UIScreen.main.scale
        button.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(button)
        button.setTitle("Send To JS", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(webView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(44)
        }
        button.addTarget(self, action: #selector(sendToJS), for: .touchUpInside)
    }

    @objc
    private func sendToJS() {
        webView.evaluateJavaScript("acceptMsg('Native发送消息给JS')") { (_, error) in
            if error == nil {
                AlertUtil.shared.alert(title: "Native To JS", msg: "Complete!")
            } else {
                AlertUtil.shared.alert(title: "Native To JS", msg: "\(error.debugDescription)")
            }
        }
    }
}

extension BlockUrlController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        if let urlStr = url, urlStr.hasPrefix("wxlocal://") {
            AlertUtil.shared.alert(title: "JS To Native", msg: urlStr)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

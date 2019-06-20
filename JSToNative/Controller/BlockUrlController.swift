//
//  BlockUrlController.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/9.
//  Copyright © 2019 yuanping. All rights reserved.
//

import UIKit
import WebKit
import Foundation

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

    private lazy var textTF: UITextField = {
        let textTF = UITextField(frame: .zero)
        textTF.placeholder = "发送给JS的信息"
        textTF.layer.borderWidth = 1 / UIScreen.main.scale
        textTF.layer.borderColor = UIColor.gray.cgColor
        textTF.layer.cornerRadius = 4
        return textTF
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
            make.height.equalTo(400)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        let htmlPath = Bundle.main.path(forResource: "Resouce/blockurl.html", ofType: nil)
        if let path = htmlPath {
            let htmlUrl = URL(fileURLWithPath: path)
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
        }

        view.addSubview(textTF)
        textTF.snp.makeConstraints { (make) in
            make.top.equalTo(webView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        let nativeToJS = UIButton(frame: .zero)
        nativeToJS.layer.borderWidth = 1 / UIScreen.main.scale
        nativeToJS.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(nativeToJS)
        nativeToJS.setTitle("Native发送给JS", for: .normal)
        nativeToJS.setTitleColor(.black, for: .normal)
        nativeToJS.snp.makeConstraints { (make) in
            make.top.equalTo(textTF.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        nativeToJS.addTarget(self, action: #selector(sendToJS), for: .touchUpInside)

        let nativeCallback = UIButton(frame: .zero)
        nativeCallback.layer.borderWidth = 1 / UIScreen.main.scale
        nativeCallback.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(nativeCallback)
        nativeCallback.setTitle("Native发送给JS并回调Native", for: .normal)
        nativeCallback.setTitleColor(.black, for: .normal)
        nativeCallback.snp.makeConstraints { (make) in
            make.top.equalTo(nativeToJS.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        nativeCallback.addTarget(self, action: #selector(nativeToJSAndCB), for: .touchUpInside)
    }

    /// Native发送给JS，JS不回调Native
    @objc
    private func sendToJS() {
        webView.evaluateJavaScript("acceptMsg('\(textTF.text ?? "")')") { (_, error) in
            if error == nil {
                AlertUtil.shared.alert(title: "Native To JS", msg: "Complete!")
            } else {
                AlertUtil.shared.alert(title: "Native To JS", msg: "\(error.debugDescription)")
            }
        }
    }

    /// Native发送给JS并回调Native
    @objc
    private func nativeToJSAndCB() {
        webView.evaluateJavaScript("nativeCallback('收到Native发送给JS消息')")
    }

    /// Native发送给JS并回调Native：JS回调Native
    @objc
    private func jsCallbackNative() {
        AlertUtil.shared.alert(title: "Native发送给JS并回调Native", msg: "JS回调Native成功")
    }
}

extension BlockUrlController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        guard let urlStr = url else { return }
        if !urlStr.hasPrefix("wxlocal://") {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            let params = DecodeUtil.shared.decodeParamFrom(url: urlStr)
            // JS发送给Native并回调JS：Native回调JS
            if let jsCallback = params["js_callback"] {
                webView.evaluateJavaScript("\(jsCallback)('Native callback JS成功')") { (_, error) in
                    if error == nil {
                        AlertUtil.shared.alert(title: "JS发送给Native并回调JS", msg: "JS调用Native成功!")
                    } else {
                        AlertUtil.shared.alert(title: "JS发送给Native并回调JS", msg: "\(error.debugDescription)")
                    }
                }
            } else if let nativeCallback = params["native_callback"] {
                /* 如何把String转化为Native的函数？
                 * Swift中respondsToSelector不起作用
                 * 参见：https://stackoverflow.com/questions/46545431/swift4-respondstoselector-not-working
                 * 有两种方式：
                 * 一种是将整个类继承自NSObject，但是Swift不支持多继承，此法一般不行
                 * 另一种是在对应的需要invoke的方法前面加上@objc
                 */
                // Native发送给JS并回调Native：JS回调Native
                let selector = NSSelectorFromString(nativeCallback)
                if self.responds(to: selector) {
                    self.perform(selector)
                }
            } else {
                // JS发送给Native，Native不回调JS
                AlertUtil.shared.alert(title: "JS To Native", msg: urlStr)
            }
        }
    }
}

//
//  MessageHandlerController.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/11.
//  Copyright © 2019 yuanping. All rights reserved.
//

import UIKit
import WebKit
import Foundation

/*
 * WKScriptMessageHandler（只适用于WKWebView，iOS8+）
 * 参考：
 * 1. https://www.jianshu.com/p/c9ceb6a824e2
 * 2. https://www.jianshu.com/p/433e59c5a9eb
 */
class MessageHandlerController: UIViewController {
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         * addScriptMessageHandler 很容易导致循环引用
         * 控制器 强引用了WKWebView, WKWebView copy(强引用了）configuration, configuration copy （强引用了）userContentController
         * userContentController 强引用了 self （控制器）
         */
        webView.configuration.userContentController.add(self, name: "sendMsgToNative")
        webView.configuration.userContentController.add(self, name: "callbackJS")
        webView.configuration.userContentController.add(self, name: "callbackNative")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "sendMsgToNative")
    }


    private func setupViews() {
        navigationController?.isNavigationBarHidden = true
        let titleNavBar = TitleNavBar()
        view.addSubview(titleNavBar)
        titleNavBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
        titleNavBar.setTitle(title: "WKScriptMessageHandler")
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
        let htmlPath = Bundle.main.path(forResource: "Resouce/messagehandler.html", ofType: nil)
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

    @objc
    private func sendToJS() {
        webView.evaluateJavaScript("acceptMsg('\(textTF.text ?? "")')") { (_, error) in
            if error != nil {
                AlertUtil.shared.alert(title: "Native发送给JS", msg: error.debugDescription)
            }
        }
    }

    @objc
    private func nativeToJSAndCB() {
        webView.evaluateJavaScript("nativeCallback('Native发送给JS成功','callbackNative')", completionHandler: nil)
    }
}

extension MessageHandlerController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "sendMsgToNative" {
            if let params = message.body as? NSDictionary {
                AlertUtil.shared.alert(title: "JS发送给Native", msg: (params["content"] as? String) ?? "")
            }
        } else if message.name == "callbackJS" {
            if let params = message.body as? NSDictionary {
                AlertUtil.shared.alert(title: "JS发送给 Native", msg: (params["content"] as? String) ?? "")
                if let jsCallback = params["callback"] as? String {
                    webView.evaluateJavaScript("\(jsCallback)('Native回调JS成功')", completionHandler: nil)
                }
            }
        } else if message.name == "callbackNative" {
            if let params = message.body as? NSDictionary {
                AlertUtil.shared.alert(title: params["title"] as? String ?? "", msg: params["msg"] as? String ?? "")
            }
        }
    }
}

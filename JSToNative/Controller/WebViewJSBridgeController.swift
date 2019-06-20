//
//  WebViewJSBridgeController.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/17.
//  Copyright © 2019 yuanping. All rights reserved.
//

import UIKit
import WebKit
import Foundation

/*
 * WebViewJavascriptBridge（适用于UIWebView和WKWebView，属于第三方框架）
 */
class WebViewJSBridgeController: UIViewController {
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
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

    private lazy var bridge: WebViewJavascriptBridge = {
        let bridge = WebViewJavascriptBridge(forWebView: webView)
        bridge!.setWebViewDelegate(self)
        return bridge!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBridge()
        setupViews()
    }

    private func setupBridge() {
        WebViewJavascriptBridge.enableLogging()
        bridge.registerHandler("sendToNative") { (data, callback) in
            if let content = data as? Dictionary<String, String> {
                let result = content["content"]
                AlertUtil.shared.alert(title: "JS发送给Native", msg: result ?? "")
            }
        }
        bridge.registerHandler("jsSendToNativeAndCBJs") { (data, callback) in
            if let content = data as? Dictionary<String, String> {
                let result = content["content"]
                AlertUtil.shared.alert(title: "JS发送给Native", msg: result ?? "")
                callback?("Native回调JS成功")
            }
        }
    }

    private func setupViews() {
        navigationController?.isNavigationBarHidden = true
        let titleNavBar = TitleNavBar()
        view.addSubview(titleNavBar)
        titleNavBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
        titleNavBar.setTitle(title: "WebViewJavascriptBridge")
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
        let htmlPath = Bundle.main.path(forResource: "Resouce/webview_js_bridge.html", ofType: nil)
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

    /// Native发送给JS
    @objc
    private func sendToJS() {
        bridge.callHandler("acceptMsg", data: "\(textTF.text ?? "")")
    }

    /// Native发送给JS并回调Native
    @objc
    private func nativeToJSAndCB() {
        bridge.callHandler("nativeCallback", data: "Native发送给JS成功") {[weak self] (data) in
            self?.jsCallbackNative(data: (data as? String) ?? "")
        }
    }

    /// Native发送给JS并回调Native：JS回调Native
    private func jsCallbackNative(data: String) {
        AlertUtil.shared.alert(title: "JS回调Native", msg: data)
    }
}

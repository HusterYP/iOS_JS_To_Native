//
//  JavaScriptCoreController.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/10.
//  Copyright © 2019 yuanping. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

/*
 * JavaScriptCore
 * JavaScriptCore（只适用于UIWebView，iOS7+）
 * WKWebView不支持JavaScriptCore的方式, 但提供messagehandler的方式为JavaScript与OC通信
 * 参考: https://www.jianshu.com/p/ac534f508fb0
 */
class JavaScriptCoreController: UIViewController {
    private lazy var webView: UIWebView = {
        let webView = UIWebView(frame: .zero)
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

    /// JS发送给Native
    // Swift注入Native闭包到JS中
    private lazy var jsCallNative: @convention(block) (String, String) -> Void = { title, msg in
        // 默认是WebThread
        DispatchQueue.main.async {
            AlertUtil.shared.alert(title: title, msg: msg)
        }
    }

    /// JS发送给Native并回调JS：Native收到JS消息并回调JS
    private lazy var nativeCallJS: @convention(block) (String, String) -> Void = { [weak self] msg, callback in
        DispatchQueue.main.async {
            AlertUtil.shared.alert(title: "JS发送给Native", msg: msg)
            self?.context?.evaluateScript("\(callback)('Native回调JS成功')")
        }
    }

    private var context: JSContext?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        titleNavBar.setTitle(title: "JavaScriptCore")
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
        let htmlPath = Bundle.main.path(forResource: "Resouce/javascriptcore.html", ofType: nil)
        if let path = htmlPath {
            let htmlUrl = URL(fileURLWithPath: path)
            webView.loadRequest(URLRequest(url: htmlUrl))
        }
        context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        let jsBlock = unsafeBitCast(jsCallNative, to: AnyObject.self)
        context?.setObject(jsBlock, forKeyedSubscript: "jsCallNative" as NSCopying & NSObjectProtocol)
        let nativeBlock = unsafeBitCast(nativeCallJS, to: AnyObject.self)
        context?.setObject(nativeBlock, forKeyedSubscript: "nativeCallJS" as NSCopying & NSObjectProtocol)

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

    /// Native发送给JS，不回调Native
    @objc
    private func sendToJS() {
        context?.evaluateScript("acceptMsg('\(textTF.text ?? "")')")
    }

    /// Native发送给JS并回调Native
    @objc
    private func nativeToJSAndCB() {
        context?.evaluateScript("nativeCallback('Native发送给JS成功')")
    }
}

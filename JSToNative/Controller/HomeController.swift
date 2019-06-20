//
//  HomeController.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/9.
//  Copyright © 2019 yuanping. All rights reserved.
//

import UIKit
import SnapKit

/*
 * JS 与Native的互相调用:
 * 1. 拦截url（适用于UIWebView和WKWebView）
 * 2. JavaScriptCore（只适用于UIWebView，iOS7+）
 * 3. WKScriptMessageHandler（只适用于WKWebView，iOS8+）
 * 4. WebViewJavascriptBridge（适用于UIWebView和WKWebView，属于第三方框架）
 */

class HomeController: UIViewController {
    private let cellIdentifier = "HomeCell"
    private let model: HomeModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.register(HomeCell.self, forCellReuseIdentifier: cellIdentifier)
        return tableView
    }()

    init() {
        model = HomeModel()
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
        titleNavBar.setTitle(title: "JS与Native通信")
        titleNavBar.hideBackImage(hide: true)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleNavBar.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
}

extension HomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.cellTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HomeCell else {
            return UITableViewCell(frame: .zero)
        }
        guard indexPath.row >= 0, indexPath.row < model.cellTypes.count else {
            return UITableViewCell(frame: .zero)
        }
        cell.updateContent(type: model.cellTypes[indexPath.row])
        return cell
    }
}

extension HomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row >= 0, indexPath.row < model.cellTypes.count else { return }
        let type = model.cellTypes[indexPath.row]
        switch type {
        case .BlockUrl:
            let blockUrlVC = BlockUrlController()
            navigationController?.pushViewController(blockUrlVC, animated: true)
        case .JavaScriptCore:
            let javaScriptCoreVC = JavaScriptCoreController()
            navigationController?.pushViewController(javaScriptCoreVC, animated: true)
        case .WKScriptMessageHandler:
            let msgHandlerController = MessageHandlerController()
            navigationController?.pushViewController(msgHandlerController, animated: true)
        case .WebViewJavascriptBridge:
            let webviewJSBridge = WebViewJSBridgeController()
            navigationController?.pushViewController(webviewJSBridge, animated: true)
        }
    }
}

class HomeModel {
    let cellTypes: [HomeCellType] = [.BlockUrl,
                                     .JavaScriptCore,
                                     .WKScriptMessageHandler,
                                     .WebViewJavascriptBridge]
}

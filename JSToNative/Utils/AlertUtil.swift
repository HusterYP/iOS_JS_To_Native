//
//  AlertUtil.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/9.
//  Copyright © 2019 yuanping. All rights reserved.
//
import UIKit

class AlertUtil {
    public static let shared: AlertUtil = AlertUtil()

    private init() {}

    public func alert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确定", style: .cancel)
        alert.addAction(confirm)
        if let vc = topViewController() {
            vc.present(alert, animated: true, completion: nil)
        }
    }

    private func topViewController(viewController: UIViewController? = nil) -> UIViewController? {
        let viewController = viewController ?? UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = viewController as? UINavigationController,
            !navigationController.viewControllers.isEmpty {
            return self.topViewController(viewController: navigationController.viewControllers.last)
        } else if let tabBarController = viewController as? UITabBarController,
            let selectedController = tabBarController.selectedViewController {
            return self.topViewController(viewController: selectedController)
        } else if let presentedController = viewController?.presentedViewController {
            return self.topViewController(viewController: presentedController)
        }
        return viewController
    }
}

//
//  TitleNavBar.swift
//  JSToNative
//
//  Created by yuanping on 2019/6/9.
//  Copyright © 2019 yuanping. All rights reserved.
//
import UIKit

class TitleNavBar: UIView {
    private lazy var topView: UIView = {
        let topView = UIView(frame: .zero)
        return topView
    }()

    private lazy var contentView: UIView = {
        let contentView = UIView(frame: .zero)
        return contentView
    }()

    private lazy var splitLine: UIView = {
        let split = UIView(frame: .zero)
        split.backgroundColor = .gray
        return split
    }()

    private lazy var title: UILabel = {
        let title = UILabel(frame: .zero)
        title.font = UIFont.boldSystemFont(ofSize: 22)
        return title
    }()

    private lazy var backImg: UIImageView = {
        let backImg = UIImageView(frame: .zero)
        backImg.image = UIImage(named: "back")
        backImg.isUserInteractionEnabled = true
        backImg.contentMode = .scaleAspectFit
        return backImg
    }()

    public var backTapped: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 11, *) {
            topView.snp.updateConstraints { (make) in
                make.height.equalTo(safeAreaInsets.top)
            }
        }
    }

    private func setupView() {
        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }

        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(44)
            make.leading.bottom.trailing.equalToSuperview()
        }

        contentView.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        contentView.addSubview(backImg)
        backImg.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backTap))
        backImg.addGestureRecognizer(backGesture)

        contentView.addSubview(splitLine)
        splitLine.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }
    }

    public func setTitle(title: String) {
        self.title.text = title
    }

    public func hideBackImage(hide: Bool) {
        backImg.isHidden = hide
    }

    @objc
    private func backTap() {
        if let callback = backTapped {
            callback()
        }
    }
}

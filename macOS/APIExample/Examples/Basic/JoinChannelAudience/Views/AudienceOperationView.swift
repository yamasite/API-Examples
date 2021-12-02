//
//  AudienceOperationView.swift
//  APIExample
//
//  Created by zhaoyongqiang on 2021/12/1.
//  Copyright © 2021 Agora Corp. All rights reserved.
//

import Cocoa

class AudienceOperationView: NSView {
    var onClickPageButtonClosure: ((Bool) -> Void)?
    
    private lazy var nextButton: NSButton = {
        let button = NSButton()
        button.wantsLayer = true
        button.bezelStyle = .regularSquare
        button.setButtonType(.momentaryPushIn)
        button.title = "下一页"
        button.font = .systemFont(ofSize: 14)
        button.target = self
        button.action = #selector(clickNextButton(sender:))
        return button
    }()
    
    private lazy var preButton: NSButton = {
        let button = NSButton()
        button.wantsLayer = true
        button.bezelStyle = .regularSquare
        button.setButtonType(.momentaryPushIn)
        button.title = "上一页"
        button.font = .systemFont(ofSize: 14)
        button.target = self
        button.action = #selector(clickPreButton(sender:))
        return button
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        preButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(nextButton)
        addSubview(preButton)
        
        nextButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        nextButton.topAnchor.constraint(equalTo: topAnchor,constant: 20).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        preButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        preButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 25).isActive = true
        preButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        preButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        preButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
    }
    
    @objc
    private func clickNextButton(sender: NSButton) {
        onClickPageButtonClosure?(true)
    }
    
    @objc
    private func clickPreButton(sender: NSButton) {
        onClickPageButtonClosure?(false)
    }
}

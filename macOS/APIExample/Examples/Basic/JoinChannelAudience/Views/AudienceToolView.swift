//
//  AudienceToolView.swift
//  APIExample
//
//  Created by zhaoyongqiang on 2021/11/30.
//  Copyright © 2021 Agora Corp. All rights reserved.
//

import Cocoa

class AudienceToolView: NSView {
    var onClickJoinButtonClosure: ((String, Bool) -> Void)?
    
    private lazy var channelLabel: NSText = {
        let text = NSText()
        text.wantsLayer = true
        text.textColor = .white
        text.string = "Channel".localized
        text.font = .systemFont(ofSize: 14)
        return text
    }()
    private lazy var textField: NSTextField = {
        let textField = NSTextField()
        textField.textColor = .white
        textField.wantsLayer = true
        textField.placeholderString = "Channel Name".localized
        textField.font = .systemFont(ofSize: 14)
        textField.stringValue = "vos128demo-0"
        return textField
    }()
    private lazy var joinButton: NSButton = {
        let button = NSButton()
        button.wantsLayer = true
        button.bezelStyle = .rounded
        button.setButtonType(.momentaryPushIn)
        button.title = "Join Channel".localized
        button.font = .systemFont(ofSize: 14)
        button.target = self
        button.action = #selector(clickJoinButton(sender:))
        return button
    }()
    public var isJoin: Bool = false {
        didSet {
            let title = isJoin ? "Leave Channel" : "Join Channel"
            joinButton.title = title.localized
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        channelLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(channelLabel)
        addSubview(textField)
        addSubview(joinButton)
        
        channelLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        channelLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        channelLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        channelLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        textField.leadingAnchor.constraint(equalTo: channelLabel.leadingAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: channelLabel.bottomAnchor, constant: 5).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        joinButton.leadingAnchor.constraint(equalTo: textField.leadingAnchor).isActive = true
        joinButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10).isActive = true
        joinButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor).isActive = true
        joinButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        joinButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
    }
    
    @objc
    private func clickJoinButton(sender: NSButton) {
        if isJoin {
            textField.stringValue = ""
        }
        isJoin = !isJoin
        onClickJoinButtonClosure?(textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines),
                                  isJoin)
    }
}

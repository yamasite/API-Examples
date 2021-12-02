//
//  JoinChannelAudienceCell.swift
//  APIExample
//
//  Created by zhaoyongqiang on 2021/11/30.
//  Copyright © 2021 Agora Corp. All rights reserved.
//

import Cocoa
import AGEVideoLayout

class JoinChannelAudienceCell: NSCollectionViewItem {

    override func loadView() {
        view = AGEView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.backgroundColor = AGEColor(red: CGFloat.random(in: 0...255)/255, green: CGFloat.random(in: 0...255)/255, blue: CGFloat.random(in: 0...255)/255, alpha: 1.0)
    }
    
}

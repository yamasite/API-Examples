//
//  JoinChannelAudience.swift
//  APIExample
//
//  Created by zhaoyongqiang on 2021/11/30.
//  Copyright © 2021 Agora Corp. All rights reserved.
//

import Cocoa
import AGEVideoLayout
import AgoraRtcKit

class JoinChannelAudience: BaseViewController {
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.documentView = collectionView
        scrollView.verticalScrollElasticity = .none
        scrollView.scrollerStyle = .overlay
        
//        scrollView.contentView.postsBoundsChangedNotifications = true
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(boundsDidChangeNotification(notification:)),
//                                               name: NSView.boundsDidChangeNotification,
//                                               object: scrollView.contentView)
        return scrollView
    }()
    private lazy var flowLayout: NSCollectionViewFlowLayout = {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
    private lazy var collectionView: NSCollectionView = {
        let view = NSCollectionView(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.wantsLayer = true
        view.isSelectable = true
        view.allowsMultipleSelection = false
        view.collectionViewLayout = flowLayout
        return view
    }()
    
    private lazy var toolView: AGEView = {
        let view = AGEView()
        return view
    }()
    
    private lazy var channelView = AudienceToolView()
    private lazy var operationView = AudienceOperationView()
    
    private lazy var agoraKit: AgoraRtcEngineKit = {
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.areaCode = GlobalSettings.shared.area.rawValue
        let agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        agoraKit.setParameters("{\"rtc.vos_list\":[\"36.150.9.164\"]}")
        agoraKit.setClientRole(.audience)
        agoraKit.enableVideo()
        agoraKit.setChannelProfile(.liveBroadcasting)
        return agoraKit
    }()
    private lazy var mediaOption: AgoraRtcChannelMediaOptions = {
        let option = AgoraRtcChannelMediaOptions()
        option.autoSubscribeAudio = false
        option.autoSubscribeVideo = false
        return option
    }()
    private var dataArray = [AgoraRtcVideoCanvas]()
    private var isJoinChannel: Bool = false
    private var lastPoint: CGPoint = .zero
    private var itemCount: CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        eventHandler()
        createData()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        leaveChannel()
        AgoraRtcEngineKit.destroy()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        let itemH = collectionView.visibleRect.height / itemCount
        flowLayout.itemSize = CGSize(width: itemH, height: itemH)
    }
    
    private func createData() {
        for i in 1...100 {
            let canvas = AgoraRtcVideoCanvas()
            canvas.renderMode = .hidden
            canvas.uid = UInt(i)
            dataArray.append(canvas)
        }
        collectionView.reloadData()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(toolView)
        
        collectionView.register(JoinChannelAudienceCell.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AudienceItemView"))
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        toolView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        toolView.leadingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        toolView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        toolView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolView.widthAnchor.constraint(equalToConstant: 313).isActive = true
        
        channelView.translatesAutoresizingMaskIntoConstraints = false
        toolView.addSubview(channelView)
        
        channelView.leadingAnchor.constraint(equalTo: toolView.leadingAnchor).isActive = true
        channelView.bottomAnchor.constraint(equalTo: toolView.bottomAnchor).isActive = true
        channelView.trailingAnchor.constraint(equalTo: toolView.trailingAnchor).isActive = true
        
        operationView.translatesAutoresizingMaskIntoConstraints = false
        toolView.addSubview(operationView)
        
        operationView.leadingAnchor.constraint(equalTo: toolView.leadingAnchor).isActive = true
        operationView.topAnchor.constraint(equalTo: toolView.topAnchor).isActive = true
        operationView.trailingAnchor.constraint(equalTo: toolView.trailingAnchor).isActive = true
    }
    
    private func eventHandler() {
        channelView.onClickJoinButtonClosure = { [weak self] channelName, isJoin in
            if channelName.isEmpty && isJoin {
                self?.channelView.isJoin = false
                self?.showAlert(title: "Channel Name".localized, message: "")
                return
            }
            self?.isJoinChannel = isJoin
            if isJoin {
                self?.joinChannel(channel: channelName, uid: 0)
            } else {
                self?.leaveChannel()
            }
        }
        
        operationView.onClickPageButtonClosure = { [weak self] isNext in
            guard let self = self else { return }
            let contentSize = self.scrollView.documentView?.frame.size ?? .zero
            let itemW = self.collectionView.visibleRect.height / self.itemCount
            if isNext {
                var offsetX = self.lastPoint.x + itemW * self.itemCount
                offsetX = offsetX > contentSize.width ? contentSize.width : offsetX
                let point = NSPoint(x: offsetX, y: 0)
                self.collectionView.scroll(point)
                self.lastPoint = point
            } else {
                var offsetX = self.lastPoint.x - itemW * self.itemCount
                offsetX = offsetX < 0 ? 0 : offsetX
                let point = NSPoint(x: offsetX, y: 0)
                self.collectionView.scroll(point)
                self.lastPoint = point
            }
        }
    }
    
    private func joinChannel(channel: String, uid: UInt) {
        let result = agoraKit.joinChannel(byToken: KeyCenter.Token,
                                          channelId: channel,
                                          info: nil,
                                          uid: uid,
                                          options: mediaOption)
        if result != 0 {
            // Usually happens with invalid parameters
            // Error code description can be found at:
            // en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
            // cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
            showAlert(title: "Error", message: "joinChannel call failed: \(result), please check your params")
        }
        collectionView.reloadData()
    }
    
    private func leaveChannel() {
        agoraKit.leaveChannel { state in
            LogUtils.log(message: "Left channel == \(state)", level: .info)
        }
        collectionView.reloadData()
    }
    
    private func muteRemoteAudioStream(uid: UInt, isMute: Bool) {
        agoraKit.muteRemoteAudioStream(uid, mute: isMute)
        agoraKit.muteRemoteVideoStream(uid, mute: isMute)
    }
}
extension JoinChannelAudience: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        isJoinChannel ? dataArray.count : 0
    }
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let itemView = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AudienceItemView"), for: indexPath)
        let canvas = dataArray[indexPath.item]
        canvas.view = itemView.view
        agoraKit.setupRemoteVideo(canvas)
        return itemView
    }
    
    func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        let model = dataArray[indexPath.item]
        muteRemoteAudioStream(uid: model.uid, isMute: false)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        let model = dataArray[indexPath.item]
        muteRemoteAudioStream(uid: model.uid, isMute: true)
    }
}

extension JoinChannelAudience: AgoraRtcEngineDelegate {
    /// callback when the local user joins a specified channel.
    /// @param channel
    /// @param uid uid of local user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        LogUtils.log(message: "Join \(channel) with uid \(uid) elapsed \(elapsed)ms", level: .info)
    }
    
    /// callback when a remote user is joinning the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        LogUtils.log(message: "remote user join: \(uid) \(elapsed)ms", level: .info)
    }
    
    /// callback when a remote user is leaving the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param reason reason why this user left, note this event may be triggered when the remote user
    /// become an audience in live broadcasting profile
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        LogUtils.log(message: "remote user left: \(uid) reason \(reason)", level: .info)
    }
}

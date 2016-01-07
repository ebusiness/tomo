//
//  JSQMessageEntity.swift
//  Tomo
//
//  Created by starboychina on 2015/08/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Alamofire

class JSQMessageEntity:NSObject, JSQMessageData {
    
    var message: MessageEntity!
    var brokenImage: UIImage?
    
    private let broken = UIImage(named: "file_broken")!
    private var isTaskRunning: Bool = false
    private var taskTryCount = 2
    
    override init() {
        super.init()
        self.message = MessageEntity()
    }
    
    init(message: MessageEntity) {
        self.message = message
    }
    
    func senderId() -> String! {
        return message.from.id
    }
    
    func senderDisplayName() -> String! {
        return message.from.nickName
    }
    
    func date() -> NSDate! {
        return message.createDate
    }
    
    func isMediaMessage() -> Bool {
        if MediaMessage.isMediaMessage(message.content) {
            return true
        }
        
        return false
    }
    
    func text() -> String! {
        return message.content
    }
    
    func messageHash() -> UInt {
        return UInt(bitPattern: message.hash)
    }
    
    func media() -> JSQMessageMediaData! {
        guard let name = MediaMessage.fileNameOfMessage(message.content) else { return nil }
        guard let mediaMessageType = MediaMessage.mediaMessage(message.content) else { return nil }
        
        var item: JSQMediaItem!
        
        let fileUrl = FCFileManager.urlForItemAtPath(name)
        
        switch mediaMessageType {
        case .Video:
            
            item = TomoVideoMediaItem(fileURL: fileUrl, isReadyToPlay: true)
            
        case .Image:
            
            if FCFileManager.existsItemAtPath(name) {
                item = JSQPhotoMediaItem(image: UIImage(contentsOfFile: fileUrl.path!))
            } else {
                item = JSQPhotoMediaItem(image: self.brokenImage)
            }
            
        case .Voice:
            
            let imageName = message.from.id == me.id ? "SenderVoiceNodePlaying" : "ReceiverVoiceNodePlaying"
            let image = UIImage(named: imageName)
            if FCFileManager.existsItemAtPath(name) {
                item = JSQVoiceMediaItem(voice: NSData(contentsOfFile: fileUrl.path!), image: image)
            } else {
                item = JSQVoiceMediaItem(voice: nil, image: image)
            }
            
        }
        
        item.appliesMediaViewMaskAsOutgoing = message.from.id == me.id
        return item
    }
    
    func download(completion: ()->() ){
        if self.isTaskRunning || self.brokenImage != nil {
            return
        } else {
            self.isTaskRunning = true
        }
        
        guard
            let name = MediaMessage.fileNameOfMessage(message.content)
            where MediaMessage.mediaMessage(message.content) == .Image && !FCFileManager.existsItemAtPath(name)
            else {
                return
        }
        
        let url = MediaMessage.fullPath(message.content)
        
        Manager.sharedInstance.download(.GET, url) { (tempUrl, res) -> (NSURL) in
            if res.statusCode == 200 {
                return FCFileManager.urlForItemAtPath(name)
            } else {
                return tempUrl
            }
            }.response { (_, _, _, error) -> Void in
                self.isTaskRunning = false
                
                if error != nil {
                    self.taskTryCount--
                    if self.taskTryCount > 0 { //auto reload
                        self.download(completion)
                    } else {
                        self.brokenImage = self.broken
                        completion()
                    }
                } else {
                    completion() // reload collectionView
                }
        }
    }
    
    func reload(completion: ()->() ){
        if self.taskTryCount < -2 {
            return
        }
        self.brokenImage = nil
        self.download(completion)
    }
}


enum MediaMessage: Int {
    case Image, Voice, Video
    
    static let medias = [Image, Voice, Video]
    
    static func isMediaMessage(str: String) -> Bool {
        for media in medias {
            if str.hasPrefix(media.messagePrefix) {
                return true
            }
        }
        return false
    }
    
    static func mediaMessage(str: String) -> MediaMessage? {
        for media in medias {
            if str.hasPrefix(media.messagePrefix) {
                return media
            }
        }
        
        return nil
    }
    
    static func fileNameOfMessage(str: String) -> String? {
        for media in medias {
            if str.hasPrefix(media.messagePrefix) {
                return str[media.messagePrefix.length..<str.length]!
            }
        }
        return nil
    }
    
    static func messagePrefix(str: String) -> String? {
        return mediaMessage(str)?.messagePrefix
    }
    
    var messagePrefix: String {
        get {
            switch self {
            case .Image:
                return "[photo]"
            case .Voice:
                return "[voice]"
            case .Video:
                return "[video]"
            }
        }
    }
    
    static func remotePath(fileName name: String, type: MediaMessage) -> String {
        switch type {
        case .Image:
            return "/messages/images/\(name)"
        case .Voice:
            return "/messages/voices/\(name)"
        case .Video:
            return "/messages/videos/\(name)"
        }
    }
    
    static func mediaMessageStr(fileName name: String, type: MediaMessage) -> String {
        return "\(type.messagePrefix)\(name)"
    }
    
    static func fullPath(str: String) -> String {
        let fileName = fileNameOfMessage(str)!
        let type = mediaMessage(str)!
        return self.fullPath(fileName: fileName, type: type)
    }
    
    static func fullPath(fileName name: String, type: MediaMessage) -> String {
        let remote = remotePath(fileName: name, type: type)
        return "\(TomoConfig.AWS.S3.Url)/\(TomoConfig.AWS.S3.Bucket)\(remote)"
    }
}

//
//  JSQMessageEntity.swift
//  Tomo
//
//  Created by starboychina on 2015/08/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


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
        if let name = MediaMessage.fileNameOfMessage(message.content) {
            if FCFileManager.existsItemAtPath(name) {
                var item: JSQMediaItem!
                
                if MediaMessage.mediaMessage(message.content) == .Image {
                    item = JSQPhotoMediaItem(image: UIImage(contentsOfFile: FCFileManager.urlForItemAtPath(name).path!))
                } else if MediaMessage.mediaMessage(message.content) == .Voice {
                    let imageName = message.from.id == me.id ? "SenderVoiceNodePlaying" : "ReceiverVoiceNodePlaying"
                    item = JSQVoiceMediaItem(voice: NSData(contentsOfFile: FCFileManager.urlForItemAtPath(name).path!), image: UIImage(named: imageName))
                } else if MediaMessage.mediaMessage(message.content) == .Video {
                    item = TomoVideoMediaItem(fileURL: FCFileManager.urlForItemAtPath(name), isReadyToPlay: true)
                }
                
                item.appliesMediaViewMaskAsOutgoing = message.from.id == me.id
                
                return item
            } else {
                var item: JSQMediaItem!
                if MediaMessage.mediaMessage(message.content) == .Image {
                    item = JSQPhotoMediaItem(image: self.brokenImage)
                } else if MediaMessage.mediaMessage(message.content) == .Voice {
                    let imageName = message.from.id == me.id ? "SenderVoiceNodePlaying" : "ReceiverVoiceNodePlaying"
                    item = JSQVoiceMediaItem(voice: nil, image: UIImage(named: imageName))
                } else if MediaMessage.mediaMessage(message.content) == .Video {
                    item = TomoVideoMediaItem(fileURL: FCFileManager.urlForItemAtPath(name), isReadyToPlay: true)
                }
                
                item.appliesMediaViewMaskAsOutgoing = message.from.id == me.id
                return item
            }
        }
        
        return nil
    }
    
    func download(completion: ()->() ){
        if self.isTaskRunning || self.brokenImage != nil {
            return
        } else {
            self.isTaskRunning = true
        }
        
        if let name = MediaMessage.fileNameOfMessage(message.content) where MediaMessage.mediaMessage(message.content) == .Image && !FCFileManager.existsItemAtPath(name) {
            
            let url = MediaMessage.fullPath(message.content)
            Manager.sharedInstance.download(.GET, url) { (tempUrl, res) -> (NSURL) in
                if res.statusCode == 200 {
                    return FCFileManager.urlForItemAtPath(name)
                } else {
                    return tempUrl
                }
            }.response { (_, _, _, error) -> Void in
                self.isTaskRunning = false
                
                if let error = error {
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
                return str.substringFromIndex(advance(str.startIndex, media.messagePrefix.length))
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
    
    static func remotePath(#fileName: String, type: MediaMessage) -> String {
        switch type {
        case .Image:
            return "/messages/images/\(fileName)"
        case .Voice:
            return "/messages/voices/\(fileName)"
        case .Video:
            return "/messages/videos/\(fileName)"
        }
    }
    
    static func mediaMessageStr(#fileName: String, type: MediaMessage) -> String {
        return "\(type.messagePrefix)\(fileName)"
    }
    
    static func fullPath(str: String) -> String {
        return kS3BasePath.stringByAppendingPathComponent(AmazonS3Bucket).stringByAppendingPathComponent(remotePath(fileName: fileNameOfMessage(str)!, type: mediaMessage(str)!))
    }
    
    static func fullPath(#fileName: String, type: MediaMessage) -> String {
        return kS3BasePath.stringByAppendingPathComponent(AmazonS3Bucket).stringByAppendingPathComponent(remotePath(fileName: fileName, type: type))
    }
}

//
//  JSQMessageEntity.swift
//  Tomo
//
//  Created by starboychina on 2015/08/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


class JSQMessageEntity:NSObject, JSQMessageData {
    
    var message:MessageEntity!
    
    override init() {
        super.init()
        self.message = MessageEntity()
    }
    
    init(message:MessageEntity) {
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
                //do not download voice and video
                if MediaMessage.mediaMessage(message.content) == .Image {
                    download(.GET, MediaMessage.fullPath(message.content), { (tempUrl, res) -> (NSURL) in
                        gcd.async(.Main, closure: { () -> () in
                            NSNotificationCenter.defaultCenter().postNotificationName("NotificationDownloadMediaDone", object: nil)
                        })
                        return FCFileManager.urlForItemAtPath(name)
                    })
                }
                
                var item: JSQMediaItem!
                if MediaMessage.mediaMessage(message.content) == .Image {
                    item = JSQPhotoMediaItem(image: nil)
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
}

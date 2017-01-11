//
//  JSQMessageEntity.swift
//  Tomo
//
//  Created by starboychina on 2015/08/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Alamofire

class JSQMessageEntity: MessageEntity, JSQMessageData {

    
//    var message: MessageEntity!
    var brokenImage: UIImage?
    
    private let broken = UIImage(named: "file_broken")!
    private var isTaskRunning: Bool = false
    private var taskTryCount = 2
    
    func senderId() -> String! {
        return self.from.id
    }
    
    func senderDisplayName() -> String! {
        return self.from.nickName
    }
    
    public func date() -> Date! {
        return self.createDate
    }
    
    func isMediaMessage() -> Bool {
        return self.type != .text
    }
    
    func messageHash() -> UInt {
        return UInt(bitPattern: self.hash)
    }
    
    func text() -> String! {
        return self.content
    }
    
    func media() -> JSQMessageMediaData! {
        if !isMediaMessage() { return nil }
        if self.content.characters.count < 1 { return nil }
        
        var item: JSQMediaItem!
        
        let fileUrl = FCFileManager.urlForItem(atPath: self.content)
        
        switch self.type {
        case .video:
            
            item = TomoVideoMediaItem(fileURL: fileUrl, isReadyToPlay: true)
            
        case .photo:
            
            if FCFileManager.existsItem(atPath: self.content) {
                item = JSQPhotoMediaItem(image: UIImage(contentsOfFile: fileUrl!.path))
            } else {
                item = JSQPhotoMediaItem(image: self.brokenImage)
            }
            
        case .voice:
            
            let imageName = self.from.id == me.id ? "SenderVoiceNodePlaying" : "ReceiverVoiceNodePlaying"
            let image = UIImage(named: imageName)
            if FCFileManager.existsItem(atPath: self.content) {
                item = JSQVoiceMediaItem(voice: NSData(contentsOfFile: (fileUrl?.path)!) as Data!, image: image)
            } else {
                item = JSQVoiceMediaItem(voice: nil, image: image)
            }
        default:
            return nil
        }
        
        item.appliesMediaViewMaskAsOutgoing = self.from.id == me.id
        return item
    }
    
    func download(_ completion: @escaping ()->() ){
        if self.isTaskRunning || self.brokenImage != nil {
            return
        } else {
            self.isTaskRunning = true
        }
        
        guard
            self.type == .photo && !FCFileManager.existsItem(atPath: self.content)
            else {
                return
        }
        
        let url = self.type.fullPath(name: self.content)
        
//        Alamofire.SessionManager.default.download(.get, method: url) { (tempUrl, res) -> (NSURL) in
//            if res.statusCode == 200 {
//                return FCFileManager.urlForItemAtPath(self.content)
//            } else {
//                return tempUrl
//            }
//            }.response { (_, _, _, error) -> Void in
//                self.isTaskRunning = false
//                
//                if error != nil {
//                    self.taskTryCount--
//                    if self.taskTryCount > 0 { //auto reload
//                        self.download(completion)
//                    } else {
//                        self.brokenImage = self.broken
//                        completion()
//                    }
//                } else {
//                    completion() // reload collectionView
//                }
//        }
    }
    
    func reload(completion: @escaping ()->() ){
        if self.taskTryCount < -2 {
            return
        }
        self.brokenImage = nil
        self.download(completion)
    }
}

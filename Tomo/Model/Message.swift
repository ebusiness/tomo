@objc(Message)
class Message: _Message {

    class func latestDate() -> NSDate? {
        let message = self.MR_findAllWithPredicate(NSPredicate(format: "createDate==max(createDate)")).first as? Message
        return message?.createDate
    }

}

extension Message: JSQMessageData {
    
    func senderId() -> String! {
        return from?.id
    }
    
    func senderDisplayName() -> String! {
        return from?.nickName
    }
    
    func date() -> NSDate! {
        return createDate
    }
    
    func isMediaMessage() -> Bool {
        if let content = content where MediaMessage.isMediaMessage(content) {
            return true
        }
    
        return false
    }
    
    func text() -> String! {
        return content
    }
    
    func messageHash() -> UInt {
        return UInt(bitPattern: hash)
    }
    
    func media() -> JSQMessageMediaData! {
        if let content = content, name = MediaMessage.fileNameOfMessage(content) {
            if FCFileManager.existsItemAtPath(name) {
                var item: JSQMediaItem!
                
                if MediaMessage.mediaMessage(content) == .Image {
                    item = JSQPhotoMediaItem(image: UIImage(contentsOfFile: FCFileManager.urlForItemAtPath(name).path!))
                } else if MediaMessage.mediaMessage(content) == .Voice {
                    let imageName = from?.id == Defaults["myId"].string ? "SenderVoiceNodePlaying" : "ReceiverVoiceNodePlaying"
                    item = JSQVoiceMediaItem(voice: NSData(contentsOfFile: FCFileManager.urlForItemAtPath(name).path!), image: UIImage(named: imageName))
                } else if MediaMessage.mediaMessage(content) == .Video {
                    item = TomoVideoMediaItem(fileURL: FCFileManager.urlForItemAtPath(name), isReadyToPlay: true)
                }
                
                item.appliesMediaViewMaskAsOutgoing = from?.id == Defaults["myId"].string

                return item
            } else {
                //do not download voice and video
                if MediaMessage.mediaMessage(content) == .Image {
                    download(.GET, MediaMessage.fullPath(content), { (tempUrl, res) -> (NSURL) in
                        gcd.async(.Main, closure: { () -> () in
                            NSNotificationCenter.defaultCenter().postNotificationName("NotificationDownloadMediaDone", object: nil)
                        })
                        return FCFileManager.urlForItemAtPath(name)
                    })
                }
                
                var item: JSQMediaItem!
                if MediaMessage.mediaMessage(content) == .Image {
                    item = JSQPhotoMediaItem(image: nil)
                } else if MediaMessage.mediaMessage(content) == .Voice {
                    let imageName = from?.id == Defaults["myId"].string ? "SenderVoiceNodePlaying" : "ReceiverVoiceNodePlaying"
                    item = JSQVoiceMediaItem(voice: nil, image: UIImage(named: imageName))
                } else if MediaMessage.mediaMessage(content) == .Video {
                    item = TomoVideoMediaItem(fileURL: FCFileManager.urlForItemAtPath(name), isReadyToPlay: true)
                }
                
                item.appliesMediaViewMaskAsOutgoing = from?.id == Defaults["myId"].string
                return item
            }
        }
        
        return nil
    }
}
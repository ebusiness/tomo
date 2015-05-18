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
        return from?.fullName()
    }
    
    func date() -> NSDate! {
        return createDate
    }
    
    func isMediaMessage() -> Bool {
        if let content = content where content.hasPrefix(imageMessagePrefix) {
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
        if let content = content {
            let name = content.substringFromIndex(advance(content.startIndex, imageMessagePrefix.length))
            if FCFileManager.existsItemAtPath(name) {
                let item = JSQPhotoMediaItem(image: UIImage(contentsOfFile: FCFileManager.urlForItemAtPath(name).path!))
                item.appliesMediaViewMaskAsOutgoing = from?.id == Defaults["myId"].string
                return item
            } else {
                download(.GET, Constants.imageFullPath(fileName: name), { (tempUrl, res) -> (NSURL) in
                    gcd.async(.Main, closure: { () -> () in
                        NSNotificationCenter.defaultCenter().postNotificationName("NotificationDownloadMediaDone", object: nil)
                    })
                    return FCFileManager.urlForItemAtPath(name)
                })
                
                let item = JSQPhotoMediaItem(image: nil)
                item.appliesMediaViewMaskAsOutgoing = from?.id == Defaults["myId"].string
                return item
            }
        }
        
        return nil
    }
}
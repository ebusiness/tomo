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
    
//    func media() -> JSQMessageMediaData! {
//        if let content = content {
//            content.substringFromIndex(content.rangeOfString(<#aString: String#>, options: <#NSStringCompareOptions#>, range: <#Range<String.Index>?#>, locale: <#NSLocale?#>))
//        }
//        JSQPhotoMediaItem(image: <#UIImage!#>)
//    }
}
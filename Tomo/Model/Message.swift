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
        return false
    }
    
    func text() -> String! {
        return content
    }
    
    func messageHash() -> UInt {
        return UInt(hash)
    }
    
}
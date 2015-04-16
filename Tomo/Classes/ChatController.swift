//
//  ChatController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/10.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ChatController: DBController {
   
    /*
    class func startPrivateChat(#user1: User, user2: User) -> String {
//        let groupId = user1.id! + user2.id!
        let groupId = makeGroupId(user1: user1, user2: user2)
        createMessageItem(user: user1, groupId: groupId, displayName: user2.fullName())
        createMessageItem(user: user2, groupId: groupId, displayName: user1.fullName())
        
        return groupId
    }
    
    class func makeGroupId(#user1: User, user2: User) -> String {
        return user1.id!.compare(user2.id!) == .OrderedAscending ? user1.id! + user2.id! : user2.id! + user1.id!
    }
    
    class func createMessageItem(#user: User, groupId: String, displayName: String) {
        
        if messages(user: user, groupId: groupId) == nil {
            let messages = Messages.MR_createEntity() as! Messages
            messages.user = user
            messages.groupId = groupId
            messages.displayName = displayName
            messages.lastUser = myUser()
            messages.lastMessage = ""
            messages.createdAt = NSDate()
            
            save()
        }
    }
    
    class func messages(#user: User, groupId: String) -> Messages? {
        return Messages.MR_findFirstWithPredicate(NSPredicate(format: "user = %@ AND groupId = %@",user, groupId)) as? Messages
    }
    
    class func chatsByGroupId(groupId: String, after: NSDate?) -> [Chat] {
        if let after = after {
            return Chat.MR_findAllSortedBy("createdAt", ascending: true, withPredicate: NSPredicate(format: "createdAt > %@", after)) as! [Chat]
        }
        
        return Chat.MR_findByAttribute("groupId", withValue: groupId, andOrderBy: "createdAt", ascending: true) as! [Chat]
    }
    
    class func createChat(groupId: String, text: String) {
        let chat = Chat.MR_createEntity() as! Chat
        chat.groupId = groupId
        chat.text = text
        chat.createdAt = NSDate()
        chat.user = myUser()
        
        save()
    }
    
    class func updateMessage(groupId: String, text: String) {
        let messages = Messages.MR_findByAttribute("groupId", withValue: groupId) as! [Messages]
        for message in messages {
            let user = message.user
            message.lastUser = myUser()
            message.lastMessage = text
            message.updatedAt = NSDate()
        }
        
        save()
}
    
        */
    
    class func createMessage(user: User, text: String) {
        let message = Message.MR_createEntity() as! Message
        message.to = NSOrderedSet(array: [user])
        message.content = text
        message.subject = "no subject"
        message.from = myUser()
        message.createDate = NSDate()
        
        save()
    }
    
    /*
    class func addChat(dic: NSDictionary) {
        // TODO: if not exist
        
        let user = User.MR_findFirstByAttribute("id", withValue: (dic["_from"] as! NSDictionary) ["_id"]) as! User
        let groupId = makeGroupId(user1: user, user2: myUser())
        
        let chat = Chat.MR_createEntity() as! Chat
        chat.groupId = groupId
        chat.text = dic["content"] as? String
        chat.createdAt = NSDate()
        chat.user = user
    }*/
    
    // TODO: 群聊
    class func messageWithUser(user: User) -> NSFetchedResultsController {
        return Message.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "from=%@ OR (to.@count = 1 AND ANY to.id=%@)", user, user.id!), sortedBy: "createDate", ascending: true)
    }
    
    class func latestMessage() -> Message {
        return Message.MR_findFirstOrderedByAttribute("createDate", ascending: false) as! Message
    }
    
    /*
    // MARK: - Test
    
    class func createChatFrom(userId: String) {
        
    }
    
    class func createChatFrom(#user: User, groupId: String) {
        let chat = Chat.MR_createEntity() as! Chat
        chat.groupId = groupId
        chat.text = NSUUID().UUIDString
        chat.createdAt = NSDate()
        chat.user = user
        
        save()
    }*/

}

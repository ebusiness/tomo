//
//  ChatController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/10.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ChatController: DBController {
   
    class func startPrivateChat(#user1: User, user2: User) -> String {
        let groupId = user1.id! + user2.id!
        
        createMessageItem(user: user1, groupId: groupId, displayName: user2.fullName())
        createMessageItem(user: user2, groupId: groupId, displayName: user1.fullName())
        
        return groupId
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
    
    
    class func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
    }
    
    // MARK: - Test
    
    class func createChatFrom(#user: User, groupId: String) {
        let chat = Chat.MR_createEntity() as! Chat
        chat.groupId = groupId
        chat.text = NSUUID().UUIDString
        chat.createdAt = NSDate()
        chat.user = user
        
        save()
    }

}

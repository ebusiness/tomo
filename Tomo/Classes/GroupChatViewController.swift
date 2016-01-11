//
//  GroupChatViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/18.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit
import SwiftyJSON
import MobileCoreServices

final class GroupChatViewController: CommonMessageController {
    
    var group: GroupEntity!
    
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    var oldestMessage: MessageEntity?
    
    var isLoading = false
    var isExhausted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // page title
        title = group.name
        
        //receive notification
        self.registerForNotifications()
        
        // load avatar
        self.loadAvatars()

        self.loadMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        guard let groups = me.groups where groups.contains(self.group.id) else {
//            self.navigationController?.popViewControllerAnimated(true)
//            return
//        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // open all message when leave
        Router.GroupMessage.FindByGroupId(id: self.group.id, before: nil).request
    }
}

// MARK: - Private Methods

extension GroupChatViewController {
    
    private func loadAvatars() {
        self.group.members?.forEach { user in
            self.avatars[user.id] = self.defaultAvatar
        }
        
        Router.Group.FindById(id: self.group.id).response {
            if $0.result.isFailure { return }
            
            self.group = GroupEntity($0.result.value!)
            guard let members = self.group.members else {return}
            
            members.forEach {
                self.loadAvatarForUser($0)
            }
        }
    }
    
    private func loadAvatarForUser(user: UserEntity){

        if user.id == me.id {
            return
        }

        self.avatars[user.id] = self.defaultAvatar
        
        guard let photo = user.photo else { return }
        
        let sdBlock: SDWebImageCompletionWithFinishedBlock = { (image, error, _, _, _) -> Void in

            guard let image = image else { return }
            
            self.avatars[user.id] = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            
            self.collectionView!.visibleCells().forEach { cell in
                if let indexPath = self.collectionView!.indexPathForCell(cell )
                    where self.messages[indexPath.item].senderId() == user.id {
                        
                        self.collectionView!.reloadItemsAtIndexPaths([indexPath])
                }
            }
        }
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: photo), options: .RetryFailed, progress: nil, completed: sdBlock)
    }
    
    private func loadMessages() {
        
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        Router.GroupMessage.FindByGroupId(id: self.group.id, before: oldestMessage?.createDate.timeIntervalSince1970)
            .response {
                
                self.isLoading = false
                if $0.result.isFailure {
                    self.isExhausted = true
                    return
                }
                guard let messages:[MessageEntity] = MessageEntity.collection($0.result.value!) else {
                    return
                }
                
                for message in messages {
                    
                    message.group = self.group
                    
                    if message.from.id == me.id {
                        message.from = me
                    }
                    self.messages.insert(JSQMessageEntity(message: message), atIndex: 0)
                }
                
                if self.oldestMessage == nil {
                    self.collectionView!.reloadData()
                    self.scrollToBottomAnimated(false)
                    
                    let newMessages = me.newMessages.filter { $0.group?.id != self.group.id }
                    if me.newMessages != newMessages {
                        me.newMessages = newMessages
                        if let tabBarController = self.navigationController?.tabBarController as? TabBarController {
                            tabBarController.updateBadgeNumber()
                        }
                    }
                } else {
                    self.prependRows(messages.count)
                }
                
                self.oldestMessage = messages.last
                self.isLoading = false
        }
    }
    
}

// MARK: - CommonMessageDelegate

extension GroupChatViewController: CommonMessageDelegate {
    
    func createMessage(text: String) -> NSIndexPath {
        
        let newMessage = JSQMessageEntity()
        newMessage.message.id = ""
        newMessage.message.from = me
        newMessage.message.group = self.group
        newMessage.message.content = text
        newMessage.message.createDate = NSDate()
        
//        friend.lastMessage = newMessage.message
        self.messages.append(newMessage)
        
        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
        self.collectionView!.insertItemsAtIndexPaths([indexPath])
        return indexPath
        
    }
    
    func sendMessage(text: String, done: ( ()->() )? = nil ) {
        
        Router.GroupMessage.SendByGroupId(id: self.group.id, content: text).response {
            if $0.result.isSuccess {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessageAnimated(true)
            }
            done?()
        }
    }
    
}


// MARK: - NSNotificationCenter

extension GroupChatViewController {
    
    private func registerForNotifications() {
        ListenerEvent.GroupMessage.addObserver(self, selector: Selector("receiveMessage:"))
    }
    
    func receiveMessage(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        let json = JSON(userInfo)
        
        guard json["targetId"].stringValue == self.group.id else { return }
        
        let message = MessageEntity(json)
        message.group = self.group
        
        let sender = self.group.members?.find { $0.id == message.from.id }
        
        if sender == nil {
            self.group.members = self.group.members ?? []
            self.group.members!.append(message.from)
            self.loadAvatarForUser(message.from)
        }
        
        let newMessage = JSQMessageEntity(message: message)
        
        self.messages.append(newMessage)
        
        gcd.sync(.Main) { _ in
            
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            self.finishReceivingMessageAnimated(true)
        }
    }
}

// MARK: - ScrollView Delegate

extension GroupChatViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -176 {
            self.loadMessages()
        }
    }
}

// MARK: - JSQMessagesCollectionView DataSource

extension GroupChatViewController {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]

        if message.senderId() != me.id {
            return avatars[message.senderId()]
        }
        
        return avatarMe
    }
    
}

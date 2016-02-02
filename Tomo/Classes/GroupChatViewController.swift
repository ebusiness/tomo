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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "line_group"), style: .Plain, target: self, action: "groupDetail")
        
        //receive notification
        self.registerForNotifications()

        self.loadMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let groups = me.groups where groups.contains(self.group.id) else {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // open all message when leave
        Router.GroupMessage.FindByGroupId(id: self.group.id, before: nil).request
    }
}

// MARK: - Private Methods

extension GroupChatViewController {
    
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
                guard let messages:[JSQMessageEntity] = JSQMessageEntity.collection($0.result.value!) else {
                    return
                }
                
                messages.forEach {
//                    $0.group = self.group
                    
                    if $0.from.id == me.id {
                        $0.from = me
                    }
                    self.messages.insert($0, atIndex: 0)
                    
                    if nil == self.avatars[$0.from.id] {
                        self.loadAvatarForUser($0.from)
                    }
                }
                
                if self.oldestMessage == nil {
                    self.collectionView!.reloadData()
                    self.scrollToBottomAnimated(false)
                    
                    let newMessages = me.newMessages.filter { $0.group?.id != self.group.id }
                    if me.newMessages != newMessages {
                        me.newMessages = newMessages
                    }
                } else {
                    self.prependRows(messages.count)
                }
                
                self.oldestMessage = messages.last
                self.isLoading = false
        }
    }
    
    @objc private func groupDetail(){
        let vc = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        vc.group = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - CommonMessageDelegate

extension GroupChatViewController: CommonMessageDelegate {
    
    func createMessage(type: MessageType, text: String) -> NSIndexPath {
        
        let newMessage = JSQMessageEntity()
        newMessage.id = ""
        newMessage.from = me
        newMessage.type = type
        newMessage.group = self.group
        newMessage.content = text
        newMessage.createDate = NSDate()
        
//        friend.lastMessage = newMessage.message
        self.messages.append(newMessage)
        
        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
        self.collectionView!.insertItemsAtIndexPaths([indexPath])
        return indexPath
        
    }
    
    func sendMessage(type: MessageType, text: String, done: ( ()->() )? = nil ) {
        
        Router.GroupMessage.SendByGroupId(id: self.group.id, type: type, content: text).response {
            if $0.result.isSuccess {
                me.sendMessage(MessageEntity($0.result.value!))
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: ListenerEvent.GroupMessage.rawValue, object: nil)
    }
    
    func didReceiveMessage(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        let json = JSON(userInfo)
        
        guard json["group"]["id"].stringValue == self.group.id else { return }
        
        let message = JSQMessageEntity(json)
//        message.group = self.group
        
        if nil == self.avatars[message.from.id] {
            self.loadAvatarForUser(message.from)
        }
        
        self.messages.append(message)
        
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

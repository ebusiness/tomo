//
//  MessageViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/18.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit
import SwiftyJSON

final class MessageViewController: CommonMessageController {
    
    var friend: UserEntity! {
        didSet {
            // load avatar
            loadAvatars()
        }
    }

    var avatarFriend: JSQMessagesAvatarImage!
    
    var oldestMessage: MessageEntity?
    
    var isLoading = false
    var isExhausted = false
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        self.delegate = self
        
        //receive message realtime
//        ListenerEvent.Message.addObserver(self, selector: Selector("receiveMessage:"))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: ListenerEvent.Message.rawValue, object: nil)

        // page title
        title = friend.nickName
        
        loadMessages()
    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        
        guard let friend = me.friends where friend.contains(self.friend.id) else {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // open all message when leave
        Router.Message.FindByUserId(id: friend.id, before: nil).request
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - Private Methods

extension MessageViewController {
    
    private func loadAvatars() {
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: friend.photo!), options: .RetryFailed, progress: nil) {
            (image, error, _, _, _) -> Void in
            if let image = image {
                self.avatarFriend = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            } else {
                self.avatarFriend = self.defaultAvatar
            }
            
            if self.messages.count > 0 {
                let indexPaths = self.collectionView!.indexPathsForVisibleItems()
                self.collectionView!.reloadItemsAtIndexPaths(indexPaths)
            }
        }
    }
    
    private func loadMessages() {
        
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        let finder = Router.Message.FindByUserId(id: friend.id, before: oldestMessage?.createDate.timeIntervalSince1970)
        
        finder.response {

            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                return
            }
            
            guard let messages: [JSQMessageEntity] = JSQMessageEntity.collection($0.result.value!) else {
                self.isLoading = false
                return
            }
            
            for message in messages {
                
                if message.from.id != me.id {
                    message.from = self.friend
                    message.to = me
                } else {
                    message.from = me
                    message.to = self.friend
                }
                self.messages.insert(message, atIndex: 0)
            }
            
            if self.oldestMessage == nil {
                
                self.collectionView!.reloadData()
                self.scrollToBottomAnimated(false)
                let newMessages = me.newMessages.filter { $0.from.id != self.friend.id }
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
    
}

// MARK: - CommonMessageDelegate

extension MessageViewController: CommonMessageDelegate {
    
    func createMessage(type: MessageType, text: String) -> NSIndexPath {
        let newMessage = JSQMessageEntity()
        newMessage.id = ""
        newMessage.to = friend
        newMessage.from = me
        newMessage.type = type
        newMessage.content = text
        newMessage.createDate = NSDate()
        
        friend.lastMessage = newMessage
        self.messages.append(newMessage)
        
        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
        self.collectionView!.insertItemsAtIndexPaths([indexPath])
        return indexPath
    }
    
    func sendMessage(type: MessageType, text: String, done: ( ()->() )? = nil ) {
        
        Router.Message.SendTo(id: friend.id, type: type, content: text).response {
            if $0.result.isFailure {
                done?()
            } else {

                me.sendMessage(MessageEntity($0.result.value!))

                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessageAnimated(true)
                done?()
            }
        }
    }
    
}

// MARK: - JSQMessageViewController overrides

extension MessageViewController {
    
    func didReceiveMessage(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        let json = JSON(userInfo)
        
        guard friend.id == json["from"]["id"].stringValue else { return }

        let message = JSQMessageEntity(json)
        message.to = me
        message.from = friend
        
        self.messages.append(message)
        
        gcd.sync(.Main, closure: { () -> () in
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            self.finishReceivingMessageAnimated(true)
        })
    }
    
    func setting(){
        //push setting or prifile?
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = friend
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - ScrollView Delegate

extension MessageViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -176 {
            self.loadMessages()
        }
    }
}

// MARK: - JSQMessagesCollectionView DataSource

extension MessageViewController {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId() != me.id {
            return avatarFriend
        }
        
        return avatarMe
    }
    
}

// MARK: - JSQMessagesCollectionView DelegateFlowLayout

extension MessageViewController {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        
        let message = messages[indexPath.item]
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = message.senderId() == me.id ? me : friend
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
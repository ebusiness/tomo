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
        
        // custom navigationBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "user_male_circle"), style: .Plain, target: self, action: "setting")
        
        //receive message realtime
        ListenerEvent.Message.addObserver(self, selector: Selector("receiveMessage:"))
        
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
            
            guard let messages: [MessageEntity] = MessageEntity.collection($0.result.value!) else {
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
                self.messages.insert(JSQMessageEntity(message: message), atIndex: 0)
            }
            
            if self.oldestMessage == nil {
                self.collectionView!.reloadData()
                self.scrollToBottomAnimated(false)
                let newMessages = me.newMessages.filter { $0.from.id != self.friend.id }
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

extension MessageViewController: CommonMessageDelegate {
    
    func createMessage(text: String) -> NSIndexPath {
        let newMessage = JSQMessageEntity()
        newMessage.message.id = ""
        newMessage.message.to = friend
        newMessage.message.from = me
        newMessage.message.content = text
        newMessage.message.createDate = NSDate()
        
        friend.lastMessage = newMessage.message
        self.messages.append(newMessage)
        
        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
        self.collectionView!.insertItemsAtIndexPaths([indexPath])
        return indexPath
        
    }
    
    func sendMessage(text: String, done: ( ()->() )? = nil ) {
        
        Router.Message.SendTo(id: friend.id, content: text).response {
            if $0.result.isFailure {
                done?()
            } else {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessageAnimated(true)
                done?()
            }
        }
    }
    
}

// MARK: - JSQMessageViewController overrides

extension MessageViewController {
    
    func receiveMessage(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let json = JSON(userInfo)
        
        guard friend.id == json["from"]["id"].stringValue else { return }
        let message = MessageEntity(json)
        message.to = me
        message.from = friend
        
        let newMessage = JSQMessageEntity(message: message)
        
        self.messages.append(newMessage)
        
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
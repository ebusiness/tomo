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
        NotificationCenter.default.addObserver(self, selector: Selector("didReceiveMessage:"), name: NSNotification.Name(rawValue: ListenerEvent.Message.rawValue), object: nil)

        // page title
        title = friend.nickName
        
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        
        guard let friend = me.friends, friend.contains(self.friend.id) else {
            let _ = self.navigationController?.popViewController(animated: true)
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // open all message when leave
        let _ = Router.Message.FindByUserId(id: friend.id, before: nil).request

        // tell accout model we finished talk
        me.finishChat(user: self.friend)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private Methods

extension MessageViewController {
    
    fileprivate func loadAvatars() {
        SDWebImageManager.shared().downloadImage(with: NSURL(string: friend.photo!) as URL!, options: .retryFailed, progress: nil) {
            (image, error, _, _, _) -> Void in
            if let image = image {
                self.avatarFriend = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            } else {
                self.avatarFriend = self.defaultAvatar
            }
            
            if self.messages.count > 0 {
                let indexPaths = self.collectionView!.indexPathsForVisibleItems
                self.collectionView!.reloadItems(at: indexPaths)
            }
        }
    }
    
    fileprivate func loadMessages() {
        
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
            
            guard let messages:  [JSQMessageEntity] = JSQMessageEntity.collection(json: $0.result.value!) else {
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
                self.messages.insert(message, at: 0)
            }
            
            if self.oldestMessage == nil {
                
                self.collectionView!.reloadData()
                self.scrollToBottom(animated: false)
//                let newMessages = me.newMessages.filter { $0.from.id != self.friend.id }
//                if me.newMessages != newMessages {
//                    me.newMessages = newMessages
//                }
            } else {
                self.prependRows(rows: messages.count)
            }
            
            self.oldestMessage = messages.last
            self.isLoading = false
        }
    }
    
}

// MARK: - CommonMessageDelegate

extension MessageViewController: CommonMessageDelegate {
    
    public func createMessage(type: MessageType, text: String) -> IndexPath {
        let newMessage = JSQMessageEntity()
        newMessage.id = ""
        newMessage.to = friend
        newMessage.from = me
        newMessage.type = type
        newMessage.content = text
        newMessage.createDate = Date()
        
        friend.lastMessage = newMessage
        self.messages.append(newMessage)
        
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        self.collectionView!.insertItems(at: [indexPath])
        return indexPath
    }
    
    func sendMessage(type: MessageType, text: String, done: ( ()->() )? = nil ) {
        
        Router.Message.SendTo(id: friend.id, type: type, content: text).response {
            if $0.result.isFailure {
                done?()
            } else {

                let newMessage = MessageEntity($0.result.value!)
                newMessage.to = self.friend
                me.sendMessage(message: newMessage)

                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage(animated: true)
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
        
        gcd.sync(.main, closure: { () -> () in
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            self.finishReceivingMessage(animated: true)
        })
    }
    
    func setting(){
        //push setting or prifile?
        let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = friend
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - ScrollView Delegate

extension MessageViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -176 {
            self.loadMessages()
        }
    }
}

// MARK: - JSQMessagesCollectionView DataSource

extension MessageViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId() != me.id {
            return avatarFriend
        }
        
        return avatarMe
    }
    
}

// MARK: - JSQMessagesCollectionView DelegateFlowLayout

extension MessageViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        
        let message = messages[indexPath.item]
        
        let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = message.senderId() == me.id ? me : friend
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//
//  GroupChatViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/18.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit
import MobileCoreServices

final class GroupChatViewController: CommonMessageController {
    
    var group: GroupEntity!
    
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    var messages = [JSQMessageEntity]()
    
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
        
        if let groups = me.groups where groups.contains(self.group.id) {
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // open all message when leave
        AlamofireController.request(.GET, "/groups/\(self.group.id)/messages")
    }
}

// MARK: - Private Methods

extension GroupChatViewController {
    
    private func loadAvatars() {
        self.group.members?.forEach { user in
            self.avatars[user.id] = self.defaultAvatar
        }
        
        AlamofireController.request(Method.GET, "/groups/\(group.id)", parameters: nil, encoding: ParameterEncoding.JSON, success: { object in
            
            self.group = GroupEntity(object)
            
            if let members = self.group.members {
                
                members.forEach {
                    self.loadAvatarForUser($0)
                }
            }
            
        })
    }
    
    private func loadAvatarForUser(user: UserEntity){
        if user.id == me.id {
            return
        }
        self.avatars[user.id] = self.defaultAvatar
        
        if let photo = user.photo {
            
            let sdBlock: SDWebImageCompletionWithFinishedBlock = { (image, error, _, _, _) -> Void in
                if let image = image {
                    
                    self.avatars[user.id] = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                    
                    self.collectionView!.visibleCells().forEach { cell in
                        if let indexPath = self.collectionView!.indexPathForCell(cell )
                            where self.messages[indexPath.item].senderId() == user.id {
                                
                                self.collectionView!.reloadItemsAtIndexPaths([indexPath])
                        }
                    }
                }
            }
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: photo), options: .RetryFailed, progress: nil, completed: sdBlock)
        }
    }
    
    private func loadMessages() {
        
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let oldestMessage = oldestMessage {
            params["before"] = oldestMessage.createDate.timeIntervalSince1970
        }
        
        
        AlamofireController.request(.GET, "/groups/\(self.group.id)/messages", parameters: params, success: { result in
            
            if let messages:[MessageEntity] = MessageEntity.collection(result) {
                
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
        }) { _ in
                self.isLoading = false
                self.isExhausted = true
        }
    }
    
    private func prependRows(rows: Int) {
        
        var indexPathes = [NSIndexPath]()
        
        for index in 0..<rows {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        collectionView!.insertItemsAtIndexPaths(indexPathes)
        
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
        
        var params = Dictionary<String, String>()
        params["content"] = text
        
        AlamofireController.request(.POST, "/groups/\(self.group.id)/messages", parameters: params, success: { _ in
            
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessageAnimated(true)
            done?()
            
        }) { _ in
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
        if let userInfo = notification.userInfo {
            
            let json = JSON(userInfo)
            
            if json["targetId"].stringValue == self.group.id {
                
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let item = messages[indexPath.item]
        item.download { () -> () in
            self.collectionView!.reloadItemsAtIndexPaths([indexPath])
        }
        
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId() != me.id {
            return incomingBubbleImageData
        }
        
        return outgoingBubbleImageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]

        if message.senderId() != me.id {
            return avatars[message.senderId()]
        }
        
        return avatarMe
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let jsqMessage = messages[indexPath.item]
        if indexPath.item < 1 { return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(jsqMessage.date()) }
        
        let diff = jsqMessage.date().timeIntervalSince1970 - messages[indexPath.item - 1].date().timeIntervalSince1970
        
        if diff > 90 {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(jsqMessage.date())
        }
        
        return nil
    }
    
}

// MARK: - JSQMessagesCollectionView DelegateFlowLayout

extension GroupChatViewController {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if nil != self.collectionView(collectionView, attributedTextForCellTopLabelAtIndexPath: indexPath) {
            return 40
        }
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        
        let message = messages[indexPath.item]
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = message.message.from
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let message = messages[indexPath.item]
        
        if let content = message.text() {
            
            if MediaMessage.mediaMessage(content) == .Image || MediaMessage.mediaMessage(content) == .Video {
                if nil != message.brokenImage {
                    message.reload({ () -> () in
                        self.collectionView!.reloadItemsAtIndexPaths([indexPath])
                    })
                } else {
                    
                    showGalleryView(indexPath, message: message)
                }
            }
            
            if let fileName = MediaMessage.fileNameOfMessage(content) where MediaMessage.mediaMessage(content) == .Voice {
                
                if FCFileManager.existsItemAtPath(fileName) {
                    VoiceController.instance.playOrStop(path: FCFileManager.urlForItemAtPath(fileName).path!)
                } else {
                    Util.showHUD()
                    Manager.sharedInstance.download(.GET, MediaMessage.fullPath(content)) { (tempUrl, res) -> (NSURL) in
                        return FCFileManager.urlForItemAtPath(fileName)
                        }.response { (_, _, _, error) -> Void in
                            Util.dismissHUD()
                            if error == nil {
                                VoiceController.instance.playOrStop(path: FCFileManager.urlForItemAtPath(fileName).path!)
                            }
                    }
                }
                
            }
        }
    }
    
    func showGalleryView(indexPath: NSIndexPath, message: JSQMessageEntity) {
        let cell = collectionView!.cellForItemAtIndexPath(indexPath) as? JSQMessagesCollectionViewCell
        if let cell = cell, imageView = cell.mediaView as? UIImageView {
            var items = [MHGalleryItem]()
            var index = 0
            
            for item in self.messages {
                if let
                    mediaItem = item.media() as? JSQMediaItem,
                    media = MediaMessage.mediaMessage(item.message.content)
                    
                    where media == .Image || media == .Video {
                        
                        var galleryItem: MHGalleryItem!
                        if let brokenImage = item.brokenImage {
                            galleryItem = MHGalleryItem(image: brokenImage)
                            items.append(galleryItem)
                            continue
                        }
                        if self.messages[indexPath.item] == item {
                            index = items.count
                        }
                        if mediaItem is JSQPhotoMediaItem {
                            galleryItem = MHGalleryItem(image: ( mediaItem as! JSQPhotoMediaItem).image)
                        } else if mediaItem is TomoVideoMediaItem {
                            let videoPath = MediaMessage.fullPath(message.text())
                            galleryItem = MHGalleryItem(URL: videoPath, galleryType: .Video)
                            galleryItem.image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(videoPath)
                        }
                        items.append(galleryItem)
                }
            }
            
            let gallery = MHGalleryController(presentationStyle: MHGalleryViewMode.ImageViewerNavigationBarShown)
            gallery.galleryItems = items
            gallery.presentationIndex = index
            gallery.presentingFromImageView = imageView
            
            gallery.UICustomization.useCustomBackButtonImageOnImageViewer = false
            gallery.UICustomization.showOverView = false
            gallery.UICustomization.showMHShareViewInsteadOfActivityViewController = false
            
            gallery.finishedCallback = { [weak self] (currentIndex, image, transition, viewMode) -> Void in
                let cell = self!.collectionView!.cellForItemAtIndexPath(indexPath) as!JSQMessagesCollectionViewCell
                let imageView = cell.mediaView as! UIImageView
                gcd.async(.Main, closure: { () -> () in
                    gallery.dismissViewControllerAnimated(true, dismissImageView: imageView, completion: { [weak self] () -> Void in
                        self!.automaticallyScrollsToMostRecentMessage = true
                        self!.collectionView!.reloadItemsAtIndexPaths([indexPath])
                    })
                })
            }
            
            self.automaticallyScrollsToMostRecentMessage = false
            presentMHGalleryController(gallery, animated: true, completion: nil)
        } else {
            
        }
    }
}

// MARK: - UICollectionView DataSource

extension GroupChatViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if !message.isMediaMessage() {
            if message.senderId() == me.id {
                cell.textView?.textColor = UIColor.blackColor()
            } else {
                cell.textView?.textColor = UIColor.whiteColor()
            }
        }
        
        return cell
    }
}

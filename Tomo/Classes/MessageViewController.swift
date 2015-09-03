//
//  MessageViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/18.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit
import MobileCoreServices

final class MessageViewController: JSQMessagesViewController {
    
    var selectedIndexPath: NSIndexPath?
    
    var icon_speaker_normal:UIImage!
    var icon_speaker_highlighted:UIImage!
    var icon_keyboard_normal:UIImage!
    var icon_keyboard_highlighted:UIImage!
    
    var friend: UserEntity!

    let selink = RKObjectManager(baseURL: kAPIBaseURL)
    
    let navigationBarImage = Util.imageWithColor(NavigationBarColorHex, alpha: 1)
    let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(DefaultAvatarImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    
    let avatarSize = CGSize(width: 50, height: 50)
    var avatarMe: JSQMessagesAvatarImage!
    var avatarBlank: JSQMessagesAvatarImage!
    var avatarFriend: JSQMessagesAvatarImage!
    
    static let BubbleFactory = JSQMessagesBubbleImageFactory()
    let outgoingBubbleImageData = BubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    let incomingBubbleImageData = BubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    
    var messages = [JSQMessageEntity]()
    
    var oldestMessage: MessageEntity?
    
    var isLoading = false
    var isExhausted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // custom navigationBar
        self.setNavigationBar()
        
        //receive message realtime
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveMessage:"), event: .Message)
        
        // page title
        title = friend.nickName
        
        // set sendId and displayName requested by jsq
        senderId = me.id
        senderDisplayName = me.nickName
        
        // customize avatar size
        collectionView.collectionViewLayout.incomingAvatarViewSize = avatarSize
        collectionView.collectionViewLayout.outgoingAvatarViewSize = avatarSize
        
        // adjust text bubble inset
        collectionView.collectionViewLayout.messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(7, 14, 3, 14)
        
        // load avatar
        loadAvatars()
        
        // TODO: adjust
        setAccessoryButtonImageView()
        
        // load message data
        setupMapping()
        
        loadMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let friend = me.friends where friend.contains(self.friend.id) {
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(navigationBarImage, forBarMetrics: .Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        VoiceController.instance.stopPlayer()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - Private Methods

extension MessageViewController {
    
    private func setNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "user_male_circle"), style: .Plain, target: self, action: "setting")
        
        let backitem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backitem
        
        let backimage = UIImage(named: "back")!
        navigationController?.navigationBar.backIndicatorImage = backimage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backimage
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    private func loadAvatars() {
        avatarBlank = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatar"), diameter: UInt (kJSQMessagesCollectionViewAvatarSizeDefault))
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: me.photo!), options: nil, progress: nil) {
            (image, error, _, _, _) -> Void in
            if let image = image {
                self.avatarMe = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            } else {
                self.avatarMe = self.defaultAvatar
            }
        }
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: friend.photo!), options: nil, progress: nil) {
            (image, error, _, _, _) -> Void in
            if let image = image {
                self.avatarFriend = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            } else {
                self.avatarFriend = self.defaultAvatar
            }
        }
    }
    
    private func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: "id"))
        let propertyMapping = RKRelationshipMapping(fromKeyPath: "_from", toKeyPath: "from", withMapping: userMapping)
        
        let messageMapping = RKObjectMapping(forClass: MessageEntity.self)
        messageMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "content": "content",
            "createDate": "createDate"
            ])
        messageMapping.addPropertyMapping(propertyMapping)
        
        let responseDescriptor = RKResponseDescriptor(mapping: messageMapping, method: .GET, pathPattern: "/messages/:userId", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
        selink.addResponseDescriptor(responseDescriptor)
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
        
        selink.getObjectsAtPath("/messages/\(friend.id)", parameters: params, success: { (operation, result) -> Void in
            
            for message in result.array() {
                
                if let message = message as? MessageEntity {
                    
                    if message.from.id != me.id {
                        message.from = self.friend
                        message.owner = me
                    } else {
                        message.from = me
                        message.owner = self.friend
                    }
                    self.messages.insert(JSQMessageEntity(message: message), atIndex: 0)
                }
            }
            
            if self.oldestMessage == nil {
                self.collectionView.reloadData()
                self.scrollToBottomAnimated(false)
                
                me.newMessages.filter({ (message) -> Bool in
                    if message.from.id == self.friend.id {
                        me.newMessages.remove(message)
                    }
                    
                    if let tabBarController = self.navigationController?.tabBarController as? TabBarController {
                        tabBarController.updateBadgeNumber()
                    }
                    return true
                })
            } else {
                self.prependRows(result.array().count)
            }
            
            self.oldestMessage = result.array().last as? MessageEntity
            self.isLoading = false
            
        }) { (operation, err) -> Void in
            println(err)
            
            self.isLoading = false
            self.isExhausted = true
        }
    }
    
    private func prependRows(rows: Int) {
        
        var indexPathes = [NSIndexPath]()
        
        for index in 0..<rows {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        collectionView.insertItemsAtIndexPaths(indexPathes)
        
    }
    
}

// MARK: - JSQMessageViewController overrides

extension MessageViewController {
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        button.enabled = false
        
        self.createMessage(text)
        self.sendMessage(text)
    }
    
    func receiveMessage(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            
            if friend.id == json["_from"]["_id"].stringValue {
                
                let message = MessageEntity(json)
                message.isOpened = true
                message.owner = me
                message.from = friend
                
                let newMessage = JSQMessageEntity(message: message)

                self.messages.append(newMessage)
                friend.lastMessage = message
                
                gcd.sync(.Main, closure: { () -> () in
                    
                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    self.finishReceivingMessageAnimated(true)
                })
            }
        }
    }
    
    func createMessage(text: String) -> NSIndexPath {
        
        let newMessage = JSQMessageEntity()
        newMessage.message.id = ""
        newMessage.message.owner = friend
        newMessage.message.from = me
        newMessage.message.content = text
        newMessage.message.isOpened = true
        newMessage.message.createDate = NSDate()
        
        friend.lastMessage = newMessage.message
        self.messages.append(newMessage)
        
        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
        self.collectionView.insertItemsAtIndexPaths([indexPath])
        return indexPath

    }
    
    func sendMessage(text: String, done: ( ()->() )? = nil ) {
        
        var params = Dictionary<String, String>()
        params["to"] = friend.id
        params["content"] = text
        
        Manager.sharedInstance.request(.POST, kAPIBaseURLString + "/messages", parameters: params).responseJSON { (_, _, _, error) -> Void in
            
            if error == nil {
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessageAnimated(true)
                
            } else {
                // handle error
            }
            done?()
        }
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let item = messages[indexPath.item]
        item.download { () -> () in
            self.collectionView.reloadItemsAtIndexPaths([indexPath])
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
            return avatarFriend
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

extension MessageViewController {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if let topLabelText = self.collectionView(collectionView, attributedTextForCellTopLabelAtIndexPath: indexPath) {
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
        vc.user = message.senderId() == me.id ? me : friend
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let message = messages[indexPath.item]
        
        if let content = message.text() {
            
            if MediaMessage.mediaMessage(content) == .Image || MediaMessage.mediaMessage(content) == .Video {
                if let broken = message.brokenImage {
//                    let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
//                    cell.mediaView = UIImageView(image: broken)
                    
                    message.reload({ () -> () in
                        self.collectionView.reloadItemsAtIndexPaths([indexPath])
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
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? JSQMessagesCollectionViewCell
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
                let cell = self!.collectionView.cellForItemAtIndexPath(self!.selectedIndexPath!) as!JSQMessagesCollectionViewCell
                let imageView = cell.mediaView as! UIImageView
                gcd.async(.Main, closure: { () -> () in
                    gallery.dismissViewControllerAnimated(true, dismissImageView: imageView, completion: { [weak self] () -> Void in
                        self!.automaticallyScrollsToMostRecentMessage = true
                        self!.collectionView.reloadItemsAtIndexPaths([self!.selectedIndexPath!])
                        })
                    
                })
            }
            
            self.automaticallyScrollsToMostRecentMessage = false
            selectedIndexPath = indexPath
            presentMHGalleryController(gallery, animated: true, completion: nil)
        } else {
            
        }
    }
}

// MARK: - UICollectionView DataSource

extension MessageViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if !message.isMediaMessage() {
            if message.senderId() == me.id {
                cell.textView.textColor = UIColor.blackColor()
            } else {
                cell.textView.textColor = UIColor.whiteColor()
            }
        }
        
        return cell
    }
}

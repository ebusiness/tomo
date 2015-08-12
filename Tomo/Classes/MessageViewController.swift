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
        navigationController?.navigationBar.setBackgroundImage(navigationBarImage, forBarMetrics: .Default)
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloadMediaDone"), name: "NotificationDownloadMediaDone", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        VoiceController.instance.stopPlayer()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func downloadMediaDone() {
        collectionView.reloadData()
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
    
    private func loadAvatars() {
        avatarBlank = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatar"), diameter: UInt (kJSQMessagesCollectionViewAvatarSizeDefault))
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: me.photo!), options: nil, progress: nil) {
            (image, error, _, _, _) -> Void in
            self.avatarMe = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: friend.photo!), options: nil, progress: nil) {
            (image, error, _, _, _) -> Void in
            self.avatarFriend = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
    }
    
    private func setupMapping() {
        
        let messageMapping = RKObjectMapping(forClass: MessageEntity.self)
        messageMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "_from": "from",
            "content": "content",
            "createDate": "createDate"
            ])
        
        let responseDescriptor = RKResponseDescriptor(mapping: messageMapping, method: .GET, pathPattern: "/chat/:userId", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
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
        
        selink.getObjectsAtPath("/chat/\(friend.id)", parameters: params, success: { (operation, result) -> Void in
            
            for message in result.array() {
                
                if let message = message as? MessageEntity {
                    
                    if message.from != me.id {
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

        self.sendMessage(text)
    }
    
    func receiveMessage(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            
            if friend.id == json["_from"]["_id"].stringValue {
                
                let newMessage = JSQMessageEntity()
                newMessage.message.id = json["_id"].stringValue
                newMessage.message.owner = me
                newMessage.message.from = friend
                newMessage.message.content = json["content"].stringValue
                newMessage.message.isOpened = true
                newMessage.message.createDate = json["createDate"].stringValue.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")

                self.messages.append(newMessage)
                friend.lastMessage = newMessage.message
                
                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                self.finishReceivingMessageAnimated(true)
            }
        }
    }
    
    func sendMessage(text: String) {
        
        let newMessage = JSQMessageEntity()
        newMessage.message.id = ""
        newMessage.message.owner = friend
        newMessage.message.from = me
        newMessage.message.content = text
        newMessage.message.isOpened = true
        newMessage.message.createDate = NSDate()
        
        var params = Dictionary<String, String>()
        params["recipient"] = friend.id
        params["subject"] = "no subject"
        params["content"] = text
        
        Manager.sharedInstance.request(.POST, kAPIBaseURLString + "/messages", parameters: params).responseJSON { (_, _, result, error) -> Void in
            
            if error == nil {
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                                                                       
                self.messages.append(newMessage)
                self.finishSendingMessageAnimated(true)
                
            } else {
                // handle error
            }
        }
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
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date())
        }
        
        return nil
    }
    
}

// MARK: - JSQMessagesCollectionView DelegateFlowLayout

extension MessageViewController {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
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
                showGalleryView(indexPath, message: message)
            }
            
            if MediaMessage.mediaMessage(content) == .Voice {
                if let fileName = MediaMessage.fileNameOfMessage(content) {
                    if FCFileManager.existsItemAtPath(fileName) {
                        VoiceController.instance.playOrStop(path: FCFileManager.urlForItemAtPath(fileName).path!)
                    } else {
                        Util.showHUD()
                        Manager.sharedInstance.download(.GET, MediaMessage.fullPath(content)) { (tempUrl, res) -> (NSURL) in
                            gcd.async(.Main, closure: { () -> () in
                                Util.dismissHUD()
                                VoiceController.instance.playOrStop(path: FCFileManager.urlForItemAtPath(fileName).path!)
                            })
                            return FCFileManager.urlForItemAtPath(fileName)
                        }
                    }
                }
            }
        }
    }
    
    func showGalleryView(indexPath: NSIndexPath, message: JSQMessageEntity) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? JSQMessagesCollectionViewCell
        if let cell = cell {
            let imageView = cell.mediaView as! UIImageView
            
            var items = [MHGalleryItem]()
            
            for item in self.messages {
                if let mediaItem = item.media() as? JSQMediaItem {
                    var galleryItem: MHGalleryItem!
                    if mediaItem is JSQPhotoMediaItem {
                        galleryItem = MHGalleryItem(image: (mediaItem as! JSQPhotoMediaItem).image)
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

// MARK: - UIImagePickerControllerDelegate

extension MessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let mediaType = info["UIImagePickerControllerMediaType"] as! String

        var name: String!
        var localURL: NSURL!
        var remotePath: String!
        
        if mediaType == kUTTypeMovie as! String {
            name = NSUUID().UUIDString + ".MP4"
            
            let url = info[UIImagePickerControllerMediaURL] as? NSURL

            if picker.sourceType == .Camera {
                if let path = url?.path {
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self, nil, nil)
                }
            }
            
            localURL = FCFileManager.urlForItemAtPath(name)
            FCFileManager.copyItemAtPath(url?.path, toPath: localURL.path)
            
            remotePath = MediaMessage.remotePath(fileName: name, type: .Video)
        } else {
            name = NSUUID().UUIDString
            let orgImage = info[UIImagePickerControllerOriginalImage] as! UIImage

            if picker.sourceType == .Camera {
                UIImageWriteToSavedPhotosAlbum(orgImage, nil, nil, nil)
            }
            
//            var editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            
            localURL = FCFileManager.urlForItemAtPath(name)
            
            var editedImage = orgImage.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
            editedImage = editedImage.normalizedImage()
            
            editedImage.saveToURL(localURL)
            
            remotePath = MediaMessage.remotePath(fileName: name, type: .Image)
        }
        
        if mediaType == kUTTypeMovie as! String {
            sendMessage(MediaMessage.mediaMessageStr(fileName: name, type: .Video))
        } else {
            sendMessage(MediaMessage.mediaMessageStr(fileName: name, type: .Image))
        }
        
        S3Controller.uploadFile(name: name, localPath: localURL.path!, remotePath: remotePath, done: { (error) -> Void in
            println("done")
            println(error)
        })
    }
    
}

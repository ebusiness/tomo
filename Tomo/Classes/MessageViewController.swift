//
//  MessageViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/18.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit
import MobileCoreServices

class MessageViewController: JSQMessagesViewController {
    
    var initialized = false
    var messageSend = false
    
//    var groupId: String!
    var me: User! {
        get {
            return DBController.myUser()
        }
    }
    var users = [User]()
//    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var avatarImageBlank: JSQMessagesAvatarImage!
    //Test
    var friend: User!
    
    var frc: NSFetchedResultsController!
    var count: Int! {
        return frc.fetchedObjects?.count ?? 0
    }
    
    var selectedIndexPath: NSIndexPath?
        var icon_speaker_normal:UIImage!
    var icon_speaker_highlighted:UIImage!
    var icon_keyboard_normal:UIImage!
    var icon_keyboard_highlighted:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAccessoryButtonImageView()

        self.senderId = me.id
        self.senderDisplayName = me.nickName
        if let friend = friend {
            navigationItem.title = friend.nickName
        }
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gotNewMessage"), name: "GotNewMessage", object: nil)
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: Selector("mediaMessageBtnTapped"))
        
        avatarImageBlank = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatar"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        
        loadMessages()
    }

    func loadMessages() {
        /*
        let after = messages.last?.date
        
        let chats = ChatController.chatsByGroupId(groupId, after: after)
        
        var isIncoming = false
        
        for chat in chats {
            let message = addMessage(chat)
            if incoming(message) {
                isIncoming = true
            }
        }
        
        if chats.count > 0 && initialized && isIncoming {
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        }
        
        finishReceivingMessage()
        scrollToBottomAnimated(false)
        
        initialized = true
        */
        
        frc = DBController.messageWithUser(friend)
        frc.delegate = self
        
        ApiController.getMessage { (error) -> Void in
            
        }
        
        if !Defaults.hasKey("didGetMessageSent") {
            self.messageSend = true
            ApiController.getMessageSent { (error) -> Void in
//                if error == nil {
                    Defaults["didGetMessageSent"] = true
//                }
            }
        }
    }
    
    /*
    func addMessage(chat: Chat) -> JSQMessage {
        var jsqMessage: JSQMessage
        
        let user = chat.user
        let name = user?.fullName()
        
        jsqMessage = JSQMessage(senderId: user!.id, senderDisplayName: name, date: chat.createdAt, text: chat.text)
        users.append(user!)
        
        messages.append(jsqMessage)
        
        return jsqMessage
    }
    */
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloadMediaDone"), name: "NotificationDownloadMediaDone", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gotNewMessage"), name: kNotificationGotNewMessage, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if friend != nil {
            DBController.makeAllMessageRead(friend)
        }
        
        VoiceController.instance.stopPlayer()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        println("メモリー不足")
        
        #if DEBUG
            Util.showInfo("メモリー不足")
        #endif
    }
    
    // MARK: - Notification
    
    func gotNewMessage() {
        DBController.makeAllMessageRead(friend)
    }
    
    func downloadMediaDone() {
        collectionView.reloadData()
    }
    
    // MARK: - Action
    
    func mediaMessageBtnTapped() {
        
        Util.alertActionSheet(self, optionalDict: [
            "拍摄/视频":{ (_) -> Void in
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                //            picker.allowsEditing = true
                picker.delegate = self
                picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
                picker.videoMaximumDuration = 10
                self.presentViewController(picker, animated: true, completion: nil)
            },
            "从相册选择":{ (_) -> Void in
                let picker = UIImagePickerController()
                picker.sourceType = .PhotoLibrary
                //            picker.allowsEditing = true
                picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
                
            }
            ])
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        sendMessage(text)
    }
    
    func sendMessage(text: String) {
        messageSend = true

        DBController.createMessage(friend, text: text)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        ApiController.sendMessage(nil, to: [friend.id!], content: text)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    deinit {
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - CollectionView

extension MessageViewController: UICollectionViewDataSource {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return frc.sections![section].numberOfObjects
        return count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = frc.objectAtIndexPath(indexPath) as! Message
        
        if !message.isMediaMessage() {
            if outgoing(message) {
                cell.textView.textColor = UIColor.blackColor()
            } else {
                cell.textView.textColor = UIColor.whiteColor()
            }
        }
        return cell
    }
    
    func outgoing(message: Message) -> Bool {
        return message.senderId() == senderId
    }
    
    func incoming(message: Message) -> Bool {
        return message.senderId() != senderId
    }
}
// MARK: - JSQMessagesCollectionViewDataSource

extension MessageViewController: JSQMessagesCollectionViewDataSource {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return frc.objectAtIndexPath(indexPath) as! Message
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = frc.objectAtIndexPath(indexPath) as! Message
        let user = message.from!
        
        if avatars[user.id!] == nil {
            if let photo_ref = user.photo_ref {
                SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: photo_ref), options: nil, progress: nil, completed: { (image, error, _, _, _) -> Void in
                    if error == nil && image != nil {
                        self.avatars[user.id!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.collectionView.reloadData()
                        })
                    }
                })
            } else {
                return avatarImageBlank
            }
            return avatarImageBlank
        } else {
            return avatars[user.id!]
        }
        
        /*
        let user = users[indexPath.item]
        
        if avatars[user.id!] == nil {
            if let photo_ref = user.photo_ref {
                SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: photo_ref), options: nil, progress: nil, completed: { (image, error, _, _, _) -> Void in
                    if error == nil && image != nil {
                        self.avatars[user.id!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.collectionView.reloadData()
                        })
                    }
                })
            } else {
                return avatarImageBlank
            }
            return avatarImageBlank
        } else {
            return avatars[user.id!]
        }*/
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = frc.objectAtIndexPath(indexPath) as! Message
        if outgoing(message) {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        }
        
        return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = frc.objectAtIndexPath(indexPath) as! Message
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date())
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = frc.objectAtIndexPath(indexPath) as! Message
        if incoming(message) {
            if indexPath.item > 0 {
                let preMessage = frc.objectAtIndexPath(NSIndexPath(forItem: indexPath.item - 1, inSection: 0)) as! Message
    
                if preMessage.senderId() == message.senderId() {
                    return nil
                }
            }
            return NSAttributedString(string: message.senderDisplayName())
        }
        
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
}

extension MessageViewController: JSQMessagesCollectionViewDelegateFlowLayout {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        let message = frc.objectAtIndexPath(indexPath) as! Message
        
        let vc = Util.createViewControllerWithIdentifier("AccountEditViewController", storyboardName: "Setting") as! AccountEditViewController
        vc.user = message.from
        vc.readOnlyMode = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        Util.showTodo()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = frc.objectAtIndexPath(indexPath) as! Message
        if let content = message.content {
            if MediaMessage.mediaMessage(content) == .Image || MediaMessage.mediaMessage(content) == .Video {
                showGalleryView(indexPath, message: message)
            }
            
            if MediaMessage.mediaMessage(content) == .Voice {
                if let fileName = MediaMessage.fileNameOfMessage(content) {
                    if FCFileManager.existsItemAtPath(fileName) {
                        VoiceController.instance.playOrStop(path: FCFileManager.urlForItemAtPath(fileName).path!)
                    } else {
                        Util.showHUD()
                        download(.GET, MediaMessage.fullPath(content), { (tempUrl, res) -> (NSURL) in
                            gcd.async(.Main, closure: { () -> () in
                                Util.dismissHUD()
                                VoiceController.instance.playOrStop(path: FCFileManager.urlForItemAtPath(fileName).path!)
                            })
                            return FCFileManager.urlForItemAtPath(fileName)
                        })
                    }
                }
            }
        }
    }
    
    func showGalleryView(indexPath: NSIndexPath, message: Message) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? JSQMessagesCollectionViewCell
        if let cell = cell {
            let imageView = cell.mediaView as! UIImageView
            var galleryItem: MHGalleryItem!
            let item = message.media() as! JSQMediaItem
            
            if item is JSQPhotoMediaItem {
                galleryItem = MHGalleryItem(image: (item as! JSQPhotoMediaItem).image)
            } else if item is TomoVideoMediaItem {
                let videoPath = MediaMessage.fullPath(message.content!)
                galleryItem = MHGalleryItem(URL: videoPath, galleryType: .Video)
                galleryItem.image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(videoPath)
            }
            
            let gallery = MHGalleryController(presentationStyle: MHGalleryViewMode.ImageViewerNavigationBarShown)
            gallery.galleryItems = [galleryItem]
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

// MARK: - NSFetchedResultsControllerDelegate

extension MessageViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
//        collectionView.reloadData()
        
        if messageSend {
            finishSendingMessage()
            messageSend = false
        } else {
            finishReceivingMessage()
        }
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
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        if picker.sourceType == .Camera {
//            
//        }
//        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
//        
//        let name = NSUUID().UUIDString
//        let path = NSTemporaryDirectory() + name
//        
//        let newImage = image.normalizedImage()
//        
//        newImage.saveToPath(path)
//        
//        picker.dismissViewControllerAnimated(false, completion: { () -> Void in
//            let vcNavi = Util.createViewControllerWithIdentifier(nil, storyboardName: "AddPost") as! UINavigationController
//            
//            let vc = vcNavi.topViewController as! AddPostViewController
//            vc.imagePath = path
//            self.presentViewController(vcNavi, animated: true, completion: nil)
//        })
//    }
}

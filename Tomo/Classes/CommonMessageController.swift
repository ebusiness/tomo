//
//  CommonMessageController.swift
//  spot
//
//  Created by Hikaru on 2015/03/11.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import Alamofire
/**
*  delegate
*/
public protocol CommonMessageDelegate {
    func createMessage(type: MessageType, text: String) -> NSIndexPath
    func sendMessage(type: MessageType, text: String, done: ( ()->() )?)
}

// MARK: - Voice

class CommonMessageController: JSQMessagesViewController {
    
    private var textView_text :String = ""
    private var btn_voice :UIButton?
    
    private var icon_speaker_normal:UIImage!
    private var icon_speaker_highlighted:UIImage!
    private var icon_keyboard_normal:UIImage!
    private var icon_keyboard_highlighted:UIImage!
    
    private let navigationBarImage = Util.imageWithColor(0x0288D1, alpha: 1)
    static let BubbleFactory = JSQMessagesBubbleImageFactory()
    
    var recordTap: UILongPressGestureRecognizer! {
        get {
            return UILongPressGestureRecognizer(target: self,action:"record:")
        }
    }
    
    var messages = [JSQMessageEntity]()
    
    let outgoingBubbleImageData = BubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    let incomingBubbleImageData = BubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    
    let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(DefaultAvatarImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    
    let avatarSize = CGSize(width: 50, height: 50)
    var avatarMe: JSQMessagesAvatarImage!
    
    var delegate: CommonMessageDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // custom navigationBar
        self.setNavigationBar()
        // load avatar
        loadAvatars()
        
        // set sendId and displayName requested by jsq
        senderId = me.id
        senderDisplayName = me.nickName
        
        // customize avatar size
        collectionView!.collectionViewLayout.incomingAvatarViewSize = avatarSize
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = avatarSize
        
        // adjust text bubble inset
        collectionView!.collectionViewLayout.messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(7, 14, 3, 14)

        // remove the leftBarButtonItem
//        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        // TODO: adjust
        setAccessoryButtonImageView()
        
        navigationController?.navigationBar.setBackgroundImage(navigationBarImage, forBarMetrics: .Default)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(navigationBarImage, forBarMetrics: .Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        VoiceController.instance.stopPlayer()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        button.enabled = false
        
        self.delegate.createMessage(.text,text: text)
        self.delegate.sendMessage(.text, text: text, done: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - Private Methods

extension CommonMessageController {
    
    private func setNavigationBar() {

        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    private func loadAvatars() {
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: me.photo!), options: .RetryFailed, progress: nil) {
            (image, error, _, _, _) -> Void in
            if let image = image {
                self.avatarMe = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            } else {
                self.avatarMe = self.defaultAvatar
            }
        }
    }
    
    /**
    AccessoryButtonImageView
    */
    private func setAccessoryButtonImageView() {
//        let icon_speaker = UIImage(named: "icon_speaker")!
        let icon_keyboard = UIImage(named: "icon_keyboard")!
        
        self.icon_speaker_normal = UIImage.jsq_defaultAccessoryImage().jsq_imageMaskedWithColor(UIColor.lightGrayColor())
        self.icon_speaker_highlighted = UIImage.jsq_defaultAccessoryImage().jsq_imageMaskedWithColor(UIColor.darkGrayColor())
        
        self.icon_keyboard_normal = icon_keyboard.jsq_imageMaskedWithColor(UIColor.lightGrayColor())
        self.icon_keyboard_highlighted = icon_keyboard.jsq_imageMaskedWithColor(UIColor.darkGrayColor())
        self.inputToolbar!.contentView!.leftBarButtonItemWidth = 32
        self.changeAccessoryButtonImage(0)
    }
    
    private func changeAccessoryButtonImage(tag: Int) {
        if tag == 0{
            self.inputToolbar!.contentView!.leftBarButtonItem!.setImage(self.icon_speaker_normal, forState: UIControlState.Normal)
            self.inputToolbar!.contentView!.leftBarButtonItem!.setImage(self.icon_speaker_highlighted, forState: UIControlState.Highlighted)
        }else{
            self.inputToolbar!.contentView!.leftBarButtonItem!.setImage(self.icon_keyboard_normal, forState: UIControlState.Normal)
            self.inputToolbar!.contentView!.leftBarButtonItem!.setImage(self.icon_keyboard_highlighted, forState: UIControlState.Highlighted)
        }
    }
}

// MARK: - ActionSheet

extension CommonMessageController {
    
    /// CameraBlock
    var pressAccessoryBlock: CameraController.CameraBlock! {
        get {
            return { (image,videoPath) ->() in
                let fileName = NSUUID().UUIDString + (videoPath == nil ? ".png" : ".mp4" )
                let localURL = FCFileManager.urlForItemAtPath(fileName)
                var remotePath: String!
                var messaeType: MessageType!
                
                if let path = videoPath {
                    FCFileManager.copyItemAtPath(path, toPath: localURL.path)
                    messaeType = .video
                    
                } else {
                    
                    let image = image!.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
                    image.saveToURL(localURL)
                    
                    messaeType = .photo
                }
                
                remotePath = messaeType.remotePath(fileName)
                let indexPath = self.delegate.createMessage(messaeType, text: fileName)
                
                let progressView = UIProgressView(frame: CGRectZero)
                progressView.tintColor = UIColor.greenColor()
                
                let cell = self.collectionView!.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
                cell.addSubview(progressView)
                
                progressView.translatesAutoresizingMaskIntoConstraints = false
                cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[progressView(==1)]-0-|", options: [], metrics: nil, views: ["progressView" : progressView]))
                cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[progressView(==messageBubbleContainerView)]-0-[avatarContainerView]", options: [], metrics: nil, views: ["messageBubbleContainerView" : cell.messageBubbleContainerView!, "progressView" : progressView,"avatarContainerView":cell.avatarContainerView!]))
                
                S3Controller.uploadFile(localURL.path!, remotePath: remotePath, done: { (error) -> Void in
                    self.delegate.sendMessage(messaeType, text: fileName){ ()->() in
                        progressView.removeFromSuperview()
                    }
                }).progress { _, sendBytes, totalBytes in
                    gcd.sync(.Main, closure: { () -> () in
                        progressView.progress = Float(sendBytes)/Float(totalBytes)
                    })
                }
            }
        }
    }
    
    /**
    on Press
    
    - parameter sender: jsqAccessoryButton
    */
    override func didPressAccessoryButton(sender: UIButton!) {
        //録音モード
        if btn_voice?.tag == 1 {
            btn_voice?.tag = 0
            self.changeAccessoryButtonImage(0)
            self.inputToolbar!.contentView!.textView!.text = textView_text
            textView_text = ""
            btn_voice?.removeFromSuperview()
            self.inputToolbar!.contentView!.removeGestureRecognizer(self.recordTap)
            self.inputToolbar!.contentView!.textView!.becomeFirstResponder()
            return
        }
        
        Util.alertActionSheet(self, optionalDict: [
            "拍摄/视频":{ (_) -> Void in
                CameraController.sharedInstance.open(self, sourceType: .Camera, withVideo: true, completion: self.pressAccessoryBlock)
            },
            "从相册选择":{ (_) -> Void in
                CameraController.sharedInstance.open(self, sourceType: .SavedPhotosAlbum, completion: self.pressAccessoryBlock)
            },
            "语音输入":{ (_) -> Void in
                if self.btn_voice == nil {
                    self.setVoiceButton()
                }
                if self.btn_voice?.tag == 0{
                    self.btn_voice?.tag = 1
                    self.changeAccessoryButtonImage(1)
                    self.inputToolbar!.contentView!.addSubview(self.btn_voice!)
                    self.textView_text = self.inputToolbar!.contentView!.textView!.text
                    self.inputToolbar!.contentView!.textView!.text = ""
                    self.inputToolbar!.contentView!.textView!.resignFirstResponder()
                }
            }
            ])
    }
    
    /**
    hold on button
    */
    func setVoiceButton(){
        var frame = self.inputToolbar!.contentView!.textView!.frame
        frame.size.height = 30;
        
        btn_voice = UIButton(frame:frame)
        let l = self.inputToolbar!.contentView!.textView!.layer
        
        btn_voice?.layer.borderWidth = l.borderWidth//0.5;
        btn_voice?.layer.borderColor = l.borderColor//UIColor.lightGrayColor().CGColor;
        btn_voice?.layer.cornerRadius = l.cornerRadius//6.0;
        
        let rect = btn_voice?.bounds
        let label = UILabel(frame: rect!)
        label.textAlignment = NSTextAlignment.Center
        label.text = "按住说话"
        btn_voice?.addSubview(label)
        
        btn_voice?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        
        self.inputToolbar!.contentView!.addGestureRecognizer(self.recordTap)
//        btn_voice?.addGestureRecognizer(UILongPressGestureRecognizer(target: self,action:"record:"))
        //btn_voice?.addTarget(self, action: "holdOn", forControlEvents: UIControlEvents.TouchDown)
        //btn_voice?.addTarget(self, action: "sendVoice", forControlEvents: UIControlEvents.TouchUpInside)
    }
}

// MARK: - Private Methods

extension CommonMessageController {
    
    /**
    hold on
    
    - parameter longPressedRecognizer: longPressedRecognizer
    */
    func record(longPressedRecognizer: UILongPressGestureRecognizer) {
        if longPressedRecognizer.state == UIGestureRecognizerState.Began {
            btn_voice?.backgroundColor = Util.UIColorFromRGB(0x0EAA00, alpha: 1)
            VoiceController.instance.start()
            NSLog("hold Down");
            
        }//长按结束
        else if longPressedRecognizer.state == UIGestureRecognizerState.Ended || longPressedRecognizer.state == UIGestureRecognizerState.Cancelled{
            
            btn_voice?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
            if let (url, fileName) = VoiceController.instance.stop() {
                self.delegate.createMessage(.voice, text: fileName)
                self.delegate.sendMessage(.voice, text: fileName, done: nil)
                
                S3Controller.uploadFile(url, remotePath: MessageType.voice.remotePath(fileName), done: { error in
                    print("done")
                    print(error)
                })
            }
            //            VoiceController.instance.play(url)
            NSLog("hold release");
        }
    }
}

// MARK: - JSQMessagesCollectionView DataSource

extension CommonMessageController {
    
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

extension CommonMessageController {
    
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
        vc.user = message.from
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionView DataSource

extension CommonMessageController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if !message.isMediaMessage() {
            if message.senderId() == me.id {
                cell.textView!.textColor = UIColor.blackColor()
            } else {
                cell.textView!.textColor = UIColor.whiteColor()
            }
        }
        
        self.addBadgeViewIfNeeded(cell, message: message)
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let message = messages[indexPath.item]
        
        guard let content = message.text() else { return }
        
        switch message.type {
        case .photo:
            fallthrough
        case .video:
            if nil != message.brokenImage {
                //                let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
                //                cell.mediaView = UIImageView(image: broken)
                
                message.reload({ () -> () in
                    self.collectionView!.reloadItemsAtIndexPaths([indexPath])
                })
            } else {
                
                showGalleryView(indexPath, message: message)
            }
        case .voice:
            if FCFileManager.existsItemAtPath(content) {
                VoiceController.instance.playOrStop(path: FCFileManager.urlForItemAtPath(content).path!)
            } else {
                Util.showHUD()
                Manager.sharedInstance.download(.GET, message.type.fullPath(content)) { (tempUrl, res) -> (NSURL) in
                    return FCFileManager.urlForItemAtPath(content)
                    }.response { (_, _, _, error) -> Void in
                        Util.dismissHUD()
                        if error == nil {
                            VoiceController.instance.playOrStop(path: FCFileManager.urlForItemAtPath(content).path!)
                        }
                }
            }
        default:
            break
        }
        
    }
}

extension CommonMessageController {
    
    func addBadgeViewIfNeeded (cell: JSQMessagesCollectionViewCell, message: JSQMessageEntity){
        if message.senderId() == me.id { return }
        guard message.type == .voice else { return }
        
        let width: CGFloat = 8
        let avatarHeight: CGFloat = 50
        let voiceBackgroundImageWidth: CGFloat = 100
        
        let badgeView = UIView(frame: CGRectZero)
        badgeView.backgroundColor = UIColor.redColor()
        badgeView.layer.cornerRadius = width / 2
        badgeView.layer.masksToBounds = true
        
        cell.addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["badgeView" : badgeView]
        cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[badgeView(==\(width))]-\(avatarHeight-width)-|", options: [], metrics: nil, views: views))
        cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[badgeView(==\(width))]-\(avatarHeight+voiceBackgroundImageWidth)-|", options: [], metrics: nil, views:views))
    }
    
    func showGalleryView(indexPath: NSIndexPath, message: JSQMessageEntity) {
        
        guard let
            cell = collectionView!.cellForItemAtIndexPath(indexPath) as? JSQMessagesCollectionViewCell,
            imageView = cell.mediaView as? UIImageView
            else { return }
        
        var items = [MHGalleryItem]()
        var index = 0
        
        for item in self.messages {
            
            guard let
                mediaItem = item.media() as? JSQMediaItem
                where item.type == .photo || item.type == .video
                else { continue }
            
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
                let videoPath = message.type.fullPath(message.content)
                galleryItem = MHGalleryItem(URL: videoPath, galleryType: .Video)
                galleryItem.image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(videoPath)
            }
            items.append(galleryItem)
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
    }
    
    func prependRows(rows: Int) {
        
        var indexPathes = [NSIndexPath]()
        
        for index in 0..<rows {
            indexPathes.append(NSIndexPath(forRow: index, inSection: 0))
        }
        
        collectionView!.insertItemsAtIndexPaths(indexPathes)
    }
}

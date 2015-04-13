//
//  MessageViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/18.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class MessageViewController: JSQMessagesViewController {
//    var pathDownloading = Dictionary<String, Net?>()
//    
//    var pUser: PFObject!
//    var avatarImageData: NSData?
//    
//    var jidStr: String! {
//        return pUser["openfireId"] as String
//    }
//    
//    var jid: XMPPJID! {
//        return XMPPJID.jidWithString(jidStr)
//    }
//
//    var meImage: JSQMessagesAvatarImage!
//    var friendImage: JSQMessagesAvatarImage!
//    
//    var frc: NSFetchedResultsController!
//    
//    var icon_speaker_normal:UIImage!
//    var icon_speaker_highlighted:UIImage!
//    var icon_keyboard_normal:UIImage!
//    var icon_keyboard_highlighted:UIImage!
    
    var groupId: String!
    var me: User! {
        get {
            return DBController.myUser()
        }
    }
    var users = [User]()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var avatarImageBlank: JSQMessagesAvatarImage!
    //Test
    var friend: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = me.id
        self.senderDisplayName = me.fullName()
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "写真を送信", style: .Done, target: self, action: Selector("sendImage"))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "接收", style: .Done, target: self, action: Selector("receiveMessage"))
        
        avatarImageBlank = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatar"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        
        loadMessages()
//        setAccessoryButtonImageView()

//        showLoadEarlierMessagesHeader = true
        
//        setupAvatarImage()
//        
//        loadMessage()
        
//        ParseController.getPUserByKeyIncludeAvatarIgnoreCache("openfireId", value: pUser["openfireId"] as String) { (pUser, data, error) -> Void in
//            if let error = error {
//                return
//            }
//            
//            self.pUser = pUser
//            
//            if let data = data {
//                let rosterImage = UIImage(data: data)
//                self.friendImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(rosterImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//            }
//            
//            self.collectionView.reloadData()
//        }
    }

    func loadMessages() {
        let after = messages.last?.date
        
        let chats = ChatController.chatsByGroupId(groupId, after: after)
        
        for chat in chats {
            addMessage(chat)
        }
        
        finishReceivingMessage()
        scrollToBottomAnimated(false)
    }
    
    func addMessage(chat: Chat) -> JSQMessage {
        var jsqMessage: JSQMessage
        
        let user = chat.user
        let name = user?.fullName()
        
        jsqMessage = JSQMessage(senderId: user!.id, senderDisplayName: name, date: chat.createdAt, text: chat.text)
        users.append(user!)
        
        messages.append(jsqMessage)
        
        return jsqMessage
    }
//    func setupAvatarImage() {
//        self.meImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(XMPPManager.instance.account.avatarImage(), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//        
//        var rosterImage = UIImage(named: "avatar")
//        if let data = avatarImageData {
//            rosterImage = UIImage(data: data)
//        }
//        
//        self.friendImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(rosterImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//    }
//    
//    func loadMessage() {
//        frc = XMPPMessageArchiving_Message_CoreDataObject.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "bareJidStr=%@", argumentArray: [jidStr]), sortedBy: "timestamp", ascending: true, inContext: XMPPManager.instance.xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext)
//        frc.delegate = self
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func messageAtIndexPath(indexPath: NSIndexPath) -> JSQMessageData {
//        return frc.objectAtIndexPath(indexPath) as JSQMessageData
//    }
    
    // MARK: - Action
    
    func receiveMessage() {
        ChatController.createChatFrom(user: friend, groupId: groupId)
        loadMessages()
    }
    
    func sendImage() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "写真を撮る", style: .Default, handler: { (action) -> Void in
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.allowsEditing = true
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let albumAction = UIAlertAction(title: "写真から選択", style: .Default, handler: { (action) -> Void in
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
//        if let path = NSBundle.mainBundle().pathForResource("test", ofType: "png") {
//            XMPPManager.instance.sendLocalPhotoMessage(path, to: jid)
//        
//            self.finishSendingMessageAnimated(true)
//            
//            XMPPManager.instance.sendRemotePhotoMessage("http://sourcetreeapp.com/images/sourcetree-hero-mac-log.png", to: jid)
//        }
    }
    
    // MARK: - Notification
    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        sendMessage(text)
    }
    
    func sendMessage(text: String) {
        ChatController.createChat(groupId, text: text)
        ChatController.updateMessage(groupId, text: text)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        loadMessages()
        
        finishSendingMessage()
    }
    
//    // MARK: - KVO
//
//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if keyPath == "messages" {
//            self.collectionView.reloadData()
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - CollectionView

extension MessageViewController: UICollectionViewDataSource {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return frc.sections![section].numberOfObjects
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        if outgoing(messages[indexPath.item]) {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
//        let message = messageAtIndexPath(indexPath)
//        
////        let message = self.friend.messages[indexPath.item] as SpotMessage
//        
//        if message.isMediaMessage() == false {
//            if message.senderId() == self.senderId {
//                cell.textView.textColor = UIColor.blackColor()
//            } else {
//                cell.textView.textColor = UIColor.whiteColor()
//            }
//            
//            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName : cell.textView.textColor,
//                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternDash.rawValue]
//        }

        return cell
    }
    
    func outgoing(message: JSQMessage) -> Bool {
        return message.senderId == senderId
    }
    
    func incoming(message: JSQMessage) -> Bool {
        return message.senderId != senderId
    }
}
// MARK: - JSQMessagesCollectionViewDataSource

extension MessageViewController: JSQMessagesCollectionViewDataSource {
    
//    func senderDisplayName() -> String! {
//        return "me"
//    }
    
//    func senderId() -> String! {
////        return XMPPManager.instance.account.openfireId;
//        return ""
//    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
//        let m = messageAtIndexPath(indexPath) as XMPPMessageArchiving_Message_CoreDataObject
//        let type = m.messageType()
//        
//        if type != .Text {
//            let path = m.pathOfMedia(m.isLocalMediaMessage())
//            
//            if type == .Photo {
//                var image: UIImage?
//                
//                if let data = DatabaseManager.dataOfPath(path) {
//                    image = UIImage(data: data)
//                } else {
//                    if m.isRemoteMediaMessage() {
//                        downloadResources(path)
//                    }
//                }
//                
//                let photoItem = JSQPhotoMediaItem(image:image)
//                photoItem.appliesMediaViewMaskAsOutgoing = m.isLocalMediaMessage()
//                
//                let photoMessage = JSQMessage(senderId: m.senderId(), senderDisplayName: m.senderDisplayName(), date: m.timestamp, media: photoItem)
//                
//                return photoMessage
//            }
//            
//            if type == .Voice {
//                var voice = DatabaseManager.dataOfPath(path)
//                if voice == nil && m.isRemoteMediaMessage() {
//                    downloadResources(path)
//                }
//                
//                let imageName = m.isLocalMediaMessage() ? "SenderVoiceNodePlaying" : "ReceiverVoiceNodePlaying"
//                
//                let voiceItem = JSQVoiceMediaItem(voice: voice, image: UIImage(named: imageName))
//                voiceItem.appliesMediaViewMaskAsOutgoing = m.isLocalMediaMessage()
//                
//                let voiceMessage = JSQMessage(senderId: m.senderId(), senderDisplayName: m.senderDisplayName(), date: m.timestamp, media: voiceItem)
//                
//                return voiceMessage
//            }
//        }
//        
//        return messageAtIndexPath(indexPath)
        
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
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
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        if outgoing(message) {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        }
        
        return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        if incoming(message) {
            if indexPath.item > 0 {
                let preMessage = messages[indexPath.item - 1]
    
                if preMessage.senderId == message.senderId {
                    return nil
                }
            }
            return NSAttributedString(string: message.senderDisplayName)
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
//        let message = messageAtIndexPath(indexPath)
//        if message.senderId() == senderId {
//            return 0
//        }
//        
//        if indexPath.item - 1 > 0 {
//            let preMessage = messageAtIndexPath(NSIndexPath(forItem: indexPath.item - 1, inSection: 0))
//            
//            if preMessage.senderId() == message.senderId() {
//                return 0
//            }
//        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        SVProgressHUD.showInfoWithStatus("TODO", maskType: .Clear)
//        let message = messageAtIndexPath(indexPath)
//        let jid = XMPPJID.jidWithString(message.senderId())
//        Util.enterFriendDetailViewController(jid, username: nil, from: self, isTalking: true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        SVProgressHUD.showInfoWithStatus("TODO", maskType: .Clear)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        Util.showTodo()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
//        let m = messageAtIndexPath(indexPath) as XMPPMessageArchiving_Message_CoreDataObject
//        if m.messageType() == .Voice {
//            if m.isRemoteMediaMessage() {
//                VoiceController.instance.playOrStopTest()
//                return
//            }
//            
//            if let data = DatabaseManager.dataOfPath(m.pathOfMedia(m.isLocalMediaMessage())) {
//                VoiceController.instance.playOrStop(data)
//            }
//        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MessageViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
        finishReceivingMessageAnimated(true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {

//        let smallImage = image.scaleToFitSize(CGSize(width: 500, height: 500))
//        let orgImage = image.scaleToFitSize(CGSize(width: 750, height: 750))
//        
//        let path = NSUUID().UUIDString.lowercaseString
//        DatabaseManager.saveDataOfPath(path, data: UIImagePNGRepresentation(smallImage)) { () -> Void in
//            XMPPManager.instance.sendLocalPhotoMessage(path, to: self.jid)
//            
//            self.finishSendingMessageAnimated(true)
//
//            // TODO: UploadToS3
//            
//            XMPPManager.instance.sendRemotePhotoMessage("http://lorempixel.com/500/500/?" + NSUUID().UUIDString.lowercaseString, to: self.jid)
//            
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
    }
}

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
    @discardableResult
    func createMessage(type: MessageType, text: String) -> IndexPath
    func sendMessage(type: MessageType, text: String, done: ( ()->() )?)
}

// MARK: - Voice

class CommonMessageController: JSQMessagesViewController {

    fileprivate var textViewText :String = ""
    fileprivate var btnVoice :UIButton?

    fileprivate var iconSpeakerNormal:UIImage!
    fileprivate var iconSpeakerHighlighted:UIImage!
    fileprivate var iconKeyboardNormal:UIImage!
    fileprivate var iconKeyboardHighlighted:UIImage!

    private let navigationBarImage = Util.imageWithColor(rgbValue: 0x0288D1, alpha: 1)
    static let BubbleFactory = JSQMessagesBubbleImageFactory()

    var recordTap: UILongPressGestureRecognizer! {
        get {
            return UILongPressGestureRecognizer(target: self,action:Selector(("record:")))
        }
    }

    var messages = [JSQMessageEntity]()

    let outgoingBubbleImageData = BubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    let incomingBubbleImageData = BubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())

    let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: defaultAvatarImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))

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

        navigationController?.navigationBar.setBackgroundImage(navigationBarImage, for: .default)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(navigationBarImage, for: .default)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        VoiceController.instance.stopPlayer()
    }

    // MARK: - Navigation
    override func didPressSend(_ button: UIButton!, withMessageText text:   String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        button.isEnabled = false

        self.delegate.createMessage(type: .text,text: text)
        self.delegate.sendMessage(type: .text, text: text, done: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private Methods

extension CommonMessageController {

    fileprivate func setNavigationBar() {

        navigationController?.navigationBar.tintColor = UIColor.white

        navigationController?.navigationBar.barStyle = .black

    }

    fileprivate func loadAvatars() {
        _ = SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: me.photo!), progress: nil, completed: { (image, error, _, _) in
            if let image = image {
                self.avatarMe = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            } else {
                self.avatarMe = self.defaultAvatar
            }
        })
    }

    /**
    AccessoryButtonImageView
    */
    fileprivate func setAccessoryButtonImageView() {
//        let icon_speaker = UIImage(named: "icon_speaker")!
        let icon_keyboard = UIImage(named: "icon_keyboard")!

        self.iconSpeakerNormal = UIImage.jsq_defaultAccessory().jsq_imageMasked(with: UIColor.lightGray)
        self.iconSpeakerHighlighted = UIImage.jsq_defaultAccessory().jsq_imageMasked(with: UIColor.darkGray)

        self.iconKeyboardNormal = icon_keyboard.jsq_imageMasked(with: UIColor.lightGray)
        self.iconKeyboardHighlighted = icon_keyboard.jsq_imageMasked(with: UIColor.darkGray)
        self.inputToolbar!.contentView!.leftBarButtonItemWidth = 32
        self.changeAccessoryButtonImage(tag: 0)
    }

    fileprivate func changeAccessoryButtonImage(tag: Int) {
        if tag == 0{
            self.inputToolbar!.contentView!.leftBarButtonItem!.setImage(self.iconSpeakerNormal, for: .normal)
            self.inputToolbar!.contentView!.leftBarButtonItem!.setImage(self.iconSpeakerHighlighted, for: .highlighted)
        }else{
            self.inputToolbar!.contentView!.leftBarButtonItem!.setImage(self.iconKeyboardNormal, for: .normal)
            self.inputToolbar!.contentView!.leftBarButtonItem!.setImage(self.iconKeyboardHighlighted, for: .highlighted)
        }
    }
}

// MARK: - ActionSheet

extension CommonMessageController {

    /// CameraBlock
    var pressAccessoryBlock: CameraController.CameraBlock! {
        get {
            return { (image,videoPath) ->() in
                let fileName = NSUUID().uuidString + (videoPath == nil ? ".png" : ".mp4" )

                let localURL = Util.getDocumentsURL(forFile: fileName)

                var remotePath: String!
                var messaeType: MessageType!

                if let path = videoPath {

                    if !FileManager.default.fileExists(atPath: localURL.path) {
                        try? FileManager.default.copyItem(atPath: path, toPath: localURL.path)
                    }

                    messaeType = .video

                } else {

                    let image = image!.scale(toFit: CGSize(width: maxWidth, height: maxWidth))
                    image?.save(to: localURL)

                    messaeType = .photo
                }

                remotePath = messaeType.remotePath(fileName)
                let indexPath = self.delegate.createMessage(type: messaeType, text: fileName)

                let progressView = UIProgressView(frame: CGRect.zero)
                progressView.tintColor = UIColor.green

                let cell = self.collectionView!.cellForItem(at: indexPath) as? JSQMessagesCollectionViewCell!
                cell!.addSubview(progressView)

                progressView.translatesAutoresizingMaskIntoConstraints = false
                cell!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[progressView(==1)]-0-|", options: [], metrics: nil, views: ["progressView" : progressView]))
                cell!.addConstraints(NSLayoutConstraint.constraints(
                    withVisualFormat: "H:[progressView(==messageBubbleContainerView)]-0-[avatarContainerView]",
                    options: [],
                    metrics: nil,
                    views: [
                        "messageBubbleContainerView" : cell!.messageBubbleContainerView!,
                        "progressView" : progressView,
                        "avatarContainerView":cell!.avatarContainerView!
                    ]))

                S3Controller.uploadFile(localPath: localURL.path, remotePath: remotePath, done: { (error) -> Void in
                    self.delegate.sendMessage(type: messaeType, text: fileName){ ()->() in
                        progressView.removeFromSuperview()
                    }
                })
//                    .uploadProgress { progress in // main queue by default
//                    gcd.sync(.Main, closure: { () -> () in
//                        progressView.progress = progress.fractionCompleted
//                    })
//                }


//                    .progress { _, sendBytes, totalBytes in
//                    gcd.sync(.Main, closure: { () -> () in
//                        progressView.progress = Float(sendBytes)/Float(totalBytes)
//                    })
//                }
            }
        }
    }

    /**
    on Press

    - parameter sender: jsqAccessoryButton
    */
    override func didPressAccessoryButton(_ sender: UIButton!) {
        //録音モード
        if btnVoice?.tag == 1 {
            btnVoice?.tag = 0
            self.changeAccessoryButtonImage(tag: 0)
            self.inputToolbar!.contentView!.textView!.text = textViewText
            textViewText = ""
            btnVoice?.removeFromSuperview()
            self.inputToolbar!.contentView!.removeGestureRecognizer(self.recordTap)
            self.inputToolbar!.contentView!.textView!.becomeFirstResponder()
            return
        }

        Util.alertActionSheet(parentvc: self, optionalDict: [
            "拍摄/视频":{ (_) -> Void in
                CameraController.sharedInstance.open(vc: self, sourceType: .camera, withVideo: true, completion: self.pressAccessoryBlock)
            },
            "从相册选择":{ (_) -> Void in
                CameraController.sharedInstance.open(vc: self, sourceType: .savedPhotosAlbum, completion: self.pressAccessoryBlock)
            },
//            "语音输入":{ (_) -> Void in
//                if self.btnVoice == nil {
//                    self.setVoiceButton()
//                }
//                if self.btnVoice?.tag == 0{
//                    self.btnVoice?.tag = 1
//                    self.changeAccessoryButtonImage(1)
//                    self.inputToolbar!.contentView!.addSubview(self.btnVoice!)
//                    self.textViewText = self.inputToolbar!.contentView!.textView!.text
//                    self.inputToolbar!.contentView!.textView!.text = ""
//                    self.inputToolbar!.contentView!.textView!.resignFirstResponder()
//                }
//            }
            ])
    }

    /**
    hold on button
    */
    func setVoiceButton(){
        var frame = self.inputToolbar!.contentView!.textView!.frame
        frame.size.height = 30;

        btnVoice = UIButton(frame:frame)
        let l = self.inputToolbar!.contentView!.textView!.layer

        btnVoice?.layer.borderWidth = l.borderWidth//0.5;
        btnVoice?.layer.borderColor = l.borderColor//UIColor.lightGrayColor().CGColor;
        btnVoice?.layer.cornerRadius = l.cornerRadius//6.0;

        let rect = btnVoice?.bounds
        let label = UILabel(frame: rect!)
        label.textAlignment = .center
        label.text = "按住说话"
        btnVoice?.addSubview(label)

        btnVoice?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)

        self.inputToolbar!.contentView!.addGestureRecognizer(self.recordTap)
//        btnVoice?.addGestureRecognizer(UILongPressGestureRecognizer(target: self,action:"record:"))
        //btnVoice?.addTarget(self, action: "holdOn", forControlEvents: UIControlEvents.TouchDown)
        //btnVoice?.addTarget(self, action: "sendVoice", forControlEvents: UIControlEvents.TouchUpInside)
    }
}

// MARK: - Private Methods

extension CommonMessageController {

    /**
    hold on

    - parameter longPressedRecognizer: longPressedRecognizer
    */
    func record(longPressedRecognizer: UILongPressGestureRecognizer) {
        if longPressedRecognizer.state == UIGestureRecognizerState.began {
            btnVoice?.backgroundColor = Util.UIColorFromRGB(0x0EAA00, alpha: 1)
            VoiceController.instance.start()
            NSLog("hold Down");

        }//长按结束
        else if longPressedRecognizer.state == UIGestureRecognizerState.ended || longPressedRecognizer.state == UIGestureRecognizerState.cancelled {

            btnVoice?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
            if let (url, fileName) = VoiceController.instance.stop() {
                self.delegate.createMessage(type: .voice, text: fileName)
                self.delegate.sendMessage(type: .voice, text: fileName, done: nil)

                S3Controller.uploadFile(localPath: url, remotePath: MessageType.voice.remotePath(fileName), done: { error in
                    print("done")
                    print(error ?? "no errors")
                })
            }
            //            VoiceController.instance.play(url)
            NSLog("hold release");
        }
    }
}

// MARK: - JSQMessagesCollectionView DataSource

extension CommonMessageController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let item = messages[indexPath.item]
        item.download { () -> () in
            self.collectionView!.reloadItems(at: [indexPath])
        }

        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {

        let message = messages[indexPath.item]

        if message.senderId() != me.id {
            return incomingBubbleImageData
        }

        return outgoingBubbleImageData
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {

        let jsqMessage = messages[indexPath.item]
        if indexPath.item < 1 { return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: jsqMessage.date()) }

        let diff = jsqMessage.date().timeIntervalSince1970 - messages[indexPath.item - 1].date().timeIntervalSince1970

        if diff > 90 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: jsqMessage.date())
        }

        return nil
    }

}

// MARK: - JSQMessagesCollectionView DelegateFlowLayout

extension CommonMessageController {

    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!,
                                 heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {

        if nil != self.collectionView(collectionView, attributedTextForCellTopLabelAt: indexPath) {
            return 40
        }
        return 0
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!,
                                 heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 20
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!,
                                 heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {

        let message = messages[indexPath.item]

        let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
        vc!.user = message.from
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

// MARK: - UICollectionView DataSource

extension CommonMessageController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell

        let message = messages[indexPath.item]

        if !message.isMediaMessage() {
            if message.senderId() == me.id {
                cell!.textView!.textColor = UIColor.black
            } else {
                cell!.textView!.textColor = UIColor.white
            }
        }

        self.addBadgeViewIfNeeded(cell: cell!, message: message)

        return cell!
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {

        let message = messages[indexPath.item]

        guard let content = message.text() else { return }

        switch message.type {
        case .photo:
            fallthrough
        case .video:
            if nil != message.brokenImage {
                //                let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
                //                cell.mediaView = UIImageView(image: broken)

                message.reload(completion: { () -> () in
                    self.collectionView!.reloadItems(at: [indexPath])
                })
            } else {

//                showGalleryView(indexPath: indexPath, message: message)
            }
        case .voice:
            let fileURL = Util.getDocumentsURL(forFile: content)

            if FileManager.default.fileExists(atPath: fileURL.path) {
                VoiceController.instance.playOrStop(path: fileURL.path)
            } else {
                Util.showHUD()

                let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }

                Alamofire.SessionManager.default.download(message.type.fullPath(name: content), to: destination).response { res in
                    Util.dismissHUD()
                    if res.error == nil {
                        VoiceController.instance.playOrStop(path: fileURL.absoluteString)
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

        let badgeView = UIView(frame: CGRect.zero)
        badgeView.backgroundColor = UIColor.red
        badgeView.layer.cornerRadius = width / 2
        badgeView.layer.masksToBounds = true

        cell.addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["badgeView" : badgeView]
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[badgeView(==\(width))]-\(avatarHeight-width)-|", options: [], metrics: nil, views: views))
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[badgeView(==\(width))]-\(avatarHeight+voiceBackgroundImageWidth)-|", options: [], metrics: nil, views:views))
    }

    func prependRows(rows: Int) {

        var indexPathes = [IndexPath]()

        for index in 0..<rows {
            indexPathes.append(IndexPath(row: index, section: 0))
        }

        collectionView!.insertItems(at: indexPathes)
    }
}

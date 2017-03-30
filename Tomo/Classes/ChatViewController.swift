//
//  ChatViewController.swift
//  Tomo
//
//  Created by starboychina on 2017/02/13.
//  Copyright © 2017 e-business. All rights reserved.
//

import SlackTextViewController
import UIKit

final class ChatViewController: SLKTextViewController {

    var btnVoice: UIButton?

    fileprivate var textViewText: String = ""
    fileprivate var iconSpeakerNormal: UIImage!
    fileprivate var iconSpeakerHighlighted: UIImage!
    fileprivate var iconKeyboardNormal: UIImage!
    fileprivate var iconKeyboardHighlighted: UIImage!

    var group: GroupEntity?

    var friend: UserEntity?

    override var tableView: UITableView {
        return super.tableView!
    }

    var messages = [MessageEntity]()

    fileprivate var cellForCalculatorHeight: ChatTableViewTextCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()

        let nibs = Bundle.main.loadNibNamed("ChatTableViewTextCell", owner: nil, options: nil)!
        if let cell = nibs.first as? ChatTableViewTextCell {
            self.cellForCalculatorHeight = cell
        }

        guard self.group != nil else {
            loadFriendMessages()
            return
        }

        self.loadGroupMessages()
    }

    private func configureTableView() {

        self.leftButton.setImage(#imageLiteral(resourceName: "icon_keyboard"), for: .normal)

        self.textView.placeholder = "Message"
        let textNib = UINib(nibName: "ChatTableViewTextCell", bundle: nil)
        self.tableView.register(textNib, forCellReuseIdentifier: "ChatTableViewTextCell")
        let imageNib = UINib(nibName: "ChatTableViewImageCell", bundle: nil)
        self.tableView.register(imageNib, forCellReuseIdentifier: "ChatTableViewImageCell")
        self.tableView.separatorStyle = .none
    }
}

// MARK: - load message

extension ChatViewController {

    fileprivate func loadFriendMessages() {

        guard let friendId = self.friend?.id else {
            return
        }

        Router.Message.FindByUserId(id: friendId, before: nil).response { res in
            if res.result.isFailure {
                return
            }
            guard let result: [MessageEntity] = MessageEntity.collection(res.result.value!) else {
                return
            }

            self.messages = result.map {
                if $0.from.id == me.id {
                    $0.from = me
                }
                return $0
            }
            self.tableView.reloadData()
        }
    }

    fileprivate func loadGroupMessages() {

        guard let groupId = self.group?.id else {
            return
        }

        Router.GroupMessage.FindByGroupId(id: groupId, before: nil).response { res in
            if res.result.isFailure {
                return
            }
            guard let result: [MessageEntity] = MessageEntity.collection(res.result.value!) else {
                return
            }

            self.messages = result.map {
                if $0.from.id == me.id {
                    $0.from = me
                }
                return $0
            }
            self.tableView.reloadData()
        }
    }
}

// MARK: - send message

extension ChatViewController {

    fileprivate func sendMessage(type: MessageType, text: String,
                                 uploadHandler: ((@escaping () -> Void) -> Void)? = nil) {
        let newMessage = MessageEntity()
        newMessage.id = ""
        newMessage.from = me
        newMessage.type = type
        newMessage.content = text
        newMessage.createDate = Date()

        if group != nil {
            newMessage.group = self.group
            if let handler = uploadHandler {
                handler({
                    self.sendGroupMessage(type: type, text: text)
                })
            } else {
                self.sendGroupMessage(type: type, text: text)
            }
        } else {
            newMessage.to = self.friend
            friend?.lastMessage = newMessage
            if let handler = uploadHandler {
                handler({
                    self.sendGroupMessage(type: type, text: text)
                })
            } else {
                self.sendFriendMessage(type: type, text: text)
            }
        }

        self.messages.insert(newMessage, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    private func sendFriendMessage(type: MessageType, text: String) {
        guard let id = friend?.id else {
            return
        }

        Router.Message.SendTo(id: id, type: type, content: text).response {
            if $0.result.isFailure {
                return
            }

            let newMessage = MessageEntity($0.result.value!)
            newMessage.to = self.friend
            me.sendMessage(message: newMessage)
        }
    }

    private func sendGroupMessage(type: MessageType, text: String) {
        guard let groupId = group?.id else {
            return
        }

        Router.GroupMessage.SendByGroupId(id: groupId, type: type, content: text)
            .response {
                if $0.result.isFailure {
                    return
                }

                let newMessage = MessageEntity($0.result.value!)
                newMessage.group = self.group
                me.sendMessage(message: newMessage)
            }
    }
}

// MARK: - TableViewControllerDataSource

extension ChatViewController: ChatTableViewTextCellDelegate, ChatTableViewImageCellDelegate {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message.type == .text {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewTextCell", for: indexPath) as? ChatTableViewTextCell

            self.configureText(cell: cell!, forRowAt: indexPath)
            cell?.delegate = self
            cell?.transform = tableView.transform
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewImageCell", for: indexPath) as? ChatTableViewImageCell

            self.configureImage(cell: cell!, forRowAt: indexPath)
            cell?.delegate = self
            cell?.transform = tableView.transform
            return cell!
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        if message.type == .text {
            self.configureText(cell: self.cellForCalculatorHeight!, forRowAt: indexPath)
            return self.cellForCalculatorHeight.getHeight()
        } else if message.type == .photo || message.type == .video {
            return 200
        } else {
            return 80
        }
    }

    private func configureText(cell: ChatTableViewTextCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.message = self.messages[indexPath.row]
        if indexPath.row == self.messages.count - 1 {
            cell.dateOfPreviousMessage = Date(timeIntervalSince1970: 0)
        } else {
            cell.dateOfPreviousMessage = self.messages[indexPath.row + 1].createDate
        }
    }

    private func configureImage(cell: ChatTableViewImageCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.message = self.messages[indexPath.row]
        if indexPath.row == self.messages.count - 1 {
            cell.dateOfPreviousMessage = Date(timeIntervalSince1970: 0)
        } else {
            cell.dateOfPreviousMessage = self.messages[indexPath.row + 1].createDate
        }
    }

    func userAvatarTapped(message: MessageEntity) {
        let vc = Util.createViewController(storyboardName: "Profile", id: "ProfileView")
        guard let profileVC = vc as? ProfileViewController else { return }
        profileVC.user = message.from.id == me.id ? me: message.from
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: - ActionSheet

extension ChatViewController {

    override func didPressRightButton(_ sender: Any?) {
        self.view .endEditing(true)
        guard let text = self.textView.text, text != "" else {
            return
        }
        super.didPressRightButton(sender)

        self.sendMessage(type: .text, text: text)
    }

    override func didPressLeftButton(_ sender: Any?) {
        print("camera button is tapped")
        if btnVoice?.tag == 1 {
            btnVoice?.tag = 0
            btnVoice?.removeFromSuperview()
            self.textInputbar.textView.becomeFirstResponder()
            return
        }
        displaySheet()
    }
}

extension ChatViewController: UIActionSheetDelegate {

    /// CameraBlock
    private var cameraBlock: CameraController.CameraBlock! {
        return { (image, videoPath) -> Void in
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

            self.sendMessage(type: messaeType, text: fileName) { done in
                S3Controller.uploadFile(localPath: localURL.path, remotePath: remotePath, done: { (_) -> Void in
                    done()
                })
            }
        }
    }

    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        print("\(buttonIndex)")

        switch buttonIndex {

        case 0:
            print("取消")
        case 1:
            print("拍摄/视频")
            CameraController.shared.open(vc: self, sourceType: .camera, withVideo: true, completion: self.cameraBlock)
        case 2:
            print("从相册选择")
            CameraController.shared.open(vc: self, sourceType: .savedPhotosAlbum, completion: self.cameraBlock)
        case 3:
            if self.btnVoice == nil {
                self.setVoiceButton()
            }
            if self.btnVoice?.tag == 0 {
                self.btnVoice?.tag = 1
                //                self.changeAccessoryButtonImage(1)
                self.textInputbar.addSubview(self.btnVoice!)
                self.textViewText = self.textInputbar.textView.text
                self.textInputbar.textView.text = ""
                self.textInputbar.textView.resignFirstResponder()
            }
        default:
            print("Default")

        }
    }

    fileprivate func displaySheet() {

        let actionSheet = UIActionSheet(title: nil, delegate: self,
                                        cancelButtonTitle: "取消",
                                        destructiveButtonTitle: nil,
                                        otherButtonTitles: "拍摄/视频", "从相册选择", "语音输入")

        actionSheet.show(in: self.view)
    }

    /// hold on button
    func setVoiceButton() {
        let frame = self.textView.frame

        btnVoice = UIButton(frame:frame)
        let layer = self.textInputbar.textView.layer

        btnVoice?.layer.borderWidth = layer.borderWidth//0.5;
        btnVoice?.layer.borderColor = layer.borderColor//UIColor.lightGrayColor().CGColor;
        btnVoice?.layer.cornerRadius = layer.cornerRadius//6.0;

        let rect = btnVoice?.bounds
        let label = UILabel(frame: rect!)
        label.textAlignment = .center
        label.text = "按住说话"
        btnVoice?.addSubview(label)

        let colorValue: CGFloat = 0.85
        btnVoice?.backgroundColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.record(_:)))
        btnVoice?.addGestureRecognizer(longPress)
    }

    /// hold on
    ///
    /// - Parameter longPressedRecognizer: <#longPressedRecognizer description#>
    func record(_ longPressedRecognizer: UILongPressGestureRecognizer) {
        if longPressedRecognizer.state == UIGestureRecognizerState.began {
            btnVoice?.backgroundColor = Util.UIColorFromRGB(0x0EAA00, alpha: 1)
            VoiceController.instance.start()

        } else if longPressedRecognizer.state == UIGestureRecognizerState.ended
            || longPressedRecognizer.state == UIGestureRecognizerState.cancelled {

            let colorValue: CGFloat = 0.85
            btnVoice?.backgroundColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1)
            if let (url, fileName) = VoiceController.instance.stop() {
                self.sendMessage(type: .voice, text: fileName) { done in
                    S3Controller.uploadFile(localPath: url, remotePath: MessageType.voice.remotePath(fileName)) { _ in
                        done()
                    }
                }
            }
            //            VoiceController.instance.play(url)
            NSLog("hold release")
        }
    }
}

//
//  GroupChatViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/02/18.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit
import SwiftyJSON
import MobileCoreServices

final class GroupChatViewController: CommonMessageController {

    var group: GroupEntity!

    var avatars = Dictionary<String, JSQMessagesAvatarImage>()

    var oldestMessage: MessageEntity?

    var isLoading = false
    var isExhausted = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        // page title
        title = group.name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "line_group"), style: .plain, target: self, action: #selector(GroupChatViewController.groupDetail))

        //receive notification
        self.registerForNotifications()

        self.loadMessages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let groups = me.groups, groups.contains(self.group.id) else {
            self.navigationController?.pop(animated: true)
            return
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // open all message when leave
        Router.GroupMessage.FindByGroupId(id: self.group.id, before: nil).request()

        // tell account model I finished talk
        me.finishGroupChat(group: self.group)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private Methods

extension GroupChatViewController {

    fileprivate func loadAvatarForUser(user: UserEntity){

//        if user.id == me.id {
//            
//            return
//        }

        self.avatars[user.id] = self.defaultAvatar

        guard let photo = user.photo else { return }

        _ = SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: photo), progress: nil, completed: { (image, error, _, _) in

            guard let image = image else { return }

            self.avatars[user.id] = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))

            self.collectionView!.visibleCells.forEach { cell in
                if let indexPath = self.collectionView!.indexPath(for: cell ), self.messages[indexPath.item].senderId() == user.id {

                    self.collectionView!.reloadItems(at: [indexPath])
                }
            }
        })
    }

    fileprivate func loadMessages() {

        if isLoading || isExhausted {
            return
        }

        isLoading = true

        Router.GroupMessage.FindByGroupId(id: self.group.id, before: oldestMessage?.createDate.timeIntervalSince1970)
            .response {

                self.isLoading = false
                if $0.result.isFailure {
                    self.isExhausted = true
                    return
                }
                guard let messages:[JSQMessageEntity] = JSQMessageEntity.collection($0.result.value!) else {
                    return
                }

                messages.forEach {
//                    $0.group = self.group

                    if $0.from.id == me.id {
                        $0.from = me
                    }
                    self.messages.insert($0, at: 0)

                    if nil == self.avatars[$0.from.id] {
                        self.loadAvatarForUser(user: $0.from)
                    }
                }

                if self.oldestMessage == nil {
                    self.collectionView!.reloadData()
                    self.scrollToBottom(animated: false)

//                    let newMessages = me.newMessages.filter { $0.group?.id != self.group.id }
//                    if me.newMessages != newMessages {
//                        me.newMessages = newMessages
//                    }
                } else {
                    self.prependRows(rows: messages.count)
                }

                self.oldestMessage = messages.last
                self.isLoading = false
        }
    }

    func groupDetail(){
        let vc = Util.createViewControllerWithIdentifier(id: "GroupDetailView", storyboardName: "Group") as? GroupDetailViewController
        vc?.group = group
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}

// MARK: - CommonMessageDelegate

extension GroupChatViewController: CommonMessageDelegate {

    func createMessage(type: MessageType, text: String) -> IndexPath {

        let newMessage = JSQMessageEntity()
        newMessage.id = ""
        newMessage.from = me
        newMessage.type = type
        newMessage.group = self.group
        newMessage.content = text
        newMessage.createDate = Date()

//        friend.lastMessage = newMessage.message
        self.messages.append(newMessage)

        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        self.collectionView!.insertItems(at: [indexPath])
        return indexPath

    }

    func sendMessage(type: MessageType, text: String, done: ( ()->() )? = nil ) {

        Router.GroupMessage.SendByGroupId(id: self.group.id, type: type, content: text).response {
            if $0.result.isSuccess {

                let newMessage = MessageEntity($0.result.value!)
                newMessage.group = self.group
                me.sendMessage(message: newMessage)

                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage(animated: true)
            }
            done?()
        }
    }

}

// MARK: - NSNotificationCenter

extension GroupChatViewController {

    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GroupChatViewController.didReceiveMessage(_:)), name: ListenerEvent.GroupMessage.notificationName, object: nil)
    }

    func didReceiveMessage(_ notification: NSNotification) {

        guard let userInfo = notification.userInfo else { return }

        let json = JSON(userInfo)

        guard json["group"]["id"].stringValue == self.group.id else { return }

        let message = JSQMessageEntity(json)
//        message.group = self.group

        if nil == self.avatars[message.from.id] {
            self.loadAvatarForUser(user: message.from)
        }

        self.messages.append(message)

        gcd.sync(.main) { _ in

            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            self.finishReceivingMessage(animated: true)
        }
    }
}

// MARK: - ScrollView Delegate

extension GroupChatViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -176 {
            self.loadMessages()
        }
    }
}

// MARK: - JSQMessagesCollectionView DataSource

extension GroupChatViewController {

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {

        let message = messages[indexPath.item]

        if message.senderId() != me.id {
            return avatars[message.senderId()]
        } else {
            return avatarMe
        }
    }

}

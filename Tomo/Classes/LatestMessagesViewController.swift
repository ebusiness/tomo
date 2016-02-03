//
//  LatestMessagesViewController.swift
//  Tomo
//
//  Created by ebuser on 2016/02/01.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class LatestMessagesViewController: UITableViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var infoLabel: UILabel!

    var messages = [MessageEntity]()

    var isLoading = false

    override func viewDidLoad() {

        super.viewDidLoad()

        self.loadLatestMessage()

        self.configEventObserver()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - UITableView datasource

extension LatestMessagesViewController {


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if me.friendInvitations.count > 0 {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if me.friendInvitations.count > 0 {

            switch section {
            case 0:
                return me.friendInvitations.count
            default:
                return self.messages.count
            }

        } else {
            return self.messages.count
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        func makeInvitationCell() -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell", forIndexPath: indexPath) as! FriendInvitationTableViewCell
            cell.invitation = me.friendInvitations[indexPath.item]
            cell.delegate = self
            return cell
        }

        func makeMessageCell() -> UITableViewCell {

            let message = self.messages[indexPath.item]

            if message.group != nil {

                let cell = tableView.dequeueReusableCellWithIdentifier("GroupMessageCell", forIndexPath: indexPath) as! GroupMessageTableViewCell
                cell.message = message
                return cell

            } else {

                let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageTableViewCell
                cell.message = message
                return cell
            }
        }

        if me.friendInvitations.count > 0 {

            switch indexPath.section {
            case 0:
                return makeInvitationCell()
            default:
                return makeMessageCell()
            }

        } else {
            return makeMessageCell()
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if me.friendInvitations.count > 0 {

            switch section {
            case 0:
                return "未处理的好友请求"
            default:
                return "最近的消息"
            }

        } else {
            return nil
        }
    }
}

// MARK: - UITableView delegate

extension LatestMessagesViewController {

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if me.friendInvitations.count > 0 {

            switch indexPath.section {
            case 0:
                return 88
            default:
                return 66
            }

        } else {
            return 66
        }
    }

    // Do this for eliminate the gap between the friend list sction and navigation bar.
    // that gap will appear when no invitaion and the friend list is the first section.
    // TODO: Just DONT know the meaning of these values...
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if me.friendInvitations.count == 0 {
            return 10
        }
        return 38
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if me.friendInvitations.count > 0 && indexPath.section == 0 {

            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = me.friendInvitations[indexPath.item].from
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }

        let message = self.messages[indexPath.row]

        if let group = message.group {
            let vc = GroupChatViewController()
            vc.group = group
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = MessageViewController()
            vc.friend = (message.from.id == me.id ? message.to : message.from)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Internal Methods

extension LatestMessagesViewController {

    private func loadLatestMessage() {

        // skip if already in loading
        if self.isLoading {
            return
        }

        self.isLoading = true

        Router.Message.Latest.response {

            self.loadingIndicator.stopAnimating()

            if $0.result.isFailure {
                self.isLoading = false
                return
            }

            if let messages: [MessageEntity] = MessageEntity.collection($0.result.value!) {

                self.messages += messages.sort {
                    $0.createDate.compare($1.createDate) == NSComparisonResult.OrderedDescending
                }

                // let table view display new contents
                self.appendRows(messages.count, inSection: me.friendInvitations.count > 0 ? 1 : 0)
            }
        }
    }

    // Append specific number of rows on table view
    private func appendRows(rows: Int, inSection section: Int) {

        let firstIndex = self.messages.count - rows
        let lastIndex = self.messages.count

        var indexPathes = [NSIndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: section))
        }

        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
    }
}

// MARK: - Event Observer

extension LatestMessagesViewController {

    private func configEventObserver() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRefuseInvitation:", name: "didRefuseInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAcceptInvitation:", name: "didAcceptInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeleteFriend:", name: "didDeleteFriend", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLeaveGroup:", name: "didLeaveGroup", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didSendMessage:", name: "didSendMessage", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishGroupChat:", name: "didFinishGroupChat", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishChat:", name: "didFinishChat", object: me)

        // notification from background thread
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFriendInvitation", name: "didReceiveFriendInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFriendBreak:", name: "didFriendBreak", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: "didReceiveMessage", object: me)
    }

    // This method is called for sync this view controller and accout model after refuse invitation
    func didRefuseInvitation(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let index = userInfo["indexOfRemovedInvitation"] as? Int else { return }

        // update tableview, if the number of my invitation is zero, remove the whole section of 0
        // otherwise, remove the corresponding row in section 0, note the invitation data is referring
        // the accout model directly, so the data is removed just in accout model, no need to do that here
        self.tableView.beginUpdates()
        if me.friendInvitations.count > 0 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
        } else {
            self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }

    // This method is called for sync this view controller and accout model after accept invitation
    func didAcceptInvitation(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let index = userInfo["indexOfRemovedInvitation"] as? Int else { return }

        self.tableView.beginUpdates()
        // if the number of my invitation is zero, remove the whole section of 0
        // otherwise, remove the corresponding row in section 0
        if me.friendInvitations.count > 0 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
        } else {
            self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }

    // This method is called for sync this view controller and accout model after delete friend
    func didDeleteFriend(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let id = userInfo["idOfDeletedFriend"] as? String else { return }

        // see if the deleted user is exist in chat message list
        let indexInMessageList = self.messages.indexOf {

            // skip group message
            guard $0.group == nil else { return false }

            let friendId = ($0.from.id == me.id ? $0.to.id : $0.from.id)
            return friendId == id
        }

        // do nothing if not found
        guard let index = indexInMessageList else { return }

        // sync friends data with account model manually
        // remove the chat history from messages list
        self.messages.removeAtIndex(index)

        // update tableview, if the number of my invitation is zero, insert into section 1
        // otherwise, remove the corresponding row in section 0
        self.tableView.beginUpdates()
        if me.friendInvitations.count > 0 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 1)], withRowAnimation: .Automatic)
        } else {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }

    func didLeaveGroup(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let groupId = userInfo["idOfDeletedGroup"] as? String else { return }

        // see if the deleted group is exist in chat message list
        let indexInMessageList = self.messages.indexOf {

            // skip normal message
            guard let group = $0.group else { return false }

            return group.id == groupId
        }

        // do nothing if not found
        guard let index = indexInMessageList else { return }

        // sync group data with account model manually
        // remove the chat history from messages list
        self.messages.removeAtIndex(index)

        // update tableview, if the number of my invitation is zero, insert into section 1
        // otherwise, remove the corresponding row in section 0
        self.tableView.beginUpdates()
        if me.friendInvitations.count > 0 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 1)], withRowAnimation: .Automatic)
        } else {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }

    // This method is called for sync this view controller and accout model after sent message
    func didSendMessage(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let message = userInfo["messageEntityOfNewMessage"] as? MessageEntity else { return }

        let indexInMessageList: Int?

        // if the message is a group message
        if let group = message.group {

            // see if the group is exists in my message list
            indexInMessageList = self.messages.indexOf {
                $0.group?.id ==  group.id
            }

            // if the message is a normal message
        } else {

            // see if the message receiver is in my messages list
            indexInMessageList = self.messages.indexOf {

                // skip group message
                guard $0.group == nil else { return false }

                let user = ($0.from.id == me.id ? $0.to : $0.from)
                return user.id == message.to.id
            }
        }

        // if the group/sender in my message list, update the message list
        if let index = indexInMessageList {

            self.messages[index].content = message.content
            self.messages[index].createDate = message.createDate

            // TODO: gonna blow up if I put this in the update block below, don't know why
            if me.friendInvitations.count == 0 {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            } else {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .Automatic)
            }

            self.messages.insert(self.messages.removeAtIndex(index), atIndex: 0)

            // update tableview, if the number of my invitation is zero, reload the row in section 0
            // otherwise, reload the corresponding row in section 1
            self.tableView.beginUpdates()
            if me.friendInvitations.count == 0 {
                self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
            } else {
                self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: index, inSection: 1), toIndexPath: NSIndexPath(forRow: 0, inSection: 1))
            }
            self.tableView.endUpdates()

            // or insert into my message list at top
        } else {

            self.messages.insert(message, atIndex: 0)

            // update tableview, if the number of my invitation is zero, insert the row in section 0
            // otherwise, insert the corresponding row in section 1
            self.tableView.beginUpdates()
            if me.friendInvitations.count == 0 {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
            } else {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
            }
            self.tableView.endUpdates()
        }
    }

    // This method is called for sync this view controller and accout model after finish chat in some group
    func didFinishGroupChat(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let groupId = userInfo["idOfTalkedGroup"] as? String else { return }

        // see if the deleted group is exist in chat message list
        let indexInMessageList = self.messages.indexOf {

            // skip normal message
            guard let group = $0.group else { return false }

            return group.id == groupId
        }

        if let index = indexInMessageList {

            if me.friendInvitations.count == 0 {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            } else {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .Automatic)
            }
        }
    }

    // This method is called for sync this view controller and accout model after finish chat with someone
    func didFinishChat(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let userId = userInfo["idOfTalkedFriend"] as? String else { return }

        // see if the deleted user is exist in chat message list
        let indexInMessageList = self.messages.indexOf {

            // skip group message
            guard $0.group == nil else { return false }

            let friendId = ($0.from.id == me.id ? $0.to.id : $0.from.id)
            return friendId == userId
        }

        if let index = indexInMessageList {

            if me.friendInvitations.count == 0 {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            } else {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .Automatic)
            }
        }
    }

    // This method is called for sync this view controller and accout model after receive friend invitation
    func didReceiveFriendInvitation() {

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.Main) {

            // update tableview, if the number of my invitation is 1, insert whole section of 0
            // otherwise, insert the corresponding row in section 0 row0
            self.tableView.beginUpdates()
            if me.friendInvitations.count == 1 {
                self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            } else {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
            }
            self.tableView.endUpdates()
        }
    }

    // This method is called for sync this view controller and accout model after someone dump me
    func didFriendBreak(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let brokenUserId = userInfo["userIdOfBrokenFriend"] as? String else { return }

        // see if the deleted user is exist in chat message list
        let indexInMessageList = self.messages.indexOf {

            // skip group message
            guard $0.group == nil else { return false }

            let friendId = ($0.from.id == me.id ? $0.to.id : $0.from.id)
            return friendId == brokenUserId
        }

        // do nothing if not found
        guard let index = indexInMessageList else { return }

        // sync friends data with account model manually
        // remove the chat history from messages list
        self.messages.removeAtIndex(index)

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.Main) {

            // update tableview, if the number of my invitation is zero, remove from section 0
            // otherwise, insert the corresponding row from section 1
            self.tableView.beginUpdates()
            if me.friendInvitations.count == 0 {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            } else {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .Automatic)
            }
            self.tableView.endUpdates()
        }
    }

    func didReceiveMessage(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let message = userInfo["messageEntityOfNewMessage"] as? MessageEntity else { return }

        let indexInMessageList: Int?

        // if the message is a group message
        if let group = message.group {

            // see if the group is exists in my message list
            indexInMessageList = self.messages.indexOf {
                $0.group?.id ==  group.id
            }

            // if the message is a normal message
        } else {

            // see if the message sender is in my messages list
            indexInMessageList = self.messages.indexOf {
                
                // skip group message
                guard $0.group == nil else { return false }

                let user = ($0.from.id == me.id ? $0.to : $0.from)
                return user.id == message.from.id
            }
        }

        // if the group/sender in my message list, update the message list
        if let index = indexInMessageList {

            self.messages[index].content = message.content
            self.messages[index].createDate = message.createDate

            // this method is called from background thread (because it fired from notification center)
            // must switch to main thread for UI updating
            gcd.sync(.Main) {

                // TODO: gonna blow up if I put this in the update block below, don't know why
                if me.friendInvitations.count == 0 {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
                } else {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .Automatic)
                }

                self.messages.insert(self.messages.removeAtIndex(index), atIndex: 0)

                // update tableview, if the number of my invitation is zero, reload the row in section 0
                // otherwise, reload the corresponding row in section 1
                self.tableView.beginUpdates()
                if me.friendInvitations.count == 0 {
                    self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                } else {
                    self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: index, inSection: 1), toIndexPath: NSIndexPath(forRow: 0, inSection: 1))
                }
                self.tableView.endUpdates()

            }

            // or insert into my message list at top
        } else {

            self.messages.insert(message, atIndex: 0)

            // this method is called from background thread (because it fired from notification center)
            // must switch to main thread for UI updating
            gcd.sync(.Main) {

                // update tableview, if the number of my invitation is zero, insert the row in section 0
                // otherwise, insert the corresponding row in section 1
                self.tableView.beginUpdates()
                if me.friendInvitations.count == 0 {
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
                } else {
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
                }
                self.tableView.endUpdates()
            }
        }

    }
}

// MARK: - MessageTableViewCell

final class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var message: MessageEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        let user: UserEntity

        // TODO: when the message come from socket, it don't have "to".
        // but it's ok, cuase it must sent "to me". so I can't use 'to' to check user
        if self.message.from.id == me.id {
            user = self.message.to
        } else {
            user = self.message.from
        }

        if let photo = user.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.nickNameLabel.text = user.nickName

        self.contentLabel.text = self.getMediaString()

        self.dateLabel.text = self.message.createDate.relativeTimeToString()

        let count = me.newMessages.reduce(0, combine: { (count, message) -> Int in

            // skip group message
            guard message.group == nil else { return count }

            if message.from.id == user.id {
                return count + 1
            } else {
                return count
            }
        })

        if count > 0 {
            self.countLabel.hidden = false
            self.countLabel.text = String(count)
        } else {
            self.countLabel.hidden = true
        }
    }

    private func getMediaString()-> String {
        let msg = self.message.from.id == me.id ? "您发送了" : "发给您"
        switch self.message.type {
        case .photo:
            return "\(msg)一张图片"
        case .voice:
            return "\(msg)一段语音"
        case .video:
            return "\(msg)一段视频"
        case .text:
            return self.message.content
        }
    }
}

// MARK: - GrouopMessageTableViewCell

final class GroupMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var message: MessageEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        guard let group = self.message.group else { return }

        if let cover = group.cover {
            self.coverImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: TomoConst.Image.DefaultGroup)
        }

        self.nameLabel.text = group.name

        self.contentLabel.text = self.getMediaString()

        self.dateLabel.text = self.message.createDate.relativeTimeToString()

        let count = me.newMessages.reduce(0, combine: { (count, message) -> Int in
            if message.group?.id == group.id {
                return count + 1
            } else {
                return count
            }
        })

        if count > 0 {
            countLabel.hidden = false
            countLabel.text = String(count)
        } else {
            countLabel.hidden = true
        }
    }

    private func getMediaString()-> String {
        let msg = self.message.from.id == me.id ? "您发送了" : "发给您"
        switch self.message.type {
        case .photo:
            return "\(msg)一张图片"
        case .voice:
            return "\(msg)一段语音"
        case .video:
            return "\(msg)一段视频"
        case .text:
            return self.message.content
        }
    }
}


// MARK: - FriendInvitationTableViewCell

final class FriendInvitationTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    weak var delegate: UIViewController!

    var invitation: NotificationEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        let user = invitation.from

        if let photo = user.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.userNameLabel.text = user.nickName

    }

    @IBAction func accept(sender: UIButton) {

        Router.Invitation.ModifyById(id: self.invitation.id, accepted: true).response {
            if $0.result.isFailure { return }
            me.acceptInvitation(self.invitation)
        }
    }

    @IBAction func refuse(sender: UIButton) {

        Util.alert(delegate, title: "拒绝好友邀请", message: "拒绝 " + self.invitation.from.nickName + " 的好友邀请么") { _ in
            Router.Invitation.ModifyById(id: self.invitation.id, accepted: false).response {
                if $0.result.isFailure { return }
                me.refuseInvitation(self.invitation)
            }
        }
    }
}

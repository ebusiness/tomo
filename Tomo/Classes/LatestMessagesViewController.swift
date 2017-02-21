//
//  LatestMessagesViewController.swift
//  Tomo
//
//  Created by ebuser on 2016/02/01.
//  Copyright © 2016 e-business. All rights reserved.
//

import UIKit

final class LatestMessagesViewController: UITableViewController {

    @IBOutlet weak fileprivate var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak fileprivate var emptyResultView: UIView!

    var messages = [MessageEntity]()

    var isLoading = false

    override func viewDidLoad() {

        super.viewDidLoad()

        self.loadLatestMessage()

        self.configEventObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueForChatDetail(segue, sender: sender)
    }

    private func segueForChatDetail(_ segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "SegueChatDetail" { return }
        guard let vc = segue.destination as? ChatViewController else {
            return
        }
        vc.hidesBottomBarWhenPushed = true
        guard let message = sender as? MessageEntity else {
            return
        }

        if let group = message.group {
            vc.group = group
        } else {
            vc.friend = message.from.id == me.id ? message.to : message.from
        }
    }
}

// MARK: - UITableView datasource

extension LatestMessagesViewController {

    override func numberOfSections (in tableView: UITableView) -> Int {
        if !me.friendInvitations.isEmpty {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if !me.friendInvitations.isEmpty {

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        func makeInvitationCell() -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationCell", for: indexPath) as? FriendInvitationTableViewCell
            cell!.invitation = me.friendInvitations[indexPath.item]
            cell!.delegate = self
            return cell!
        }

        func makeMessageCell() -> UITableViewCell {

            let message = self.messages[indexPath.item]

            if message.group != nil {

                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMessageCell", for: indexPath) as? GroupMessageTableViewCell
                cell!.message = message
                return cell!

            } else {

                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageTableViewCell
                cell!.message = message
                return cell!
            }
        }

        if !me.friendInvitations.isEmpty {

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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if !me.friendInvitations.isEmpty {

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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if me.friendInvitations.isEmpty {

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
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if me.friendInvitations.isEmpty {
            return 10
        }
        return 38
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let message = self.messages[indexPath.row]

        self.performSegue(withIdentifier: "SegueChatDetail", sender: message)
    }
}

// MARK: - Internal Methods

extension LatestMessagesViewController {

    fileprivate func loadLatestMessage() {

        // skip if already in loading
        if self.isLoading {
            return
        }

        self.isLoading = true

        Router.Message.Latest.response {

            self.loadingIndicator.stopAnimating()

            if $0.result.isFailure {
                self.isLoading = false

                if me.friendInvitations.isEmpty {
                    self.showEmptyResultView()
                }

                return
            }

            if let messages: [MessageEntity] = MessageEntity.collection($0.result.value!) {

                self.messages += messages.sorted {
                    $0.createDate.compare($1.createDate) == ComparisonResult.orderedDescending
                }

                // let table view display new contents
                self.appendRows(rows: messages.count, inSection: me.friendInvitations.isEmpty ? 0 : 1)
            }
        }
    }

    // Append specific number of rows on table view
    fileprivate func appendRows(rows: Int, inSection section: Int) {

        let firstIndex = self.messages.count - rows
        let lastIndex = self.messages.count

        var indexPathes = [IndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.append(IndexPath(row: index, section: section))
        }

        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .fade)
        tableView.endUpdates()
    }

    fileprivate func showEmptyResultView() {
        self.tableView.tableFooterView?.frame = TomoConst.UI.ViewFrameMiddleFullScreen
        UIView.animate(withDuration: TomoConst.Duration.Short) {
            self.emptyResultView.alpha = 1.0
        }
    }

    fileprivate func hideEmptyResultView() {
        self.tableView.tableFooterView?.frame = TomoConst.UI.ViewFrameTopBarHeight
        UIView.animate(withDuration: TomoConst.Duration.Short) {
            self.emptyResultView.alpha = 0.0
        }
    }
}

// MARK: - Event Observer

extension LatestMessagesViewController {

    fileprivate func configEventObserver() {

        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didRefuseInvitation(_:)), name: NSNotification.Name(rawValue: "didRefuseInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didAcceptInvitation(_:)), name: NSNotification.Name(rawValue: "didAcceptInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didDeleteFriend(_:)), name: NSNotification.Name(rawValue: "didDeleteFriend"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didLeaveGroup(_:)), name: NSNotification.Name(rawValue: "didLeaveGroup"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didSendMessage(_:)), name: NSNotification.Name(rawValue: "didSendMessage"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didFinishGroupChat(_:)), name: NSNotification.Name(rawValue: "didFinishGroupChat"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didFinishChat(_:)), name: NSNotification.Name(rawValue: "didFinishChat"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LatestMessagesViewController.didMyFriendInvitationAccepted(_:)),
                                               name: NSNotification.Name(rawValue: "didMyFriendInvitationAccepted"), object: me)

        // notification from background thread
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LatestMessagesViewController.didReceiveFriendInvitation),
                                               name: NSNotification.Name(rawValue: "didReceiveFriendInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didFriendBreak(_:)), name: NSNotification.Name(rawValue: "didFriendBreak"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestMessagesViewController.didReceiveMessage(_:)), name: NSNotification.Name(rawValue: "didReceiveMessage"), object: me)
    }

    // This method is called for sync this view controller and accout model after refuse invitation
    func didRefuseInvitation(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let index = userInfo["indexOfRemovedInvitation"] as? Int else { return }

        // update tableview, if the number of my invitation is zero, remove the whole section of 0
        // otherwise, remove the corresponding row in section 0, note the invitation data is referring
        // the accout model directly, so the data is removed just in accout model, no need to do that here
        self.tableView.beginUpdates()
        if !me.friendInvitations.isEmpty {
            self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        } else {
            self.tableView.deleteSections([0], with: .automatic)
            // refresh the title of section 1
            self.tableView.headerView(forSection: 1)?.textLabel?.text = self.tableView(self.tableView, titleForHeaderInSection: 1)
        }
        self.tableView.endUpdates()

        if me.friendInvitations.isEmpty && self.messages.isEmpty {
            self.showEmptyResultView()
        }
    }

    // This method is called for sync this view controller and accout model after accept invitation
    func didAcceptInvitation(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let index = userInfo["indexOfRemovedInvitation"] as? Int else { return }

        self.tableView.beginUpdates()
        // if the number of my invitation is zero, remove the whole section of 0
        // otherwise, remove the corresponding row in section 0
        if !me.friendInvitations.isEmpty {
            self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        } else {
            self.tableView.deleteSections([0], with: .automatic)
            // refresh the title of section 1
            self.tableView.headerView(forSection: 1)?.textLabel?.text = self.tableView(self.tableView, titleForHeaderInSection: 1)
        }
        self.tableView.endUpdates()

        if me.friendInvitations.isEmpty && self.messages.isEmpty {
            self.showEmptyResultView()
        }
    }

    // This method is called for sync this view controller and accout model after delete friend
    func didDeleteFriend(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let id = userInfo["idOfDeletedFriend"] as? String else { return }

        // see if the deleted user is exist in chat message list
        let indexInMessageList = self.messages.index {

            // skip group message
            guard $0.group == nil else { return false }

            let friendId = ($0.from.id == me.id ? $0.to.id : $0.from.id)
            return friendId == id
        }

        // do nothing if not found
        guard let index = indexInMessageList else { return }

        // sync friends data with account model manually
        // remove the chat history from messages list
        self.messages.remove(at: index)

        // update tableview, if the number of my invitation is zero, insert into section 1
        // otherwise, remove the corresponding row in section 0
        self.tableView.beginUpdates()
        if !me.friendInvitations.isEmpty {
            self.tableView.deleteRows(at: [IndexPath(item: index, section: 1)], with: .automatic)
        } else {
            self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        }
        self.tableView.endUpdates()

        if me.friendInvitations.isEmpty && self.messages.isEmpty {
            self.showEmptyResultView()
        }
    }

    func didLeaveGroup(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let groupId = userInfo["idOfDeletedGroup"] as? String else { return }

        // see if the deleted group is exist in chat message list
        let indexInMessageList = self.messages.index {

            // skip normal message
            guard let group = $0.group else { return false }

            return group.id == groupId
        }

        // do nothing if not found
        guard let index = indexInMessageList else { return }

        // sync group data with account model manually
        // remove the chat history from messages list
        self.messages.remove(at: index)

        // update tableview, if the number of my invitation is zero, insert into section 1
        // otherwise, remove the corresponding row in section 0
        self.tableView.beginUpdates()
        if !me.friendInvitations.isEmpty {
            self.tableView.deleteRows(at: [IndexPath(item: index, section: 1)], with: .automatic)
        } else {
            self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        }
        self.tableView.endUpdates()

        if me.friendInvitations.isEmpty && self.messages.isEmpty {
            self.showEmptyResultView()
        }
    }

    // This method is called for sync this view controller and accout model after sent message
    func didSendMessage(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let message = userInfo["messageEntityOfNewMessage"] as? MessageEntity else { return }

        let indexInMessageList: Int?

        // if the message is a group message
        if let group = message.group {

            // see if the group is exists in my message list
            indexInMessageList = self.messages.index {
                $0.group?.id ==  group.id
            }

            // if the message is a normal message
        } else {

            // see if the message receiver is in my messages list
            indexInMessageList = self.messages.index {

                // skip group message
                guard $0.group == nil else { return false }

                let user = ($0.from.id == me.id ? $0.to : $0.from)
                return user!.id == message.to.id
            }
        }

        // if the group/sender in my message list, update the message list
        if let index = indexInMessageList {

            self.messages[index].type = message.type
            self.messages[index].content = message.content
            self.messages[index].createDate = message.createDate

            // TODO: gonna blow up if I put this in the update block below, don't know why
            if me.friendInvitations.isEmpty {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            } else {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
            }

            self.messages.insert(self.messages.remove(at: index), at: 0)

            // update tableview, if the number of my invitation is zero, reload the row in section 0
            // otherwise, reload the corresponding row in section 1
            self.tableView.beginUpdates()
            if me.friendInvitations.isEmpty {
                self.tableView.moveRow(at: IndexPath(row: index, section: 0), to: IndexPath(row: 0, section: 0))
            } else {
                self.tableView.moveRow(at: IndexPath(row: index, section: 1), to: IndexPath(row: 0, section: 1))
            }
            self.tableView.endUpdates()

            // or insert into my message list at top
        } else {

            self.messages.insert(message, at: 0)

            // update tableview, if the number of my invitation is zero, insert the row in section 0
            // otherwise, insert the corresponding row in section 1
            self.tableView.beginUpdates()
            if me.friendInvitations.isEmpty {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            } else {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            }
            self.tableView.endUpdates()
        }

        self.hideEmptyResultView()
    }

    // This method is called for sync this view controller and accout model after finish chat in some group
    func didFinishGroupChat(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let groupId = userInfo["idOfTalkedGroup"] as? String else { return }

        // see if the deleted group is exist in chat message list
        let indexInMessageList = self.messages.index {

            // skip normal message
            guard let group = $0.group else { return false }

            return group.id == groupId
        }

        if let index = indexInMessageList {

            if me.friendInvitations.isEmpty {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            } else {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
            }
        }
    }

    // This method is called for sync this view controller and accout model after finish chat with someone
    func didFinishChat(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let userId = userInfo["idOfTalkedFriend"] as? String else { return }

        // see if the deleted user is exist in chat message list
        let indexInMessageList = self.messages.index {

            // skip group message
            guard $0.group == nil else { return false }

            let friendId = ($0.from.id == me.id ? $0.to.id : $0.from.id)
            return friendId == userId
        }

        if let index = indexInMessageList {

            if me.friendInvitations.isEmpty {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            } else {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
            }
        }
    }

    // This method is called for sync this view controller and accout model after my friend invitation was accepted
    func didMyFriendInvitationAccepted(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let index = userInfo["indexOfRemovedInvitation"] as? Int else { return }

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.main) {
            self.tableView.beginUpdates()
            // if the number of my invitation is zero, remove the whole section of 0
            // otherwise, remove the corresponding row in section 0
            if !me.friendInvitations.isEmpty {
                self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
            } else {
                self.tableView.deleteSections([0], with: .automatic)
                // refresh the title of section 1
                self.tableView.headerView(forSection: 1)?.textLabel?.text = self.tableView(self.tableView, titleForHeaderInSection: 1)
            }
            self.tableView.endUpdates()
        }
    }

    // This method is called for sync this view controller and accout model after receive friend invitation
    func didReceiveFriendInvitation() {

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.main) {

            // update tableview, if the number of my invitation is 1, insert whole section of 0
            // otherwise, insert the corresponding row in section 0 row0
            self.tableView.beginUpdates()
            if me.friendInvitations.count == 1 {
                // refresh the title of section 0(message section)
                self.tableView.headerView(forSection: 0)?.textLabel?.text = self.tableView(self.tableView, titleForHeaderInSection: 1)
                self.tableView.insertSections([0], with: .automatic)
            } else {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            self.tableView.endUpdates()

            self.hideEmptyResultView()
        }
    }

    // This method is called for sync this view controller and accout model after someone dump me
    func didFriendBreak(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let brokenUserId = userInfo["userIdOfBrokenFriend"] as? String else { return }

        // see if the deleted user is exist in chat message list
        let indexInMessageList = self.messages.index {

            // skip group message
            guard $0.group == nil else { return false }

            let friendId = ($0.from.id == me.id ? $0.to.id : $0.from.id)
            return friendId == brokenUserId
        }

        // do nothing if not found
        guard let index = indexInMessageList else { return }

        // sync friends data with account model manually
        // remove the chat history from messages list
        self.messages.remove(at: index)

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.main) {

            // update tableview, if the number of my invitation is zero, remove from section 0
            // otherwise, insert the corresponding row from section 1
            self.tableView.beginUpdates()
            if me.friendInvitations.isEmpty {
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
            }
            self.tableView.endUpdates()

            if me.friendInvitations.isEmpty && self.messages.isEmpty {
                self.showEmptyResultView()
            }
        }
    }

    func didReceiveMessage(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let message = userInfo["messageEntityOfNewMessage"] as? MessageEntity else { return }

        let indexInMessageList: Int?

        // if the message is a group message
        if let group = message.group {

            // see if the group is exists in my message list
            indexInMessageList = self.messages.index {
                $0.group?.id ==  group.id
            }

            // if the message is a normal message
        } else {

            // see if the message sender is in my messages list
            indexInMessageList = self.messages.index {

                // skip group message
                guard $0.group == nil else { return false }

                let user = ($0.from.id == me.id ? $0.to : $0.from)
                return user!.id == message.from.id
            }
        }

        // if the group/sender in my message list, update the message list
        if let index = indexInMessageList {

            self.messages[index].type = message.type
            self.messages[index].content = message.content
            self.messages[index].createDate = message.createDate

            // this method is called from background thread (because it fired from notification center)
            // must switch to main thread for UI updating
            gcd.sync(.main) {

                // TODO: gonna blow up if I put this in the update block below, don't know why
                if me.friendInvitations.isEmpty {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                } else {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
                }

                self.messages.insert(self.messages.remove(at: index), at: 0)

                // update tableview, if the number of my invitation is zero, reload the row in section 0
                // otherwise, reload the corresponding row in section 1
                self.tableView.beginUpdates()
                if me.friendInvitations.isEmpty {
                    self.tableView.moveRow(at: IndexPath(row: index, section: 0), to: IndexPath(row: 0, section: 0))
                } else {
                    self.tableView.moveRow(at: IndexPath(row: index, section: 1), to: IndexPath(row: 0, section: 1))
                }
                self.tableView.endUpdates()

                self.hideEmptyResultView()
            }

            // or insert into my message list at top
        } else {

            self.messages.insert(message, at: 0)

            // this method is called from background thread (because it fired from notification center)
            // must switch to main thread for UI updating
            gcd.sync(.main) {

                // update tableview, if the number of my invitation is zero, insert the row in section 0
                // otherwise, insert the corresponding row in section 1
                self.tableView.beginUpdates()
                if me.friendInvitations.isEmpty {
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                } else {
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                }
                self.tableView.endUpdates()

                self.hideEmptyResultView()
            }
        }

    }
}

// MARK: - MessageTableViewCell

final class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak fileprivate var avatarImageView: UIImageView!
    @IBOutlet weak fileprivate var countLabel: UILabel!
    @IBOutlet weak fileprivate var nickNameLabel: UILabel!
    @IBOutlet weak fileprivate var contentLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!

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
            self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.nickNameLabel.text = user.nickName

        self.contentLabel.text = self.getMediaString()

        self.dateLabel.text = self.message.createDate.relativeTimeToString()

        let messageCount = me.newMessages.reduce(0, { (count, message) -> Int in

            // skip group message
            guard message.group == nil else { return count }

            if message.from.id == user.id {
                return count + 1
            } else {
                return count
            }
        })

        if messageCount > 0 {
            self.countLabel.isHidden = false
            self.countLabel.text = String(messageCount)
        } else {
            self.countLabel.isHidden = true
        }
    }

    private func getMediaString()-> String {
        let msg = self.message.from.id == me.id ? "您发送了" : "给您发送了"
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

    @IBOutlet weak fileprivate var coverImageView: UIImageView!
    @IBOutlet weak fileprivate var countLabel: UILabel!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var contentLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!

    var message: MessageEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        guard let group = self.message.group else { return }

        if let cover = group.cover {
            self.coverImageView.sd_setImage(with: URL(string: cover), placeholderImage: TomoConst.Image.DefaultGroup)
        }

        self.nameLabel.text = group.name

        self.contentLabel.text = self.getMediaString()

        self.dateLabel.text = self.message.createDate.relativeTimeToString()

        let messageCount = me.newMessages.reduce(0, { (count, message) -> Int in
            if message.group?.id == group.id {
                return count + 1
            } else {
                return count
            }
        })

        if messageCount > 0 {
            countLabel.isHidden = false
            countLabel.text = String(messageCount)
        } else {
            countLabel.isHidden = true
        }
    }

    private func getMediaString()-> String {
        let msg = self.message.from.id == me.id ? "您发送了" : "给您发送了"
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

    @IBOutlet weak fileprivate var avatarImageView: UIImageView!
    @IBOutlet weak fileprivate var userNameLabel: UILabel!

    weak var delegate: UIViewController!

    var invitation: NotificationEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        let user = invitation.from

        if let photo = user?.photo {
            self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.userNameLabel.text = user?.nickName

    }

    @IBAction func accept(_ sender: UIButton) {

        Router.Invitation.ModifyById(id: self.invitation.id, accepted: true).response {
            if $0.result.isFailure { return }
            me.acceptInvitation(invitation: self.invitation)
        }
    }

    @IBAction func refuse(_ sender: UIButton) {

        Util.alert(parentvc: delegate, title: "拒绝好友邀请", message: "拒绝 " + self.invitation.from.nickName + " 的好友邀请么") { _ in
            Router.Invitation.ModifyById(id: self.invitation.id, accepted: false).response {
                if $0.result.isFailure { return }
                me.refuseInvitation(invitation: self.invitation)
            }
        }
    }
}

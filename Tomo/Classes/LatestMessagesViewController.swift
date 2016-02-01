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

        self.loadContacts()
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

//        if let group = self.messageContacts[indexPath.row] as? GroupEntity {
//            let vc = GroupChatViewController()
//            vc.hidesBottomBarWhenPushed = true
//            vc.group = group
//            navigationController?.pushViewController(vc, animated: true)
//            return
//        }

        let vc = MessageViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.friend = self.messages[indexPath.row].from
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Internal Methods

extension LatestMessagesViewController {

    private func loadContacts() {

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

                self.messages += messages.reverse()

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

        if self.message.to.id == me.id {
            user = self.message.from
        } else {
            user = self.message.to
        }

        if let photo = user.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.nickNameLabel.text = user.nickName

        self.contentLabel.text = self.getMediaString()

        self.dateLabel.text = self.message.createDate.relativeTimeToString()

        let count = me.newMessages.reduce(0, combine: { (count, message) -> Int in
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

        self.contentLabel.text = self.message.content

        self.dateLabel.text = self.message.createDate.relativeTimeToString()
    }
}
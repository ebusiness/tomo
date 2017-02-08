//
//  NotificationListViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/09/04.
//  Copyright © 2015 e-business. All rights reserved.
//


import UIKit

final class NotificationListViewController: UITableViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var loadingLabel: UILabel!

    fileprivate var notifications = [NotificationEntity]()

    fileprivate var isLoading = false
    fileprivate var isExhausted = false

    override func viewDidLoad() {

        super.viewDidLoad()

        self.loadMoreContent()

        self.configEventObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // let account model marks all notification checked
        me.checkAllNotification()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: UIScrollView Delegate

extension NotificationListViewController {

    // Fetch more contents when scroll down to bottom
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        // trigger on the position of one screen height to bottom
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            self.loadMoreContent()
        }
    }
}

// MARK: - UITableView DataSource

extension NotificationListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? NotificationCell
        cell?.notification = self.notifications[indexPath.row]
        return cell!
    }
}

// MARK: - UITableView Delegate

extension NotificationListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? NotificationCell
        cell?.didSelect(vc: self)
    }
}

// MARK: - Internal Methods

extension NotificationListViewController {

    fileprivate func loadMoreContent() {

        // skip if already in loading or no more contents
        if self.isLoading || self.isExhausted {
            return
        }

        self.isLoading = true

        let notification = Router.Setting.FindNotification(before: self.notifications.last?.createDate.timeIntervalSince1970)

        notification.response {

            // Mark as exhausted when something wrong (probably 404)
            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = false
                return
            }

            if let loadNotifications:[NotificationEntity] = NotificationEntity.collection($0.result.value!) {
                self.notifications += loadNotifications
                self.appendRows(rows: loadNotifications.count)
            }

            self.isLoading = false
        }
    }

    fileprivate func appendRows(rows: Int) {

        let notificationsCount = self.notifications.count
        let firstIndex = notificationsCount - rows
        let lastIndex = notificationsCount

        var indexPathes = [IndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.append(IndexPath(row: index, section: 0))
        }

        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .fade)
        tableView.endUpdates()
    }
}

// MARK: - Event Observer

extension NotificationListViewController {

    fileprivate func configEventObserver() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotificationListViewController.didReceiveNotification(_:)),
                                               name: NSNotification.Name(rawValue: "didMyFriendInvitationAccepted"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotificationListViewController.didReceiveNotification(_:)),
                                               name: NSNotification.Name(rawValue: "didMyFriendInvitationRefused"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationListViewController.didReceiveNotification(_:)), name: NSNotification.Name(rawValue: "didFriendBreak"), object: me)

        NotificationCenter.default.addObserver(self, selector: #selector(NotificationListViewController.didReceiveNotification(_:)), name: NSNotification.Name(rawValue: "didReceivePost"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationListViewController.didReceiveNotification(_:)), name: NSNotification.Name(rawValue: "didPostLiked"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotificationListViewController.didReceiveNotification(_:)),
                                               name: NSNotification.Name(rawValue: "didPostCommented"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotificationListViewController.didReceiveNotification(_:)),
                                               name: NSNotification.Name(rawValue: "didPostBookmarked"), object: me)
    }

    func didReceiveNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return}
        let remoteNotification = NotificationEntity(userInfo)

        self.notifications.insert(remoteNotification, at: 0)

        gcd.sync(.main) {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            self.tableView.endUpdates()
        }
    }
}

// MARK: NotificationCell

final class NotificationCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var nickNameLabelView: UILabel!

    @IBOutlet weak var messageLabelView: UILabel!

    @IBOutlet weak var createDateLabelView: UILabel!

    var notification: NotificationEntity! {
        didSet{

            if let photo = self.notification.from.photo {
                self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: defaultAvatarImage)
            }

            self.nickNameLabelView.text = self.notification.from.nickName
            self.messageLabelView.text = self.getNotificationContent()
            self.createDateLabelView.text = self.notification.createDate.relativeTimeToString()
        }
    }
}

extension NotificationCell {

    func didSelect(vc: UIViewController) {
        guard let type = ListenerEvent(rawValue: self.notification.type) else { return }
        switch type {
        case .Announcement:
            //                print("系统通知")
            return
        case .FriendAccepted, .FriendRefused, .FriendBreak: // User
            //                print("接受了您的好友请求")
            //                print("拒绝了您的好友邀请")
            //                print("解除了与您的好友关系")
            self.presentProfileView(vc: vc)
        case .PostNew, .PostLiked, .PostCommented, .PostBookmarked: // Post
            //                print("发表了新的帖子")
            //                print("赞了您的帖子")
            //                print("评论了您的帖子")
            //                print("收藏了您的帖子")
            self.presentPostView(vc: vc)
        case .GroupJoined: // Group
            //                print("加入了您的群组")
            self.presentGroupView(vc: vc)
        default:
            break
        }
    }
}

extension NotificationCell {

    fileprivate func getNotificationContent() ->String {
        guard let type = ListenerEvent(rawValue: self.notification.type) else { return "未知处理" }
        var message = self.notification.type
        switch type {
        case .Announcement:
            message = "系统通知"
        case .FriendAccepted:
            message = "接受了您的好友请求"
        case .FriendRefused:
            message = "拒绝了您的好友邀请"
        case .FriendBreak:
            message = "解除了与您的好友关系"
        case .PostNew:
            message = "发表了新的帖子"
        case .PostLiked:
            message = "赞了您的帖子"
        case .PostCommented:
            message = "评论了您的帖子"
        case .PostBookmarked:
            message = "收藏了您的帖子"
        case .GroupJoined:
            message = "加入了您的群组"
        case .GroupLeft:
            message = "退出了您的群组"
        default:
            message = "未知处理"
        }
        return message!
    }

    fileprivate func presentProfileView(vc: UIViewController) {
        let profileVC = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
        profileVC?.user = self.notification.from
        vc.navigationController?.pushViewController(profileVC!, animated: true)
    }

    fileprivate func presentPostView(vc: UIViewController) {
        Router.Post.FindById(id: self.notification.targetId).response {
            if $0.result.isFailure { return }

            let postVC = Util.createViewControllerWithIdentifier(id: "PostDetailViewController", storyboardName: "Home") as? PostDetailViewController
            postVC?.post = PostEntity($0.result.value!)
            if postVC?.post.id == self.notification.targetId {
                vc.navigationController?.pushViewController(postVC!, animated: true)
            } else {
                Util.showInfo(title: "帖子已被删除")
            }
        }
    }

    fileprivate func presentGroupView(vc: UIViewController) {
        Router.Group.FindById(id: self.notification.targetId).response {
            if $0.result.isFailure { return }

            let groupVC = Util.createViewControllerWithIdentifier(id: "GroupDetailView", storyboardName: "Group") as? GroupDetailViewController
            groupVC?.group = GroupEntity($0.result.value!)
            vc.navigationController?.pushViewController(groupVC!, animated: true)
        }
    }
}

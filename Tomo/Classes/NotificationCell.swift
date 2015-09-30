//
//  NotificationCell.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class NotificationCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabelView: UILabel!
    @IBOutlet weak var messageLabelView: UILabel!
    @IBOutlet weak var createDateLabelView: UILabel!
    
    var notification: NotificationEntity! {
        didSet{
            
            if let photo = self.notification.from.photo {
                self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
            } else {
                self.avatarImageView.image = DefaultAvatarImage
            }
            
            self.nickNameLabelView.text = self.notification.from.nickName
            self.messageLabelView.text = self.getNotificationContent()
            self.createDateLabelView.text = self.notification.createDate.relativeTimeToString()
        }
    }
}

extension NotificationCell {
    
    func didSelect(vc: UIViewController) {
        if let type = ListenerEvent(rawValue: self.notification.type) {
            switch type {
            case .Announcement:
                println("系统通知")
            case .FriendAccepted, .FriendRefused, .FriendBreak: // User
//                println("接受了您的好友请求")
//                println("拒绝了您的好友邀请")
//                println("解除了与您的好友关系")
                self.presentProfileView(vc)
            case .PostNew, .PostLiked, .PostCommented, .PostBookmarked: // Post
//                println("发表了新的帖子")
//                println("赞了您的帖子")
//                println("评论了您的帖子")
//                println("收藏了您的帖子")
                self.presentPostView(vc)
            case .GroupJoined: // Group
//                println("加入了您的群组")
                self.presentGroupView(vc)
            default:
                break
            }
        }
    }
}

extension NotificationCell {
    
    private func getNotificationContent() ->String {
        if let type = ListenerEvent(rawValue: self.notification.type) {
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
            default:
                break
            }
            return message
        }
        return "未知处理"
    }
    
    private func presentProfileView(vc: UIViewController) {
        let profileVC = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        profileVC.user = self.notification.from
        vc.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func presentPostView(vc: UIViewController) {
        AlamofireController.request(.GET, "/posts/\(self.notification.targetId)", success: { result in
            let postVC = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
            postVC.post = PostEntity(result)
            vc.navigationController?.pushViewController(postVC, animated: true)
        }) { err in
                
        }
    }
    
    private func presentGroupView(vc: UIViewController) {
        AlamofireController.request(.GET, "/groupd/\(self.notification.targetId)", success: { result in
            let groupVC = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
            groupVC.group = GroupEntity(result)
            vc.navigationController?.pushViewController(groupVC, animated: true)
        }) { err in
                
        }
    }
}
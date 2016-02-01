//
//  ProfileViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import SwiftyJSON

final class ProfileViewController: UITableViewController {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var bioLabel: UILabel!

    @IBOutlet weak var genderLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var fullNameLabel: UILabel!

    @IBOutlet weak var birthDayLabel: UILabel!

    @IBOutlet weak var addFriendButton: UIButton!

    @IBOutlet weak var messageButton: UIButton!

    @IBOutlet weak var acceptButton: UIButton!

    @IBOutlet weak var refuseButton: UIButton!

    // Displayed User Entity
    var user: UserEntity!

    // The relationship of me and displayed user
    var relation = Relation.Stranger

    let headerViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.ScreenHeight * 0.382 + 58)

    enum Relation {

        case Stranger

        case Friend

        case InvitedByMe

        case InvitedingMe

        case Blocking

        func message(user: UserEntity) -> String {
            switch self {
            case .InvitedByMe:
                return "好友邀请已发送，请等待对方接受"
            case .Blocking:
                return "您已屏蔽此用户"
            default:
                return ""
            }
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.configUserStatus()

        // config display here or there will be a jump after the user info reload below
        self.configDisplay()

        // load fully populated user entity
        Router.User.FindById(id: self.user.id).response {

            if $0.result.isFailure { return }

            self.user = UserEntity($0.result.value!)

            // config display with fully populate user entity
            self.configUserInfo()
        }

        self.configEventObserver()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserPostsViewController {
            vc.user = self.user
        }
    }

    override func viewWillDisappear(animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(animated: Bool) {
        // make the navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - @IBAction

extension ProfileViewController {
    
    @IBAction func acceptInvitation(sender: UIButton) {
        self.invitationAccept(true)
    }
    
    @IBAction func refuseInvitation(sender: UIButton) {
        Util.alert(self, title: "拒绝好友邀请", message: "拒绝 " + self.user.nickName + " 的好友邀请么") { _ in
            self.invitationAccept(false)
        }
    }

    @IBAction func moreBtnTapped(sender: AnyObject) {
        
        var optionalList = Dictionary<String,((UIAlertAction!) -> Void)!>()

        if self.user.id != me.id {
            optionalList["举报此用户"] = { (_) -> Void in
                
                Util.alert(self, title: "举报用户", message: "您确定要举报此用户吗？") { _ in
                    Router.Report.User(id: self.user.id).request
                }
            }
        }
        
        if self.user.id != me.id {
            
            if let blockUsers = me.blockUsers where blockUsers.contains(self.user.id) {
                
                optionalList["取消屏蔽"] = { (_) -> Void in
                    Router.User.Block(id: self.user.id).response {
                        if $0.result.isFailure { return }
                        me.blockUsers?.remove(self.user.id)
                    }
                }
                
            } else {
                
                optionalList["屏蔽此用户"] = { (_) -> Void in
                    
                    Util.alert(self, title: "屏蔽用户", message: "您确定要屏蔽此用户吗？") { _ in
                        Router.User.Block(id: self.user.id).response {
                            if $0.result.isFailure { return }
                            me.blockUsers?.append(self.user.id)
                        }
                    }
                }
            }
            
        }
        
        if let friends = me.friends where friends.contains(self.user.id) {
            optionalList["删除好友"] = { (_) -> Void in
                
                Util.alert(self, title: "删除好友", message: "确定删除该好友么?") { _ in
                    Router.Contact.Delete(id: self.user.id).response {
                        if $0.result.isFailure { return }
                        me.deleteFriend(self.user)
                        self.configUserStatus()
                    }
                }
            }
        }
        
        Util.alertActionSheet(self, optionalDict: optionalList)
        
    }
    
    @IBAction func addFriend(sender: UIButton) {
        
        sender.userInteractionEnabled = false
        
        Router.Invitation.SendTo(id: self.user.id).response {

            if $0.result.isFailure {
                sender.userInteractionEnabled = true
                return
            }
            
            if me.invitations == nil {
                me.invitations = []
            }

            me.invitations?.append(self.user.id)

            sender.userInteractionEnabled = true

            self.configUserStatus()
        }
    }
    
    @IBAction func sendMessage(sender: UIButton) {

        // TODO: infinite loop here

        let messageViewController = self.navigationController?.childViewControllers.find { ($0 as? MessageViewController)?.friend.id == self.user.id } as? MessageViewController
        
        if let messageViewController = messageViewController {
            self.navigationController?.popToViewController(messageViewController, animated: true)
        } else {
            let vc = MessageViewController()
            vc.hidesBottomBarWhenPushed = true
            
            vc.friend = self.user
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Internal methods

extension ProfileViewController {

    func configUserStatus() {

        self.relation = .Stranger

        if let myFriends = me.friends where myFriends.contains(self.user.id) {
            self.relation = .Friend
        }

        if let myInvitations = me.invitations where myInvitations.contains(self.user.id) {
            self.relation = .InvitedByMe
        }

        if let _ = me.friendInvitations.find({ $0.from.id == self.user.id }) {
            self.relation = .InvitedingMe
        }

        self.statusLabel.text = self.relation.message(self.user)

        switch self.relation {

        case .Stranger:
            self.addFriendButton.hidden = false
            self.messageButton.hidden = true
            self.acceptButton.hidden = true
            self.refuseButton.hidden = true

        case .Friend:
            self.addFriendButton.hidden = true
            self.messageButton.hidden = false
            self.acceptButton.hidden = true
            self.refuseButton.hidden = true

        case .InvitedByMe:
            self.addFriendButton.hidden = true
            self.messageButton.hidden = true
            self.acceptButton.hidden = true
            self.refuseButton.hidden = true

        case .InvitedingMe:
            self.addFriendButton.hidden = true
            self.messageButton.hidden = true
            self.acceptButton.hidden = false
            self.refuseButton.hidden = false

        case .Blocking:
            self.addFriendButton.hidden = true
            self.messageButton.hidden = true
            self.acceptButton.hidden = true
            self.refuseButton.hidden = true
        }
    }

    private func configDisplay() {

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: self.headerViewSize)

        // set title with user nickname
        self.navigationItem.title = self.user.nickName

        // give the buttons white border
        self.avatarImageView.layer.borderWidth = 2
        self.avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor

        self.addFriendButton.layer.borderWidth = 2
        self.addFriendButton.layer.borderColor = UIColor.whiteColor().CGColor

        self.messageButton.layer.borderWidth = 2
        self.messageButton.layer.borderColor = UIColor.whiteColor().CGColor

        self.acceptButton.layer.borderWidth = 2
        self.acceptButton.layer.borderColor = UIColor.whiteColor().CGColor

        self.refuseButton.layer.borderWidth = 2
        self.refuseButton.layer.borderColor = UIColor.whiteColor().CGColor

        self.configUserInfo()
    }

    private func configUserInfo() {

        if let cover = self.user.cover {
            self.coverImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: TomoConst.Image.DefaultCover)
        }

        if let photo = self.user.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        if self.user.firstName != nil && self.user.lastName != nil  {
            self.fullNameLabel.text = user.fullName()
        }

        if let bio = self.user.bio {
            self.bioLabel.text = bio
        }

        if let gender = self.user.gender {
            self.genderLabel.text = gender
        }

        if let birthDay = self.user.birthDay {
            self.birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }

        if let address = self.user.address {
            self.addressLabel.text = address
        }
    }

    private func invitationAccept(accept: Bool){

        let invitation = me.friendInvitations.find { $0.from.id == self.user.id }

        if let invitation = invitation {

            Router.Invitation.ModifyById(id: invitation.id, accepted: accept).response {

                if $0.result.isFailure { return }

                if accept {
                    me.acceptInvitation(invitation)
                } else {
                    me.refuseInvitation(invitation)
                }
            }
        }
    }

}

// MARK: - NSNotificationCenter

extension ProfileViewController {

    private func configEventObserver() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "configUserStatus", name: "didAcceptInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "configUserStatus", name: "didRefuseInvitation", object: me)

        // notification from background thread
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reviseUserStatus", name: "didReceiveFriendInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reviseUserStatus", name: "didMyFriendInvitationAccepted", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reviseUserStatus", name: "didMyFriendInvitationRefused", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reviseUserStatus", name: "didFriendBreak", object: me)
    }

    func reviseUserStatus() {
        gcd.sync(.Main) {
            self.configUserStatus()
        }
    }
}
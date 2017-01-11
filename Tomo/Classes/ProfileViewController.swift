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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserPostsViewController {
            vc.user = self.user
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        // make the navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - @IBAction

extension ProfileViewController {
    
    @IBAction func acceptInvitation(_ sender: UIButton) {
        self.invitationAccept(accept: true)
    }
    
    @IBAction func refuseInvitation(_ sender: UIButton) {
        Util.alert(parentvc: self, title: "拒绝好友邀请", message: "拒绝 " + self.user.nickName + " 的好友邀请么") { _ in
            self.invitationAccept(accept: false)
        }
    }

    @IBAction func moreBtnTapped(_ sender: Any) {
        
        var optionalList = Dictionary<String,((UIAlertAction?) -> Void)!>()

        if self.user.id != me.id {
            optionalList["举报此用户"] = { (_) -> Void in
                
                Util.alert(parentvc: self, title: "举报用户", message: "您确定要举报此用户吗？") { _ in
                    Router.Report.User(id: self.user.id).request
                }
            }
        }
        
        if self.user.id != me.id {
            
            if let blockUsers = me.blockUsers, blockUsers.contains(self.user.id) {
                
                optionalList["取消屏蔽"] = { (_) -> Void in
                    Router.User.Block(id: self.user.id).response {
                        if $0.result.isFailure { return }
                        me.blockUsers?.remove(self.user.id)
                    }
                }
                
            } else {
                
                optionalList["屏蔽此用户"] = { (_) -> Void in
                    
                    Util.alert(parentvc: self, title: "屏蔽用户", message: "您确定要屏蔽此用户吗？") { _ in
                        Router.User.Block(id: self.user.id).response {
                            if $0.result.isFailure { return }
                            me.blockUsers?.append(self.user.id)
                        }
                    }
                }
            }
            
        }
        
        if let friends = me.friends, friends.contains(self.user.id) {
            optionalList["删除好友"] = { (_) -> Void in
                
                Util.alert(parentvc: self, title: "删除好友", message: "确定删除该好友么?") { _ in
                    Router.Contact.Delete(id: self.user.id).response {
                        if $0.result.isFailure { return }
                        me.deleteFriend(user: self.user)
                        self.configUserStatus()
                    }
                }
            }
        }
        
        Util.alertActionSheet(parentvc: self, optionalDict: optionalList)
        
    }
    
    @IBAction func addFriend(_ sender: UIButton) {
        
        sender.isUserInteractionEnabled = false
        
        Router.Invitation.SendTo(id: self.user.id).response {

            if $0.result.isFailure {
                sender.isUserInteractionEnabled = true
                return
            }
            
            if me.invitations == nil {
                me.invitations = []
            }

            me.invitations?.append(self.user.id)

            sender.isUserInteractionEnabled = true

            self.configUserStatus()
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {

        // TODO: infinite loop here

        let messageViewController = self.navigationController?.childViewControllers.first(where: { ($0 as? MessageViewController)?.friend.id == self.user.id }) as? MessageViewController
        
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

        if let myFriends = me.friends, myFriends.contains(self.user.id) {
            self.relation = .Friend
        }

        if let myInvitations = me.invitations, myInvitations.contains(self.user.id) {
            self.relation = .InvitedByMe
        }

        if let _ = me.friendInvitations.first(where: { $0.from.id == self.user.id }) {
            self.relation = .InvitedingMe
        }

        self.statusLabel.text = self.relation.message(user: self.user)

        switch self.relation {

        case .Stranger:
            self.addFriendButton.isHidden = false
            self.messageButton.isHidden = true
            self.acceptButton.isHidden = true
            self.refuseButton.isHidden = true

        case .Friend:
            self.addFriendButton.isHidden = true
            self.messageButton.isHidden = false
            self.acceptButton.isHidden = true
            self.refuseButton.isHidden = true

        case .InvitedByMe:
            self.addFriendButton.isHidden = true
            self.messageButton.isHidden = true
            self.acceptButton.isHidden = true
            self.refuseButton.isHidden = true

        case .InvitedingMe:
            self.addFriendButton.isHidden = true
            self.messageButton.isHidden = true
            self.acceptButton.isHidden = false
            self.refuseButton.isHidden = false

        case .Blocking:
            self.addFriendButton.isHidden = true
            self.messageButton.isHidden = true
            self.acceptButton.isHidden = true
            self.refuseButton.isHidden = true
        }
    }

    fileprivate func configDisplay() {

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: self.headerViewSize)

        // set title with user nickname
        self.navigationItem.title = self.user.nickName

        // give the buttons white border
        self.avatarImageView.layer.borderWidth = 2
        self.avatarImageView.layer.borderColor = UIColor.white.cgColor

        self.addFriendButton.layer.borderWidth = 2
        self.addFriendButton.layer.borderColor = UIColor.white.cgColor

        self.messageButton.layer.borderWidth = 2
        self.messageButton.layer.borderColor = UIColor.white.cgColor

        self.acceptButton.layer.borderWidth = 2
        self.acceptButton.layer.borderColor = UIColor.white.cgColor

        self.refuseButton.layer.borderWidth = 2
        self.refuseButton.layer.borderColor = UIColor.white.cgColor

        self.configUserInfo()
    }

    fileprivate func configUserInfo() {

        if let cover = self.user.cover {
            self.coverImageView.sd_setImage(with: URL(string: cover), placeholderImage: TomoConst.Image.DefaultCover)
        }

        if let photo = self.user.photo {
            self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
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
            self.birthDayLabel.text = birthDay.toString(dateStyle: .medium, timeStyle: .none)
        }

        if let address = self.user.address {
            self.addressLabel.text = address
        }
    }

    fileprivate func invitationAccept(accept: Bool){

        let invitation = me.friendInvitations.first(where: { $0.from.id == self.user.id })

        if let invitation = invitation {

            Router.Invitation.ModifyById(id: invitation.id, accepted: accept).response {

                if $0.result.isFailure { return }

                if accept {
                    me.acceptInvitation(invitation: invitation)
                } else {
                    me.refuseInvitation(invitation: invitation)
                }
            }
        }
    }

}

// MARK: - Event Observer

extension ProfileViewController {

    fileprivate func configEventObserver() {

        NotificationCenter.default.addObserver(self, selector: "configUserStatus", name: NSNotification.Name(rawValue: "didAcceptInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: "configUserStatus", name: NSNotification.Name(rawValue: "didRefuseInvitation"), object: me)

        // notification from background thread
        NotificationCenter.default.addObserver(self, selector: "reviseUserStatus", name: NSNotification.Name(rawValue: "didReceiveFriendInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: "reviseUserStatus", name: NSNotification.Name(rawValue: "didMyFriendInvitationAccepted"), object: me)
        NotificationCenter.default.addObserver(self, selector: "reviseUserStatus", name: NSNotification.Name(rawValue: "didMyFriendInvitationRefused"), object: me)
        NotificationCenter.default.addObserver(self, selector: "reviseUserStatus", name: NSNotification.Name(rawValue: "didFriendBreak"), object: me)
    }

    func reviseUserStatus() {
        gcd.sync(.main) {
            self.configUserStatus()
        }
    }
}

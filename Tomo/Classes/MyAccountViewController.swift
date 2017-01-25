//
//  MyAccountViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class MyAccountViewController: UITableViewController {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var bioLabel: UILabel!

    @IBOutlet weak var fullNameLabel: UILabel!

    @IBOutlet weak var genderLabel: UILabel!

    @IBOutlet weak var birthDayLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var primaryStation: UILabel!
    
    @IBOutlet weak var notificationCell: UITableViewCell!

    var notificationCellAccessoryView: UIView?

    let badgeView: UILabel! = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.backgroundColor = UIColor.red
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        
        return label
    }()

    let headerHeight = TomoConst.UI.ScreenHeight * 0.382 - 58
    let headerViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.ScreenHeight * 0.382 + 58)

    override func viewDidLoad() {

        super.viewDidLoad()

        self.notificationCellAccessoryView = notificationCell.accessoryView

        self.configDisplay()

        self.configEventObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let rvc = segue.destination as? RecommendViewController {
            rvc.exitAction = {
                self.configDisplay()
                rvc.dismiss(animated: true, completion: nil)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: UITableView Delegate

extension MyAccountViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: UIScrollView Delegate

extension MyAccountViewController {

    // Fetch more contents when scroll down to bottom
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.configNavigationBarByScrollPosition()
    }
}

// MARK: - Actions

extension MyAccountViewController {

    @IBAction func logoutTapped(_ sender: UIButton) {

        Util.alert(parentvc: self, title: "退出账号", message: "真的要退出当前的账号吗？") { _ in

            Router.Signout().response { _ in
                
                UserDefaults.standard.removeObject(forKey: "deviceToken")

                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "password")

                me = Account()
                let main = Util.createViewControllerWithIdentifier(id: nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
            }
        }
    }

    @IBAction func profileDidFinishEdit(_ segue: UIStoryboardSegue) {
//        self.configDisplay()
    }
}

// MARK: - Internal Method

extension MyAccountViewController {
    
    fileprivate func configDisplay() {

        self.avatarImageView.layer.borderColor = UIColor.white.cgColor
        self.avatarImageView.layer.borderWidth = 2

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: self.headerViewSize)

        self.navigationItem.title = me.nickName

        if let cover = me.cover {
            self.coverImageView.sd_setImage(with: URL(string: cover), placeholderImage: TomoConst.Image.DefaultCover)
        }

        if let avatar = me.photo {
            self.avatarImageView.sd_setImage(with: URL(string: avatar), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        if let bio = me.bio {
            self.bioLabel.text = bio
        }

        if me.firstName != nil && me.lastName != nil {
            self.fullNameLabel.text = me.fullName()
        }
        
        if let gender = me.gender {
            self.genderLabel.text = gender
        }
        
        if let birthDay = me.birthDay {
            self.birthDayLabel.text = birthDay.toString(dateStyle: .medium, timeStyle: .none)
        }
        
        if let address = me.address {
            self.addressLabel.text = address
        }
        
        if let stationName = me.primaryStation?.name {
            self.primaryStation.text = stationName
        }

        if me.notifications > 0 {
            self.badgeView.text = String(me.notifications)
            self.notificationCell.accessoryView = self.badgeView
        } else {
            self.notificationCell.accessoryView = self.notificationCellAccessoryView
        }
    }

    fileprivate func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > self.headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = self.headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(rgbValue: 0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
}

// MARK: Event Observer

extension MyAccountViewController {
    
    fileprivate func configEventObserver() {

        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateBadgeInMainTheard(_:)), name: NSNotification.Name(rawValue: "didMyFriendInvitationAccepted"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateBadgeInMainTheard(_:)), name: NSNotification.Name(rawValue: "didMyFriendInvitationRefused"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateBadgeInMainTheard(_:)), name: NSNotification.Name(rawValue: "didFriendBreak"), object: me)

        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateBadgeInMainTheard(_:)), name: NSNotification.Name(rawValue: "didReceivePost"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateBadgeInMainTheard(_:)), name: NSNotification.Name(rawValue: "didPostLiked"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateBadgeInMainTheard(_:)), name: NSNotification.Name(rawValue: "didPostCommented"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateBadgeInMainTheard(_:)), name: NSNotification.Name(rawValue: "didPostBookmarked"), object: me)

        // these events is not come from background thread
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateBadge(_:)), name: NSNotification.Name(rawValue: "didCheckAllNotification"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.updateProfile(_:)), name: NSNotification.Name(rawValue: "didEditProfile"), object: nil)
    }
    
    func updateBadgeInMainTheard(_ notification: NSNotification) {
        
        gcd.sync(.main) {
            if me.notifications > 0 {
                self.badgeView.text = String(me.notifications)
                self.notificationCell.accessoryView = self.badgeView
            } else {
                self.notificationCell.accessoryView = self.notificationCellAccessoryView
            }
        }
    }

    func updateBadge(_ notification: NSNotification) {

        if me.notifications > 0 {
            self.badgeView.text = String(me.notifications)
            self.notificationCell.accessoryView = self.badgeView
        } else {
            self.notificationCell.accessoryView = self.notificationCellAccessoryView
        }
    }

    func updateProfile(_ notification: NSNotification) {
        self.configDisplay()
    }
}


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
        let label = UILabel(frame: CGRectMake(0, 0, 20, 20))
        label.backgroundColor = UIColor.redColor()
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(12)
        label.textAlignment = .Center
        
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

    override func viewWillDisappear(animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(animated: Bool) {

        if me.notifications > 0 {
            badgeView.text = String(me.notifications)
            notificationCell.accessoryView = badgeView
        } else {
            notificationCell.accessoryView = self.notificationCellAccessoryView
        }

        self.configNavigationBarByScrollPosition()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let rvc = segue.destinationViewController as? RecommendViewController {
            rvc.exitAction = {
                self.configDisplay()
                rvc.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

// MARK: UITableView Delegate

extension MyAccountViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: UIScrollView Delegate

extension MyAccountViewController {

    // Fetch more contents when scroll down to bottom
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.configNavigationBarByScrollPosition()
    }
}

// MARK: - Actions

extension MyAccountViewController {

    @IBAction func logoutTapped(sender: UIButton) {

        Util.alert(self, title: "退出账号", message: "真的要退出当前的账号吗？") { _ in

            Router.Signout().response { _ in
                Defaults.remove("openid")
                Defaults.remove("deviceToken")

                Defaults.remove("email")
                Defaults.remove("password")

                me = Account()
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
            }
        }
    }

    @IBAction func profileDidFinishEdit(segue: UIStoryboardSegue) {
        self.configDisplay()
    }
}

// MARK: - Internal Method

extension MyAccountViewController {
    
    private func configDisplay() {

        self.avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.avatarImageView.layer.borderWidth = 2

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: self.headerViewSize)

        self.navigationItem.title = me.nickName

        if let cover = me.cover {
            self.coverImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: TomoConst.Image.DefaultCover)
        }

        if let avatar = me.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: avatar), placeholderImage: TomoConst.Image.DefaultAvatar)
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
            self.birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }
        
        if let address = me.address {
            self.addressLabel.text = address
        }
        
        if let stationName = me.primaryStation?.name {
            self.primaryStation.text = stationName
        }
    }

    private func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > self.headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = self.headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        }
    }
}

// MARK: Event Observer

extension MyAccountViewController {
    
    private func configEventObserver() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNotification:", name: ListenerEvent.FriendAccepted.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNotification:", name: ListenerEvent.FriendRefused.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNotification:", name: ListenerEvent.FriendBreak.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNotification:", name: ListenerEvent.PostNew.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNotification:", name: ListenerEvent.PostLiked.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNotification:", name: ListenerEvent.PostCommented.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNotification:", name: ListenerEvent.PostBookmarked.rawValue, object: nil)
    }
    
    func didReceiveNotification(notification: NSNotification) {
        
        gcd.sync(.Main) {
            self.badgeView.text = String(me.notifications + 1)
            self.notificationCell.accessoryView = self.badgeView
        }
    }
}


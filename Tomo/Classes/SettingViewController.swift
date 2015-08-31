//
//  SettingViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class SettingViewController: MyAccountBaseController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    @IBOutlet weak var notificationCollectionView: UICollectionView!
    
    var timer: NSTimer?
    var user: UserEntity!
    var notifications: [NotificationEntity]? {
        didSet {
            var badge: String? = nil
            if let notifications = notifications where notifications.count > 0 {
                badge = String(notifications.count)
                if let timer = timer {
                    timer.invalidate()
                }
                timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "nextNotification:", userInfo: nil, repeats: true)
            } else {
                if let timer = timer {
                    timer.invalidate()
                    self.timer = nil
                }
            }
            self.notificationCollectionView.reloadData()
            self.parentViewController!.tabBarItem.badgeValue = badge
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height / 2
        Util.changeImageColorForButton(editButton,color: UIColor.whiteColor())
        
        self.updateUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Manager.sharedInstance.request(.GET, kAPIBaseURLString + "/mobile/notifications").responseJSON { (_, _, result, error) -> Void in
            
            if let data: AnyObject = result where error == nil {
                if let array = JSON(data).array where array.count > 0 {
                    self.notifications = array.map { return NotificationEntity($0.object) }
                    return
                }
            }
            self.notifications = nil
        }
    }
    
    func updateUI() {
        user = me
        
        if let firstName = user.firstName, lastName = user.lastName {
            fullNameLabel.text = user.fullName()
        }
        
        if let gender = user.gender {
            genderLabel.text = gender
        }
        
        if let birthDay = user.birthDay {
            birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }
        
        if let address = user.address {
            addressLabel.text = address
        }

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell == logoutCell {
            
            Util.alert(self, title: "退出账号", message: "真的要退出当前的账号吗？", action: { (_) -> Void in
                
                var param = Dictionary<String, String>();
                param["token"] = Defaults["deviceToken"].string
                Manager.sharedInstance.request(.GET, kAPIBaseURLString + "/logout", parameters: param)
                
                Defaults.remove("openid")
                Defaults.remove("deviceToken")
                
                Defaults.remove("email")
                Defaults.remove("password")
                
                me = UserEntity()
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
            })
            
        }
    }

    // MARK: - Navigation

    @IBAction func profileDidFinishEdit(segue: UIStoryboardSegue) {
        self.updateUI()
    }

}

// MARK - notificationCollectionView

extension SettingViewController {
    
    func nextNotification(info: AnyObject){
        if let notifications = self.notifications, paths = self.notificationCollectionView.indexPathsForSelectedItems() as? [NSIndexPath] where notifications.count > 0 {
            
            var path:NSIndexPath!
            if paths.count > 0 {
                self.notificationCollectionView.deselectItemAtIndexPath(paths[0], animated: true)
                
                let item = ( paths[0].item == notifications.count - 1 ) ? 0 : paths[0].item + 1
                path = NSIndexPath(forItem: item, inSection: 0)
                
            } else {
                path = NSIndexPath(forItem: 0, inSection: 0)
            }
            self.notificationCollectionView.selectItemAtIndexPath(path, animated: true, scrollPosition: .Top)
//            self.notificationCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
}

extension SettingViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.notifications?.count ?? 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let notification = self.notifications![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        let imageView: AnyObject? = cell.contentView.subviews.find { $0 is UIImageView }
        let label: AnyObject? = cell.contentView.subviews.find { $0 is UILabel }
        
        if let label = label as? UILabel, imageView = imageView as? UIImageView {
            var actionString = "评论"
            if let event = SocketEvent(rawValue: notification.type) {
                if event == .PostCommented {
                    actionString = "评论"
                } else if event == .PostLiked {
                    actionString = "赞"
                }
            }
            if imageView.tag == 0 {
                imageView.tag = 1
                imageView.layer.cornerRadius = imageView.frame.size.width / 2
                imageView.layer.masksToBounds = true
            }
            if let photo = notification.from.photo {
                imageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
            } else {
                imageView.image = DefaultAvatarImage
            }
            label.text = "\(notification.from.nickName)\n    \(actionString)了您的帖子"
        }
        return cell
    }
}
extension SettingViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/mobile/notifications/open")
        self.parentViewController!.tabBarItem.badgeValue = nil
    }
    
}

extension SettingViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
    
        if scrollView == self.notificationCollectionView { return }
        else { super.scrollViewDidScroll(scrollView) }
    }
}
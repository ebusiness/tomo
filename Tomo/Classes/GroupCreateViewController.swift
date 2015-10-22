//
//  GroupCreateViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/11.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class GroupCreateViewController: BaseTableViewController {

    @IBOutlet var groupNameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var introductionTextField: UITextField!
    
    @IBOutlet weak var groupCoverImageView: UIImageView!
    private var cover: UIImage?
    @IBOutlet weak var inviteMark: UILabel!
    
    /// 用于显示头像的collectionView
    @IBOutlet weak var memberCollectionView: UICollectionView!
    /// 头像collectionView的高度
    @IBOutlet weak var memberCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private var inviteFriends = [UserEntity]()
    
    private var friends: [UserEntity]? {
        didSet {
            if nil != friends {
                memberCollectionView.reloadData()
                memberCollectionViewHeightConstraint.constant = memberCollectionView.collectionViewLayout.collectionViewContentSize().height
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memberCollectionView.allowsMultipleSelection = true
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //no friends
        if (me.friends ?? []).count < 1 {
            Util.alert(self, title: "添加好友", message: "您还没有好友,是否需要添加好友?", action: { _ in
                let vc = Util.createViewControllerWithIdentifier("SearchFriend", storyboardName: "Contacts")
                self.presentViewController(vc, animated: true, completion: nil)
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadFriends()
    }

}

// MARK: - Actions

extension GroupCreateViewController {
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func create(sender: AnyObject) {
        
        var param = Dictionary<String, AnyObject>()
        
        if self.groupNameTextField.text!.length > 0 {
            param["name"] = self.groupNameTextField.text
        } else {
            return
        }
        
        param["introduction"] = self.introductionTextField.text
        param["address"] = self.addressTextField.text
        param["members"] = self.inviteFriends.map{ (user) -> String in
            return user.id
        }
        
        let coverName = NSUUID().UUIDString
        let coverPath = NSTemporaryDirectory() + coverName
        
        if let cover = self.cover {
            cover.saveToPath(coverPath)
            param["cover"] = coverName
        }
        
        AlamofireController.request(.POST, "/groups", parameters: param, success: { group in
            
            let groupInfo = GroupEntity(group)
            if nil != self.cover {
                
                let remotePath =  Constants.groupCoverPath(groupId: groupInfo.id)
                
                let progressView = self.getProgressView()
                
                S3Controller.uploadFile(coverPath, remotePath: remotePath, done: { (error) -> Void in
                    progressView.removeFromSuperview()
                    self.performSegueWithIdentifier("groupCreated", sender: groupInfo)
                    
                }).progress { _, sendBytes, totalBytes in
                    
                    let progress = Float(sendBytes)/Float(totalBytes)
                    
                    gcd.sync(.Main) { () -> () in
                        progressView.progress = progress                        
                    }
                }
            } else {
                self.performSegueWithIdentifier("groupCreated", sender: groupInfo)
            }
        })
    }
    
    @IBAction func changeCover(sender: UITapGestureRecognizer) {
        
        let block:CameraController.CameraBlock = { (image,_) ->() in
            
            self.cover = image
            self.groupCoverImageView.image = image
        }
        
        Util.alertActionSheet(self, optionalDict: [
            
            "拍摄":{ (_) -> Void in
                CameraController.sharedInstance.open(self, sourceType: .Camera, completion: block)
            },
            "从相册选择":{ (_) -> () in
                CameraController.sharedInstance.open(self, sourceType: .SavedPhotosAlbum, completion: block)
            }
        ])
    }
}

extension GroupCreateViewController {

    func getProgressView() -> UIProgressView {
        
        let progressView = UIProgressView(frame: CGRectZero)
        progressView.trackTintColor = Util.UIColorFromRGB(0x009688, alpha: 0.1)
        progressView.tintColor = Util.UIColorFromRGB(0x009688, alpha: 1)
        
        self.tableView.tableHeaderView!.addSubview(progressView)
        
        progressView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tableView.tableHeaderView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[progressView(==20)]", options: nil, metrics: nil, views: ["progressView" : progressView]))
        self.tableView.tableHeaderView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressView]|", options: nil, metrics: nil, views: ["progressView" : progressView]))
        return progressView
    }
    
}

// MARK: - UITableView DataSorce

extension GroupCreateViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return (me.friends ?? []).count > 0 ? 2 : 1
    }
}

extension GroupCreateViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) where cell.contentView.subviews.count > 0 {
            
            let views: AnyObject? = cell.contentView.subviews.filter { $0 is UITextView || $0 is UITextField }
            if let views = views as? [UIView], lastView = views.last {
                lastView.becomeFirstResponder()
            }
        }
    }
    
}

// MARK: - Net methods
extension GroupCreateViewController {
    private func loadFriends() {
        AlamofireController.request(.GET, "/friends", success: { object in
            
            self.friends = UserEntity.collection(object)
            
        })
    }
}

// MARK: - CollectionView datasource & delegate methods
extension GroupCreateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.friends?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GroupDescriptionMemberAvatarCell.identifier, forIndexPath: indexPath) as! GroupDescriptionMemberAvatarCell
        if let member = self.friends?[indexPath.item] {
            cell.avatarImageView.sd_setImageWithURL(NSURL(string: member.photo ?? ""), placeholderImage: UIImage(named: "avatar"))
        }
        return cell;
    }
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        if let member = self.friends?[indexPath.row] {
//            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
//            vc.user = member
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            
            self.inviteFriends.append(self.friends![indexPath.item])
            
            self.refreshInviteMark()
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                cell.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: { (_) -> Void in
                let avatar: AnyObject? = cell.contentView.subviews.find { $0 is UIImageView }
                if let avatar = avatar as? UIImageView {
                    avatar.layer.borderColor = Util.UIColorFromRGB(0x4CAF50, alpha: 1).CGColor
                    avatar.layer.borderWidth = 2
                }
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            
            self.inviteFriends.remove(self.friends![indexPath.item])
            self.refreshInviteMark()
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                cell.transform = CGAffineTransformIdentity
            }, completion: { (_) -> Void in
                let avatar: AnyObject? = cell.contentView.subviews.find { $0 is UIImageView }
                if let avatar = avatar as? UIImageView {
                    avatar.layer.borderWidth = 0
                }
            })
        }
    }
    
    
}

extension GroupCreateViewController {
    func refreshInviteMark() {
        let inviteCount = self.inviteFriends.count
        
        if inviteCount > 0 {
            inviteMark.text = String(inviteCount)
            if inviteMark.hidden {
                inviteMark.superview?.bringSubviewToFront(inviteMark)
                inviteMark.transform = CGAffineTransformMakeScale(0, 0)
                inviteMark.hidden = false
                
                UIView.animateWithDuration(0.3, animations: { _ in
                    self.inviteMark.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: nil)
            }
            
        } else {
            if !inviteMark.hidden {
                UIView.animateWithDuration(0.1, animations: { _ in
                    self.inviteMark.transform = CGAffineTransformMakeScale(0, 0)
                }, completion: { (_) -> Void in
                    self.inviteMark.hidden = true
                })
            }
        }
        
    }
}

//
//  GroupDescriptionViewController.swift
//  Tomo
//
//  Created by eagle on 15/9/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import Alamofire

class GroupDescriptionViewController: UICollectionViewController {

    var group: GroupEntity!

    var members = [UserEntity]()

    var footerView: GroupDescriptionFooterCell!

    let headerHeight = TomoConst.UI.ScreenHeight * 0.382 - 44
    let headerViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.ScreenHeight * 0.382 + 44)

    override func viewDidLoad() {

        super.viewDidLoad()

        self.configDisplay()

        self.loadGroupDescription()
        
        self.registerClosureForAccount()
    }

    override func viewWillDisappear(animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.configNavigationBarByScrollPosition()
    }

}

// MARK: - Internal methods

extension GroupDescriptionViewController {

    private func configDisplay() {

        self.navigationItem.title = group.name
    }

    private func loadGroupDescription() {
        
        Router.Group.FindById(id: group.id).response {

            if $0.result.isFailure { return }

            if let members = GroupEntity($0.result.value!).members {

                self.members += members

                var insertIndex: [NSIndexPath] = []

                for _ in self.members {
                    insertIndex.append(NSIndexPath(forItem: insertIndex.count, inSection: 0))
                }

                self.collectionView!.performBatchUpdates({ _ in
                    self.collectionView!.insertItemsAtIndexPaths(insertIndex)
                }, completion: nil)

                self.footerView.loadingIndicator.stopAnimating()
            }
        }
    }

    private func configNavigationBarByScrollPosition() {

        let offsetY = self.collectionView!.contentOffset.y

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
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
}

// MARK: - UICollectionView Datasource

extension GroupDescriptionViewController {

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.members.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemberCell", forIndexPath: indexPath) as! GroupDescriptionMemberAvatarCell

        cell.avatarImageView.layer.cornerRadius = (TomoConst.UI.ScreenWidth - 50) / 4 / 2
        cell.avatarImageView.layer.masksToBounds = true

        cell.avatarImageView.sd_setImageWithURL(NSURL(string: self.members[indexPath.row].photo ?? ""), placeholderImage: UIImage(named: "avatar"))
        cell.nickNameLabel.text = self.members[indexPath.row].nickName


        return cell;
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! GroupDescriptionHeaderCell
            headerView.group = self.group
            return headerView
        } else {
            self.footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath) as! GroupDescriptionFooterCell
            return self.footerView
        }
    }
    
}

// MARK: - UICollectionView Delegate

extension GroupDescriptionViewController {

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = self.members[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension GroupDescriptionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (TomoConst.UI.ScreenWidth - 50) / 4, height: (TomoConst.UI.ScreenWidth - 50) / 4 + 30)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.headerViewSize
    }
}

extension GroupDescriptionViewController {
    
    private func registerClosureForAccount() {
        
        me.addGroupsObserver { (added, removed) -> () in
            let indexOfMeInGroup = self.members.indexOf({$0.id == me.id })
            if added.count > 0 {
                self.refreshForJoinGroupIfNeeded(indexOfMeInGroup)
            }
            if removed.count > 0 {
                self.refreshForLeaveGroupIfNeeded(indexOfMeInGroup)
            }
        }
    }
    
    private func refreshForJoinGroupIfNeeded(indexOfMeInGroup: Int?) {
        guard nil == indexOfMeInGroup else { return }
        
        self.members.insert(me, atIndex: 0)
        
        gcd.sync(.Main){
            self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
        }
    }
    
    private func refreshForLeaveGroupIfNeeded(indexOfMeInGroup: Int?) {
        guard let index = indexOfMeInGroup else { return }
        
        self.members.removeAtIndex(index)
        
        gcd.sync(.Main){
            self.collectionView!.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
        }
    }
}


// MARK: - UICollectionView Header Cell

final class GroupDescriptionHeaderCell: UICollectionReusableView {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var actionButton: UIButton!

    var group: GroupEntity! {
        didSet {
            self.coverImageView.sd_setImageWithURL(NSURL(string: self.group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
            self.didSetGroup()
        }
    }

    override func awakeFromNib() {
        self.actionButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.actionButton.layer.borderWidth = 2
    }

    @IBAction func actionButtonTapped(sender: UIButton) {

        sender.userInteractionEnabled = false

        if let myGroups = me.groups where myGroups.contains(self.group.id) {
            self.leaveGroup()
        } else {
            self.joinGroup()
        }
    }
    
    private func didSetGroup(){
        
        if let myGroups = me.groups where myGroups.contains(self.group.id) {
            
            self.actionButton.setTitle(" 退出群组 ", forState: .Normal)
            self.actionButton.backgroundColor = Palette.Red.primaryColor
            self.actionButton.sizeToFit()
            
        } else  {
            
            self.actionButton.setTitle(" 加入群组 ", forState: .Normal)
            self.actionButton.backgroundColor = Palette.Green.primaryColor
            self.actionButton.sizeToFit()
        }
    }

    private func joinGroup() {

        Router.Group.Join(id: self.group.id).response {

            if $0.result.isFailure {
                self.actionButton.userInteractionEnabled = true
                return
            }

            me.addGroup(self.group)
            UIView.animateWithDuration(TomoConst.Duration.Short) {
                self.didSetGroup()
            }
            
            self.actionButton.userInteractionEnabled = true
        }
    }

    private func leaveGroup() {

        let alert = UIAlertController(title: "退出群组", message: "确定退出\(self.group.name)么?", preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "取消", style: .Destructive, handler: { _ in
            self.actionButton.userInteractionEnabled = true
        }))

        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { _ in
            Router.Group.Leave(id: self.group.id).response {

                if $0.result.isFailure {
                    self.actionButton.userInteractionEnabled = true
                    return
                }

                me.removeGroup(self.group)
                UIView.animateWithDuration(TomoConst.Duration.Short) {
                    self.didSetGroup()
                }
                
                self.actionButton.userInteractionEnabled = true
            }
        }))

        window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Content Cell

final class GroupDescriptionMemberAvatarCell: UICollectionViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
}

// MARK: - UICollectionView Footer Cell

final class GroupDescriptionFooterCell: UICollectionReusableView {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
}

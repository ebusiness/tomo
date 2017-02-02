//
//  GroupDescriptionViewController.swift
//  Tomo
//
//  Created by eagle on 15/9/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import Alamofire

final class GroupDescriptionViewController: UICollectionViewController {

    var group: GroupEntity!

    var members = [UserEntity]()

    var footerView: GroupDescriptionFooterCell!

    let headerHeight = TomoConst.UI.ScreenHeight * 0.382 - 44
    let headerViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.ScreenHeight * 0.382 + 44)

    override func viewDidLoad() {

        super.viewDidLoad()

        self.configDisplay()

        self.loadGroupDescription()
        
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

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.configNavigationBarByScrollPosition()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Internal methods

extension GroupDescriptionViewController {

    fileprivate func configDisplay() {

        self.navigationItem.title = group.name
    }

    fileprivate func loadGroupDescription() {
        
        Router.Group.FindById(id: group.id).response {

            if $0.result.isFailure { return }

            if let members = GroupEntity($0.result.value!).members {

                self.members += members

                var insertIndex: [IndexPath] = []

                for _ in self.members {
                    insertIndex.append(IndexPath(item: insertIndex.count, section: 0))
                }

                self.collectionView!.performBatchUpdates({ _ in
                    self.collectionView!.insertItems(at: insertIndex)
                }, completion: nil)

                self.footerView.loadingIndicator.stopAnimating()
            }
        }
    }

    fileprivate func configNavigationBarByScrollPosition() {

        let offsetY = self.collectionView!.contentOffset.y

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

// MARK: - UICollectionView Datasource

extension GroupDescriptionViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.members.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell", for: indexPath) as? GroupDescriptionMemberAvatarCell

        cell?.avatarImageView.layer.cornerRadius = (TomoConst.UI.ScreenWidth - 50) / 4 / 2
        cell?.avatarImageView.layer.masksToBounds = true

        cell?.avatarImageView.sd_setImage(with: URL(string: self.members[indexPath.row].photo ?? ""), placeholderImage: UIImage(named: "avatar"))
        cell?.nickNameLabel.text = self.members[indexPath.row].nickName


        return cell!;
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? GroupDescriptionHeaderCell
            headerView?.group = self.group
            return headerView!
        } else {
            self.footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as? GroupDescriptionFooterCell
            return self.footerView!
        }
    }
    
}

// MARK: - UICollectionView Delegate

extension GroupDescriptionViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
        vc?.user = self.members[indexPath.row]
        navigationController?.pushViewController(vc!, animated: true)
    }
}

extension GroupDescriptionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (TomoConst.UI.ScreenWidth - 50) / 4, height: (TomoConst.UI.ScreenWidth - 50) / 4 + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.headerViewSize
    }
}

// MARK: - Event Observer

extension GroupDescriptionViewController {
    
    fileprivate func configEventObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(GroupDescriptionViewController.didJoinGroup(_:)), name: NSNotification.Name(rawValue: "didJoinGroup"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(GroupDescriptionViewController.didLeaveGroup(_:)), name: NSNotification.Name(rawValue: "didLeaveGroup"), object: me)
    }

    func didJoinGroup(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let group = userInfo["groupEntityOfNewGroup"] as? GroupEntity else { return }
        guard group.id == self.group.id else { return }

        self.members.insert(me, at: 0)

        self.collectionView!.insertItems(at: [IndexPath(item: 0, section: 0)])
    }

    func didLeaveGroup(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let groupId = userInfo["idOfDeletedGroup"] as? String else { return }
        guard groupId == self.group.id else { return }

        if let index = self.members.index(where: { $0.id == me.id }) {
            self.members.remove(at: index)
            self.collectionView!.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}


// MARK: - UICollectionView Header Cell

final class GroupDescriptionHeaderCell: UICollectionReusableView {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var actionButton: UIButton!

    var group: GroupEntity! {
        didSet {
            self.coverImageView.sd_setImage(with: URL(string: self.group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
            self.didSetGroup()
        }
    }

    override func awakeFromNib() {
        self.actionButton.layer.borderColor = UIColor.white.cgColor
        self.actionButton.layer.borderWidth = 2
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {

        sender.isUserInteractionEnabled = false

        if let myGroups = me.groups, myGroups.contains(self.group.id) {
            self.leaveGroup()
        } else {
            self.joinGroup()
        }
    }
    
    private func didSetGroup(){
        
        if let myGroups = me.groups, myGroups.contains(self.group.id) {
            
            self.actionButton.setTitle(" 退出群组 ", for: .normal)
            self.actionButton.backgroundColor = Palette.Red.primaryColor
            self.actionButton.sizeToFit()
            
        } else  {
            
            self.actionButton.setTitle(" 加入群组 ", for: .normal)
            self.actionButton.backgroundColor = Palette.Green.primaryColor
            self.actionButton.sizeToFit()
        }
    }

    private func joinGroup() {

        Router.Group.Join(id: self.group.id).response {

            if $0.result.isFailure {
                self.actionButton.isUserInteractionEnabled = true
                return
            }

            me.joinGroup(group: self.group)
            UIView.animate(withDuration: TomoConst.Duration.Short) {
                self.didSetGroup()
            }
            
            self.actionButton.isUserInteractionEnabled = true
        }
    }

    private func leaveGroup() {

        let alert = UIAlertController(title: "退出群组", message: "确定退出\(self.group.name)么?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "取消", style: .destructive, handler: { _ in
            self.actionButton.isUserInteractionEnabled = true
        }))

        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            Router.Group.Leave(id: self.group.id).response {

                if $0.result.isFailure {
                    self.actionButton.isUserInteractionEnabled = true
                    return
                }

                me.leaveGroup(group: self.group)
                UIView.animate(withDuration: TomoConst.Duration.Short) {
                    self.didSetGroup()
                }
                
                self.actionButton.isUserInteractionEnabled = true
            }
        }))

        window!.rootViewController!.present(alert, animated: true, completion: nil)
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

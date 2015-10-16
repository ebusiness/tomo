//
//  GroupDescriptionViewController.swift
//  Tomo
//
//  Created by eagle on 15/9/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupDescriptionViewController: BaseTableViewController {
    
    /// 地址
    @IBOutlet weak var addressLabel: UILabel!
    /// 车站
    @IBOutlet weak var stationLabel: UILabel!
    /// 介绍
    @IBOutlet weak var introductionLabel: UILabel!
    /// 用于显示头像的Cell
    @IBOutlet weak var memberCollectionCell: UITableViewCell!
    /// 用于显示头像的collectionView
    @IBOutlet weak var memberCollectionView: UICollectionView!
    /// 头像collectionView的高度
    @IBOutlet weak var memberCollectionViewHeightConstraint: NSLayoutConstraint!
    /// 封面
    @IBOutlet weak var groupCoverImageView: UIImageView!
    /// join group
    @IBOutlet weak var joinCell: UITableViewCell!
    /// leave group
    @IBOutlet weak var leaveCell: UITableViewCell!
    
    let joinOrLeaveSection = 2
    let memberCollectionSection = 1
    /// 从上个界面继承来的数据
    var group: GroupEntity!
    /// 新加载的数据
    private var detailedGroup: GroupEntity? {
        didSet {
            if let detailedGroup = detailedGroup {
                // 刷新界面
                addressLabel.text = detailedGroup.address
                if let station = detailedGroup.station {
                    stationLabel.text = station.name
                }
                introductionLabel.text = detailedGroup.introduction
                groupCoverImageView.sd_setImageWithURL(NSURL(string: detailedGroup.cover), placeholderImage: UIImage(named: "group_cover_default"))
                if (detailedGroup.members ?? []).count > 0 {
                    memberCollectionView.frame.size.width = tableView.frame.size.width
                    memberCollectionView.reloadData()
                    memberCollectionViewHeightConstraint.constant = memberCollectionView.collectionViewLayout.collectionViewContentSize().height
                    tableView.reloadData()
                    memberCollectionView.layoutIfNeeded()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.title = group.name
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        loadGroupDescription()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var tableContentInset = tableView.contentInset
        tableContentInset.bottom = 49.0
        tableView.contentInset = tableContentInset
        var tableIndicatorInset = tableView.scrollIndicatorInsets
        tableIndicatorInset.bottom = 49.0
        tableView.scrollIndicatorInsets = tableIndicatorInset
    }
}
// MARK: - join or leave group
extension GroupDescriptionViewController {
    
    @IBAction func joinGroup(sender: UIButton) {
        sender.userInteractionEnabled = false
        
        let station = self.detailedGroup?.station
        
        let successHandler: (AnyObject)->() = { _ in
            if let station = station {
                me.addStation(station.id)
            }
            me.addGroup(self.group.id)
            self.detailedGroup?.addMember(me)
            
            self.tableView.beginUpdates()
            self.tableView.reloadSections(NSIndexSet(index: self.memberCollectionSection), withRowAnimation: .Automatic)
            self.tableView.reloadSections(NSIndexSet(index: self.joinOrLeaveSection), withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            
            let item = (self.detailedGroup?.members?.count ?? 1) - 1
            self.memberCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: item, inSection: 0)])
            sender.userInteractionEnabled = true
        }
        
        let failureHandler: (Int)->() = { _ in
            sender.userInteractionEnabled = true
        }
        
        if let station = station {
            AlamofireController.request(.POST, "/stations/\(station.id)", success: successHandler, failure: failureHandler)
        } else {
            AlamofireController.request(.PATCH, "/groups/\(self.group.id)/join", success: successHandler, failure: failureHandler)
        }
    }
    
    @IBAction func leaveGroup(sender: UIButton) {
        sender.userInteractionEnabled = false
        
        let station = self.detailedGroup?.station
        
        let successHandler: (AnyObject)->() = { _ in
            if let station = station {
                me.stations?.remove(station.id)
            }
            me.groups?.remove(self.group.id)
            let item = self.detailedGroup?.members?.indexOf { $0.id == me.id } ?? 0
            self.detailedGroup?.removeMember(me)
            
            self.tableView.beginUpdates()
            self.tableView.reloadSections(NSIndexSet(index: self.memberCollectionSection), withRowAnimation: .Automatic)
            self.tableView.reloadSections(NSIndexSet(index: self.joinOrLeaveSection), withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            self.memberCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: item, inSection: 0)])
            
            sender.userInteractionEnabled = true
        }
        
        let failureHandler: (Int)->() = { _ in
            sender.userInteractionEnabled = true
        }
        
        if let station = station {
            var params = Dictionary<String, AnyObject>()
            params["stations"] = [station.id]
            
            AlamofireController.request(.DELETE, "/me/stations", parameters: params, success: successHandler, failure: failureHandler)
        } else {
            AlamofireController.request(.PATCH, "/groups/\(self.group.id)/leave", success: successHandler, failure: failureHandler)
        }
    }
}

// MARK: - Navigation
extension GroupDescriptionViewController {
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}


// MARK: - Net methods
extension GroupDescriptionViewController {
    private func loadGroupDescription() {
        AlamofireController.request(Method.GET, "/groups/\(group.id)", parameters: nil, encoding: ParameterEncoding.JSON, success: { (object) -> () in
            
            self.detailedGroup = GroupEntity(object)
            
        })
    }
}

// MARK: - TableView DataSource & Delegate
extension GroupDescriptionViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == joinOrLeaveSection {
            return 1
        }
        
        if section == memberCollectionSection && (detailedGroup?.members ?? []).count < 1 {
            return 0
        }
        
        return super.tableView(self.tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == memberCollectionSection && (detailedGroup?.members ?? []).count < 1 {
            return nil
        }
        
        return super.tableView(self.tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == joinOrLeaveSection {
            
            let cell = (me.groups ?? []).contains(self.group.id) ? leaveCell : joinCell
            
            return cell
        }
        
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
}

// MARK: - CollectionView datasource & delegate methods
extension GroupDescriptionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailedGroup?.members?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GroupDescriptionMemberAvatarCell.identifier, forIndexPath: indexPath) as! GroupDescriptionMemberAvatarCell
        if let member = detailedGroup?.members?[indexPath.row] {
            cell.avatarImageView.sd_setImageWithURL(NSURL(string: member.photo ?? ""), placeholderImage: UIImage(named: "avatar"))
        }
        return cell;
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let member = detailedGroup?.members?[indexPath.row] {
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = member
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

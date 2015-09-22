//
//  GroupDescriptionViewController.swift
//  Tomo
//
//  Created by eagle on 15/9/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupDescriptionViewController: BaseTableViewController {
    
    /// 从上个界面继承来的数据
    var group: GroupEntity!
    /// 新加载的书就
    private var detailedGroup: GroupEntity?
    
    /// 用于显示头像的collectionView
    private var memberCollectionView: UICollectionView?
    
    @IBOutlet weak var groupCoverImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadGroupDescription()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.refreshData()
            
            }) { (_) -> () in
                
        }
    }
    private func refreshData() {
        tableView.reloadData()
        groupCoverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: UIImage(named: "group_cover_default"))
        memberCollectionView?.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate
extension GroupDescriptionViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4;
        case 1:
            return 1;
        default:
            return 0;
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "基本信息"
        case 1:
            return "群组成员"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(GroupDescriptionLabelCell.identifier) as! GroupDescriptionLabelCell
            switch indexPath.row {
            case 0:
                cell.majorLabel.text = "名称"
                cell.minorLabel.text = detailedGroup?.name
            case 1:
                cell.majorLabel.text = "地址"
                cell.minorLabel.text = detailedGroup?.address
            case 2:
                cell.majorLabel.text = "车站"
                cell.minorLabel.text = detailedGroup?.station
            case 3:
                cell.majorLabel.text = "介绍"
                cell.minorLabel.text = detailedGroup?.introduction
            default:
                break
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(GroupDescriptionMemberCell.identifier) as! GroupDescriptionMemberCell
            
            memberCollectionView = cell.memberAvatarCollectionView
            
            return cell
        default:
            return UITableViewCell()
        }
        
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
}

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
    /// 新加载的数据
    private var detailedGroup: GroupEntity? {
        didSet {
            if let detailedGroup = detailedGroup {
                // 刷新界面
                nameLabel.text = detailedGroup.name
                addressLabel.text = detailedGroup.address
                stationLabel.text = detailedGroup.station
                introductionLabel.text = detailedGroup.introduction
                groupCoverImageView.sd_setImageWithURL(NSURL(string: detailedGroup.cover), placeholderImage: UIImage(named: "group_cover_default"))
                memberCollectionView.reloadData()
                memberCollectionViewHeightConstraint.constant = memberCollectionView.collectionViewLayout.collectionViewContentSize().height
                tableView.reloadData()
            }
        }
    }
    
    /// 名称
    @IBOutlet weak var nameLabel: UILabel!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
            
            }) { (_) -> () in
                
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension GroupDescriptionViewController {
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

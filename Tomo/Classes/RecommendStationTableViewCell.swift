//
//  RecommendStationTableViewCell.swift
//  Tomo
//
//  Created by ebuser on 2015/09/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class RecommendStationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: UINavigationController?

    var groups: [GroupEntity]! {
        didSet { collectionView.reloadData() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // don't interrupt the scrollToTop of the main table view
        self.collectionView.scrollsToTop = false
    }
}

// MARK: - UICollectionView datasource

extension RecommendStationTableViewCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StationCell", forIndexPath: indexPath) as! StationCollectionViewCell

        // Give the cell group data, this will trigger configDisplay.
        cell.group = groups[indexPath.item]

        return cell
    }
}

// MARK: - UICollectionView delegate

extension RecommendStationTableViewCell:UICollectionViewDelegate {

    // Move the group detail view, when colleciton view cell was tapped.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        // Create group detail view controller.
        let groupVC = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController

        // Give group detail view controller group data.
        groupVC.group = self.groups[indexPath.item]

        // Push the group detail view on the current navigation controler.
        self.delegate?.pushViewController(groupVC, animated: true)
    }
}

// MARK: - UICollectionView FlowLayout

extension RecommendStationTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        // Size of the group cell, if the cell height changed,
        // the outer collection view and table view cell's height
        // also need to change accordingly
        return CGSizeMake(250/4*3, 250)
    }
}

final class StationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var backgroundImageView: UIImageView!

    private var isJoined = false

    // The group data will be displayed
    var group: GroupEntity! {
        didSet { self.configDisplay() }
    }

    override func awakeFromNib() {

        super.awakeFromNib()

        // Give the action button a white border
        self.actionButton.layer.borderColor = UIColor.whiteColor().CGColor
    }

    private func configDisplay() {

        self.nameLabel.text = self.group.name

        self.backgroundImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)

        // If my group list has this group's id, then I had joined this group
        // so make the join button to leave button.
        if let myGroups = me.groups where myGroups.contains(self.group.id) {

            self.isJoined = true
            self.makeLeaveButton()

        // Otherwise I haven't join this group, make up the join button.
        } else {

            self.isJoined = false
            self.makeJoinButton()
        }
    }

    // Make the action button as join button
    private func makeJoinButton() {
        self.actionButton.backgroundColor = Palette.Green.primaryColor
        self.actionButton.setTitle("  加入  ", forState: .Normal)
        self.actionButton.sizeToFit()
    }

    // Make the action button as leave button
    private func makeLeaveButton() {
        self.actionButton.backgroundColor = Palette.Red.primaryColor
        self.actionButton.setTitle("  退出  ", forState: .Normal)
        self.actionButton.sizeToFit()
    }

    // Toggle the group join status when the action button tapped
    @IBAction func actionButtonTapped(sender: AnyObject) {

        if self.isJoined {

            // If this is a joined group and the button was tapped, 
            // Make the leave group request.
            Router.Group.Leave(id: group.id).response {

                if $0.result.isFailure { return }

                // Acknowledge the group data
                let group = GroupEntity($0.result.value!)

                // remove it from my joined group list
                me.removeGroup(group)

                // mark as not joined
                self.isJoined = false

                // animate to the join button
                UIView.animateWithDuration(0.3, animations: {
                    self.makeJoinButton()
                    self.setNeedsLayout()
                })
            }

        } else  {

            // If this is a group I haven't join, and the button was tapped,
            // Make the join group request.
            Router.Group.Join(id: group.id).response {

                if $0.result.isFailure { return }

                // Acknowledge the group data
                let group = GroupEntity($0.result.value!)

                // add the group to my joined group list
                me.addGroup(group)

                // mark as joined
                self.isJoined = true

                // animate to the leave button
                UIView.animateWithDuration(0.3, animations: {
                    self.makeLeaveButton()
                    self.setNeedsLayout()
                })
            }
        }
        
    }
}
//
//  RecommendStationTableViewCell.swift
//  Tomo
//
//  Created by ebuser on 2015/09/24.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

final class RecommendStationTableViewCell: UITableViewCell {

    @IBOutlet weak fileprivate var collectionView: UICollectionView!

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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationCell", for: indexPath) as? StationCollectionViewCell

        // Give the cell group data, this will trigger configDisplay.
        cell?.group = groups[indexPath.item]

        return cell!
    }
}

// MARK: - UICollectionView delegate

extension RecommendStationTableViewCell: UICollectionViewDelegate {

    // Move the group detail view, when colleciton view cell was tapped.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        collectionView.deselectItem(at: indexPath, animated: true)

        // Create group detail view controller.
        let groupVC = Util.createViewController(storyboardName: "Group", id: "GroupDetailView") as? GroupDetailViewController

        // Give group detail view controller group data.
        groupVC?.group = self.groups[indexPath.item]

        // Push the group detail view on the current navigation controler.
        self.delegate?.pushViewController(groupVC!, animated: true)
    }
}

// MARK: - UICollectionView FlowLayout

extension RecommendStationTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // Size of the group cell, if the cell height changed,
        // the outer collection view and table view cell's height
        // also need to change accordingly
        return CGSize(width: 250/4*3, height: 250)
    }
}

final class StationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak fileprivate var nameLabel: UILabel!

    @IBOutlet weak fileprivate var actionButton: UIButton!

    @IBOutlet weak fileprivate var backgroundImageView: UIImageView!

    private var isJoined = false

    // The group data will be displayed
    var group: GroupEntity! {
        didSet { self.configDisplay() }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configEventObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func awakeFromNib() {

        super.awakeFromNib()

        // Give the action button a white border
        self.actionButton.layer.borderColor = UIColor.white.cgColor
    }

    private func configDisplay() {

//        self.nameLabel.text = self.group.name
//
//        self.backgroundImageView.sd_setImage(with: URL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
//
//        // If my group list has this group's id, then I had joined this group
//        // so make the join button to leave button.
//        if let myGroups = me.groups, myGroups.contains(self.group.id) {
//
//            self.isJoined = true
//            self.makeLeaveButton()
//
//        // Otherwise I haven't join this group, make up the join button.
//        } else {
//
//            self.isJoined = false
//            self.makeJoinButton()
//        }
    }

    // Make the action button as join button
    private func makeJoinButton() {
        self.actionButton.backgroundColor = Palette.green.primaryColor
        self.actionButton.setTitle("  加入  ", for: .normal)
        self.actionButton.sizeToFit()
    }

    // Make the action button as leave button
    private func makeLeaveButton() {
        self.actionButton.backgroundColor = Palette.red.primaryColor
        self.actionButton.setTitle("  退出  ", for: .normal)
        self.actionButton.sizeToFit()
    }

    // Toggle the group join status when the action button tapped
    @IBAction func actionButtonTapped(_ sender: Any) {

//        if self.isJoined {
//
//            // If this is a joined group and the button was tapped,
//            // Make the leave group request.
//            Router.Group.leave(id: group.id).response {
//
//                if $0.result.isFailure { return }
//
//                // Acknowledge the group data
//                let group = GroupEntity($0.result.value!)
//
//                // remove it from my joined group list
//                me.leaveGroup(group: group)
//
//                // mark as not joined
//                self.isJoined = false
//
//                // animate to the join button
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.makeJoinButton()
//                    self.setNeedsLayout()
//                })
//            }
//
//        } else  {
//
//            // If this is a group I haven't join, and the button was tapped,
//            // Make the join group request.
//            Router.Group.join(id: group.id).response {
//
//                if $0.result.isFailure { return }
//
//                // Acknowledge the group data
//                let group = GroupEntity($0.result.value!)
//
//                // add the group to my joined group list
//                me.joinGroup(group: group)
//
//                // mark as joined
//                self.isJoined = true
//
//                // animate to the leave button
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.makeLeaveButton()
//                    self.setNeedsLayout()
//                })
//            }
//        }

    }

    private func configEventObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(StationCollectionViewCell.didJoinGroup(_:)), name: NSNotification.Name(rawValue: "didJoinGroup"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(StationCollectionViewCell.didLeaveGroup(_:)), name: NSNotification.Name(rawValue: "didLeaveGroup"), object: me)
    }

    func didJoinGroup(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let group = userInfo["groupEntityOfNewGroup"] as? GroupEntity else { return }
        guard group.id == self.group.id else { return }

        // reconfig display
        self.configDisplay()
    }

    func didLeaveGroup(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let groupId = userInfo["idOfDeletedGroup"] as? String else { return }
        guard groupId == self.group.id else { return }

        // reconfig display
        self.configDisplay()
    }
}

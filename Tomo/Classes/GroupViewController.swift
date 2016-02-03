//
//  GroupViewController.swift
//  Tomo
//
//  Created by ebuser on 2016/01/28.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

private let reuseIdentifier = "StationCell"

final class GroupViewController: UICollectionViewController {

    var isLoading = false
    var isExhausted = false

    var page = 0

    // Array hold the search result
    var groups = [GroupEntity]()

    // CollectionView's footer view, display the indicator and search result
    var footerView: SearchResultReusableView!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.loadData()

        self.configEventObserver()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "ShowGroupDetail" {
            let groupDetailViewController = segue.destinationViewController as! GroupDetailViewController
            groupDetailViewController.group = sender as! GroupEntity
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: UICollectionViewDaztaSource

extension GroupViewController {

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groups.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StationCell", forIndexPath: indexPath) as! MyGroupCollectionViewCell

        cell.group = self.groups[indexPath.row]
    
        return cell
    }

}

// MARK: UICollectionViewDelegate

extension GroupViewController {

    // Make the CollectionView as two-column layout
    func collectionView(collectionView: UICollectionView, layout : UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (TomoConst.UI.ScreenWidth - 2.0) / 2.0
        let height = width / 3.0 * 4.0
        return CGSizeMake(width, height)
    }

    // When cell was tapped, move to group detail
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowGroupDetail", sender: self.groups[indexPath.row])
    }

    // Give CollectionView footer view, and hold a reference of it
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        self.footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath) as! SearchResultReusableView
        return self.footerView
    }
}

// MARK: - Internal Methods

extension GroupViewController {

    private func loadData() {

        if self.isLoading || self.isExhausted {
            return
        }

        self.isLoading = true

        var parameters = Router.Group.FindParameters(category: .mine)
        parameters.page = self.page
        parameters.type = .station

        Router.Group.Find(parameters: parameters).response {

            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.stopActivityIndicator()
                return
            }

            if let groups: [GroupEntity] = GroupEntity.collection($0.result.value!) {
                self.groups.appendContentsOf(groups)
                self.appendCells(groups.count)
                self.page++

                if groups.count < TomoConst.PageSize.Medium {
                    self.stopActivityIndicator()
                }
            }

            self.isLoading = false
        }
    }

    private func stopActivityIndicator(withString: String? = nil) {
        self.footerView.activityIndicator.stopAnimating()
        self.footerView.searchResultLabel.text = withString
        UIView.animateWithDuration(TomoConst.Duration.Short) {
            self.footerView.searchResultLabel.alpha = 1.0
        }
    }

    private func appendCells(count: Int) {

        let startIndex = self.groups.count - count
        let endIndex = self.groups.count

        var indexPaths = [NSIndexPath]()

        for i in startIndex..<endIndex {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            indexPaths.append(indexPath)
        }
        
        self.collectionView!.insertItemsAtIndexPaths(indexPaths)
    }
}

// MARK: - Event Observer

extension GroupViewController {

    private func configEventObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didJoinGroup:", name: "didJoinGroup", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLeaveGroup:", name: "didLeaveGroup", object: me)
    }

    func didJoinGroup(notification: NSNotification) {
        
        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let group = userInfo["groupEntityOfNewGroup"] as? GroupEntity else { return }

        // add the new group into collection view data model
        self.groups.insert(group, atIndex: 0)

        // update collection view, insert the corresponding row in section 0 row 0
        self.collectionView?.performBatchUpdates({
            self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
        }, completion: nil)
    }

    func didLeaveGroup(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let groupId = userInfo["idOfDeletedGroup"] as? String else { return }
        guard let index = self.groups.indexOf({ $0.id == groupId }) else { return }

        // add the new group into collection view data model
        self.groups.removeAtIndex(index)

        // update collection view, remove the corresponding row from section 0
        self.collectionView?.performBatchUpdates({
            self.collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
        }, completion: nil)
    }
}

final class MyGroupCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var backgroundImageView: UIImageView!

    private var isJoined = false

    // The group data will be displayed
    var group: GroupEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        self.nameLabel.text = self.group.name

        self.backgroundImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)

    }
}
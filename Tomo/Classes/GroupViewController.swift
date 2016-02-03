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

// MARK: UICollectionViewDataSource

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

        if self.isExhausted && self.groups.count == 0 {
            self.footerView.showEmptyResultView()

        } else if self.isExhausted && self.groups.count > 0 {
            self.footerView.showSearchResultView()

        } else {
            self.footerView.showActivityIndicator()
        }

        return self.footerView
    }
}

extension GroupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        // the footerView is about 200 point height initially, for the convinence of design empty data view on stroyboard
        // if need to show the empty result view, make it full screen
        // if need to show the loading indicator, make it shorter -- 64 point height
        if self.isExhausted && self.groups.count == 0 {
            return TomoConst.UI.ViewSizeMiddleFullScreen
        } else {
            return TomoConst.UI.ViewSizeTopBarHeight
        }
    }
}

extension GroupViewController  {

    // Fetch more contents when scroll down to bottom
    override func scrollViewDidScroll(scrollView: UIScrollView) {

        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y

        // trigger on the position of one screen height to bottom
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            loadData()
        }
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

                // if the data is exhausted and we still have zero data
                if self.groups.count == 0 {

                    // TODO: this is shit, cause when the first time table footer get shown, 
                    // the UICollectionViewDelegateFlowLayout won't be asked, so I have to get the
                    // footer view size right here, may be I should use other stratigy
                    self.footerView.frame = TomoConst.UI.ViewFrameMiddleFullScreen

                    // show empty result view
                    self.footerView.showEmptyResultView()
                }

                return
            }

            if let groups: [GroupEntity] = GroupEntity.collection($0.result.value!) {
                self.groups.appendContentsOf(groups)
                self.appendCells(groups.count)
                self.page++

                if groups.count < TomoConst.PageSize.Medium {
                    self.footerView.showSearchResultView()
                }
            }

            self.isLoading = false
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
        }) { _ in
            // reload the section to get right section footer
            // TODO: This may cuase screen fliker
            self.collectionView?.reloadSections(NSIndexSet(index: 0))
        }
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
        }) { _ in
            // reload the section to get right section footer
            // TODO: This may cuase screen fliker
            self.collectionView?.reloadSections(NSIndexSet(index: 0))
        }
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
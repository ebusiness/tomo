//
//  RecommendGroupCell.swift
//  Tomo
//
//  Created by ebuser on 2015/09/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RecommendSiteTableCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    var groups: [GroupEntity]!
    var delegate: UIViewController!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.registerNib(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    func setup() {
        pageControl.numberOfPages = (groups.count - 1) / 9 + 1
    }
}

extension RecommendSiteTableCell {
    
    @IBAction func discoverMoreSite(sender: AnyObject) {
        let vc = Util.createViewControllerWithIdentifier("GroupDiscoverView", storyboardName: "Group") as UIViewController
        self.delegate.navigationController?.presentViewController(vc, animated: true, completion: nil)
    }
}

extension RecommendSiteTableCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GroupCollectionViewCell
        cell.group = groups[indexPath.item]
        cell.setupDisplay()
        return cell
    }
}

extension RecommendSiteTableCell:UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        vc.group = groups[indexPath.item]
        self.delegate.navigationController?.pushViewController(vc, animated: true)
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == collectionView {
            let contentOffsetX = scrollView.contentOffset.x + 20
            if contentOffsetX < 30 {
                pageControl.currentPage = 0
            } else if contentOffsetX + screenWidth > scrollView.contentSize.width {
                pageControl.currentPage = pageControl.numberOfPages - 1
            } else {
                pageControl.currentPage = Int(floor(contentOffsetX / screenWidth))
            }
        }
    }
}

extension RecommendSiteTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = UIScreen.mainScreen().bounds.width / 3 - 1
        let height = collectionView.bounds.height / 3 - 1
        
        return CGSizeMake(width, height)
    }
}

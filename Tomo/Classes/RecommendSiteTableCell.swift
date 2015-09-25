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
    
    var groups: [GroupEntity]!
    var delegate: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.registerNib(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
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
}

extension RecommendSiteTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = UIScreen.mainScreen().bounds.width / 3 - 1
        let height = collectionView.bounds.height / 3 - 1
        
        return CGSizeMake(width, height)
    }
}

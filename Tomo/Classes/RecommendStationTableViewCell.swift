//
//  RecommendStationTableViewCell.swift
//  Tomo
//
//  Created by ebuser on 2015/09/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RecommendStationTableCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    var groups: [GroupEntity]!
    weak var delegate: HomeViewController!
    
    /// cell container --- used for search
    weak var tableViewController: HomeViewController?
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    
    func setup() {
        pageControl.numberOfPages = (groups.count - 1) / 9 + 1
        collectionView.reloadData()
    }
}

extension RecommendStationTableCell {
    
    @IBAction func discoverMoreStation(sender: AnyObject) {
        
        tableViewController?.discoverMoreStation()
    }
}

extension RecommendStationTableCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! StationCollectionViewCell
        cell.group = groups[indexPath.item]
        cell.setupDisplay()
        return cell
    }
}

extension RecommendStationTableCell:UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let group = self.groups[indexPath.item]
        
        AlamofireController.request(.PATCH, "/groups/\(group.id)/join", parameters: nil, encoding: .URL, success: { (result) -> () in
            gcd.async(.Default) {
                let group = GroupEntity(result)
                me.addGroup(group.id)
                self.groups.removeAtIndex(indexPath.item)
                self.pageControl.numberOfPages = (self.groups.count - 1) / 12 + 1
                self.delegate.synchronizeRecommendStations(self.groups)
                gcd.async(.Main) {
                    self.collectionView.deleteItemsAtIndexPaths([indexPath])
                }
            }
        })
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

extension RecommendStationTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = screenWidth / 3 - 1
        let height = collectionView.bounds.height / 3 - 1
        
        return CGSizeMake(width, height)
    }
}
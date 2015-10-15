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
    var stations: [StationEntity]!
    weak var delegate: HomeViewController!
    
    /// cell container --- used for search
    weak var tableViewController: HomeViewController?
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    
    func setup() {
        pageControl.numberOfPages = (stations.count - 1) / 12 + 1
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
        return stations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! StationCollectionViewCell
        cell.station = stations[indexPath.item]
        cell.setupDisplay()
        return cell
    }
}

extension RecommendStationTableCell:UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let station = self.stations[indexPath.item]
        
        AlamofireController.request(.POST, "/stations/\(station.id)", parameters: nil, encoding: .URL, success: { (result) -> () in
            gcd.async(.Default) {
                let group = GroupEntity(result)
                me.addGroup(group.id)
                me.addStation(station.id)
                self.stations.removeAtIndex(indexPath.item)
                self.delegate.synchronizeRecommendStations(self.stations)
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
        let height = collectionView.bounds.height / 4 - 1
        
        return CGSizeMake(width, height)
    }
}
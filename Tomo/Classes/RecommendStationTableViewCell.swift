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
    
    var stations: [StationEntity]!
    var delegate: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
}

extension RecommendStationTableCell {
    
    @IBAction func discoverMoreStation(sender: AnyObject) {
//        let vc = Util.createViewControllerWithIdentifier("GroupDiscoverView", storyboardName: "Group") as UIViewController
//        self.delegate.navigationController?.presentViewController(vc, animated: true, completion: nil)
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
        
        AlamofireController.request(.PATCH, "/me", parameters: ["$addToSet": ["stations":station.id]], encoding: .URL, success: { (result) -> () in
            self.stations.removeAtIndex(indexPath.item)
            collectionView.deleteItemsAtIndexPaths([indexPath])
        }) { (err) -> () in
            
        }
    }
}

extension RecommendStationTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = UIScreen.mainScreen().bounds.width / 3 - 1
        let height = collectionView.bounds.height / 4 - 1
        
        return CGSizeMake(width, height)
    }
}
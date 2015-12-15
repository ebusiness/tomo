//
//  RecommendViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class RecommendViewController: UIViewController {
    
    @IBOutlet weak var recommendGroupCollectionView: UICollectionView!

    private var myGroups = [GroupEntity]()

    private let screenWidth = UIScreen.mainScreen().bounds.width
    
    private let itemSize: CGSize = {
        let width = UIScreen.mainScreen().bounds.width / 3 - 1
        let height: CGFloat = 300 / 4 - 1
        
        return CGSizeMake(width, height)
    }()
    
    private var recommendGroups: [GroupEntity]? {
        didSet {
            self.recommendGroupCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        LocationController.shareInstance.fetchWithCompletion { location in
            self.getRecommendInfo(location)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}


extension RecommendViewController {

    private func getRecommendInfo(location: CLLocation?) {
        
        var params = [
            "category": "discover",
            "type": "station",
            "page": 0
        ]

        if let location = location {
            params["coordinate"] = [location.coordinate.longitude, location.coordinate.latitude]
        } else {
            params["coordinate"] = TomoConst.Geo.CoordinateTokyo //
        }
        
        if nil == self.recommendGroups {
            AlamofireController.request(.GET, "/groups", parameters: params, hideHUD: true, success: { stationData in
                self.recommendGroups = GroupEntity.collection(stationData)
            })
        }
    }
    
    private func joinGroup(indexPath: NSIndexPath){
        
        let group = self.recommendGroups![indexPath.item]
        
        let successHandler: (AnyObject)->() = { _ in
            let removeGroup = self.recommendGroups!.removeAtIndex(indexPath.item)
            me.addGroup(removeGroup.id)
            self.myGroups.append(removeGroup)
            self.recommendGroupCollectionView.reloadData()
        }
        
        AlamofireController.request(.PATCH, "/groups/\(group.id)/join", success: successHandler)
    }

}


extension RecommendViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (recommendGroups ?? []).count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("defaultCell", forIndexPath: indexPath) as! StationRecommendCollectionViewCell

        let group = recommendGroups![indexPath.item]

        cell.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
        cell.nameLabel.text = group.name

        return cell
    }
}

extension RecommendViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }

}

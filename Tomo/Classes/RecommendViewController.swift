//
//  RecommendViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class RecommendViewController: BaseViewController {
    
    @IBOutlet weak var recommendGroupCollectionView: UICollectionView!
    @IBOutlet weak var myGroupCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var myGroups = [GroupEntity]()
    private var restoreRecommendGroups = Dictionary<String,Int>()
    
    private let screenWidth = UIScreen.mainScreen().bounds.width
    
    private let itemSize: CGSize = {
        let width = UIScreen.mainScreen().bounds.width / 3 - 1
        let height: CGFloat = 300 / 4 - 1
        
        return CGSizeMake(width, height)
    }()
    
    private var recommendGroups: [GroupEntity]? {
        didSet {
            if let groups = self.recommendGroups {
                self.pageControl.numberOfPages = (groups.count - 1) / 12 + 1
                self.recommendGroupCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alwaysShowNavigationBar = true
        LocationController.shareInstance.fetchWithCompletion { location in
            self.recommendGroupCollectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            self.myGroupCollectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            self.getRecommendInfo(location)
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        Util.alert(self, title: "退出账号", message: "真的要退出当前的账号吗？", action: { (_) -> Void in
            
            AlamofireController.request(.GET, "/signout")
            
            Defaults.remove("openid")
            Defaults.remove("deviceToken")
            
            Defaults.remove("email")
            Defaults.remove("password")
            
            me = UserEntity()
            let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
            Util.changeRootViewController(from: self, to: main)
        })
    }
    
    @IBAction func goon(sender: AnyObject) {
        if (me.groups ?? []).count > 0 {
            let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
            Util.changeRootViewController(from: self, to: tab)
        } else {
            Util.alert(self, title: "我常去的车站", message: "请设置[我常去的车站]", cancel: "OK")
        }
    }
    
    @IBAction func discoverMoreStation(sender: UIButton) {
        let vc = Util.createViewControllerWithIdentifier("modalStationSelector", storyboardName: "Home")
        self.presentViewController(vc, animated: true, completion: nil)
    }
}


extension RecommendViewController {

    private func getRecommendInfo(location: CLLocation?) {
        
        var params = Dictionary<String, AnyObject>()
        params["category"] = "discover"
        params["page"] = 0
        params["type"] = "station"
        if let location = location {
            params["coordinate"] = [location.coordinate.longitude, location.coordinate.latitude]
        } else {
            params["coordinate"] = [139.6833, 35.6833] //
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
            self.pageControl.numberOfPages = (self.recommendGroups!.count - 1) / 12 + 1
            self.recommendGroupCollectionView.reloadData()
            self.myGroupCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.myGroups.count - 1, inSection: 0)])
        }
        
        AlamofireController.request(.PATCH, "/groups/\(group.id)/join", success: successHandler)
    }
    
    private func leaveGroup(indexPath: NSIndexPath){
        let group = self.myGroups[indexPath.item]
        
        let successHandler: (AnyObject)->() = { _ in
            me.groups?.remove(group.id)
            self.myGroups.removeAtIndex(indexPath.item)
            self.myGroupCollectionView.deleteItemsAtIndexPaths([indexPath])
            
            self.pageControl.numberOfPages = (self.recommendGroups!.count - 1) / 12 + 1
            
            if let item = self.restoreRecommendGroups[group.id] {
                if item < self.recommendGroups!.count {
                    self.recommendGroups!.insert(group, atIndex: item)
                } else {
                    self.recommendGroups!.append(group)
                }
                self.recommendGroupCollectionView.reloadData()
            }
            
        }
        
        AlamofireController.request(.PATCH, "/groups/\(group.id)/leave", success: successHandler)
    }
}


extension RecommendViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recommendGroupCollectionView {
            return (recommendGroups ?? []).count
        } else {
            return myGroups.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! StationCollectionViewCell
        if collectionView == recommendGroupCollectionView {
            let group = recommendGroups![indexPath.item]
            cell.group = group
            self.restoreRecommendGroups[group.id] = indexPath.item
        } else {
            cell.group = myGroups[indexPath.item]
        }
        cell.setupDisplay()
        return cell
    }
}

extension RecommendViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        if collectionView != recommendGroupCollectionView {
            self.leaveGroup(indexPath)
        } else {
            self.joinGroup(indexPath)
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == recommendGroupCollectionView {
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

extension RecommendViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return itemSize
    }
}
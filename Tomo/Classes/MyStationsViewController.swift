//
//  MyStationsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/09/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MyStationsViewController: BaseViewController {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    let deleteImage = Util.coloredImage(UIImage(named: "delete_sign")!, color: UIColor.redColor())
    let editImage = Util.coloredImage(UIImage(named: "delete_sign")!, color: UIColor.whiteColor())
    let saveImage = Util.coloredImage(UIImage(named: "checkmark")!, color: UIColor.whiteColor())
    
    var loading = false
    var isExhausted = false
    var page = 0
    
    @IBOutlet var collectionView: UICollectionView!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var stations: [StationEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alwaysShowNavigationBar = true
        
        Util.changeImageColorForButton(editButton, color: UIColor.whiteColor())
        Util.changeImageColorForButton(addButton, color: UIColor.whiteColor())
        
        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadInitData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        isExhausted = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editTapped(sender: AnyObject) {
        if 0 == editButton.tag {
            editButton.tag = 1
            editButton.setImage(saveImage, forState: .Normal)
            
        } else {
            editButton.tag = 0
            editButton.setImage(editImage, forState: .Normal)
        }
        
        for item in self.collectionView!.visibleCells() as! [StationCollectionViewCell] {
            
            var indexpath : NSIndexPath = self.collectionView.indexPathForCell(item)!
            var cell = self.collectionView.cellForItemAtIndexPath(indexpath) as! StationCollectionViewCell
            
            //Close Button
            var close : UIButton = cell.viewWithTag(101) as! UIButton
            close.hidden = 0 == editButton.tag
        }
    }
    
    @IBAction func addTapped(sender: AnyObject) {
        let vc = Util.createViewControllerWithIdentifier("modalStationSelector", storyboardName: "Home")
        self.presentViewController(vc, animated: true, completion: nil)
        
        if 1 == editButton.tag {
            self.editTapped(editButton)
        }
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MyStationsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stations?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("identifier", forIndexPath: indexPath) as! StationCollectionViewCell
        if let station = stations?[indexPath.row] {
            cell.station = station
        }
        cell.setupDisplay()
        
        if let delBtn = cell.viewWithTag(101) as? UIButton {
            delBtn.hidden = 0 == editButton.tag
        } else {
            let delBtn = UIButton()
            delBtn.tag = 101
            delBtn.hidden = 0 == editButton.tag
            delBtn.backgroundColor = UIColor.whiteColor()
            delBtn.setImage(deleteImage, forState: .Normal)
            delBtn.layer.cornerRadius = 12.5
            delBtn.layer.masksToBounds = true
//            delBtn.layer.borderWidth = 2
//            delBtn.layer.borderColor = UIColor.whiteColor().CGColor
            
            delBtn.addTarget(self, action: Selector("deleteStation:"), forControlEvents: .TouchUpInside)
            
            delBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
            cell.addSubview(delBtn)
            
            cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[delBtn(==25)]", options: nil, metrics: nil, views: ["delBtn" : delBtn]))
            cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[delBtn(==25)]|", options: nil, metrics: nil, views: ["delBtn" : delBtn]))
        }

        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (screenWidth - 2.0) / 3.0
        let height = width / 4.0 * 3.0
        return CGSizeMake(width, height)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let station = stations?[indexPath.row] {
            AlamofireController.request(.PATCH, "/me", parameters: ["$addToSet": ["stations":station.id]], encoding: .URL, success: { (result) -> () in
                self.stations?.remove(station)
                collectionView.deleteItemsAtIndexPaths([indexPath])
                }) { (err) -> () in
                    
            }
            
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

// MARK: - Network and data process
extension MyStationsViewController {
    private func loadInitData() {
        loading = true
        let parameter: [String: AnyObject] = [
            "category": "mine",
        ]
        AlamofireController.request(.GET, "/stations",
            parameters: parameter, success: { (object) -> () in
                self.stations = StationEntity.collection(object)
                self.refresh()
                self.loading = false
                self.editButton.enabled = true
                self.page = 1
            }) { (error) -> () in
                self.loading = false
                self.isExhausted = true
        }
    }
    
    private func loadMoreData() {
        if loading || isExhausted {
            return
        }
        loading = true
        let parameter: [String: AnyObject] = [
            "category": "mine",
            "page": page
        ]
        AlamofireController.request(.GET, "/stations", parameters: parameter,
            success: { (object) -> () in
                if let stations: [StationEntity] = StationEntity.collection(object) {
                    self.stations?.extend(stations)
                    self.appendCells(stations.count)
                    self.page++
                }
                self.loading = false
            }, failure: {error in
                self.loading = false
                self.isExhausted = true
            }
        )
    }
    
    private func refresh() {
        collectionView.reloadData()
    }
    
    private func appendCells(count: Int) {
        if let totalCount = stations?.count {
            let startIndex = totalCount - count
            let endIndex = totalCount
            var indexPaths = [NSIndexPath]()
            for i in startIndex..<endIndex {
                let indexPath = NSIndexPath(forItem: i, inSection: 0)
                indexPaths.append(indexPath)
            }
            collectionView.insertItemsAtIndexPaths(indexPaths)
        }
    }
    
    func deleteStation(sender: UIButton){
        
        let cell = sender.superview as! StationCollectionViewCell
        let indexPath = self.collectionView.indexPathForCell(cell)!

        AlamofireController.request(.PATCH, "/me", parameters: ["$pull": ["stations":cell.station.id]], encoding: .URL, success: { (result) -> () in
            self.stations?.remove(cell.station)
            self.collectionView.deleteItemsAtIndexPaths([indexPath])
            if self.stations!.count < 1 {
                self.editButton.enabled = false
            }
        }) { (err) -> () in
                
        }
    }
}

extension MyStationsViewController  {
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentHeight = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y
        let measuredOffset: CGFloat
        if screenHeight > contentHeight + scrollView.contentInset.top {
            measuredOffset = contentOffset + scrollView.contentInset.top
        } else {
            measuredOffset = contentOffset - (contentHeight - screenHeight)
        }
        if measuredOffset > 25 {
            loadMoreData()
        }
    }
}


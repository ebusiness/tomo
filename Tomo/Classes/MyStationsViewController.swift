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
    @IBOutlet var collectionView: UICollectionView!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    let markImage = UIImage(named: "ok")!
    let editImage = Util.coloredImage(UIImage(named: "delete_sign")!, color: UIColor.whiteColor())
    let saveImage = Util.coloredImage(UIImage(named: "delete")!, color: UIColor.whiteColor())
    
    var loading = false
    
    var stations: [StationEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alwaysShowNavigationBar = true
        self.collectionView.allowsMultipleSelection = true
        
        Util.changeImageColorForButton(editButton, color: UIColor.whiteColor())
        Util.changeImageColorForButton(addButton, color: UIColor.whiteColor())
        
        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadInitData()
    }
    
    @IBAction func editTapped(sender: AnyObject) {
        if 0 == editButton.tag {
            editButton.tag = 1
            editButton.setImage(saveImage, forState: .Normal)
            
        } else {
            editButton.tag = 0
            editButton.setImage(editImage, forState: .Normal)
            self.deleteStation()
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

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (screenWidth - 2.0) / 3.0
        let height = width / 4.0 * 3.0
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                cell.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: { (_) -> Void in
                let mark = UIImageView(image: self.markImage)
                mark.layer.cornerRadius = 12.5
                mark.layer.masksToBounds = true
                mark.layer.borderWidth = 2
                mark.layer.borderColor = UIColor.whiteColor().CGColor
                mark.setTranslatesAutoresizingMaskIntoConstraints(false)
                cell.contentView.addSubview(mark)
                cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[mark(25)]", options: nil, metrics: nil, views: ["mark" : mark]))
                cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[mark(25)]-5-|", options: nil, metrics: nil, views: ["mark" : mark]))
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                cell.transform = CGAffineTransformIdentity
            }, completion: { (_) -> Void in
                cell.contentView.subviews.last?.removeFromSuperview()
            })
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return editButton.tag == 1
    }
    
}

// MARK: - Network and data process
extension MyStationsViewController {
    
    private func loadInitData() {
        
        if me.stations == nil {
            return
        }
        
        if me.stations?.count == self.stations?.count {
            return
        }
        
        if loading {
            return
        }
        
        loading = true
        let parameter: [String: AnyObject] = [
            "category": "mine",
            "size": (me.stations ?? []).count
        ]
        AlamofireController.request(.GET, "/stations",
            parameters: parameter, success: { object in
                let oldStations = self.stations ?? []
                self.stations = StationEntity.collection(object)
                
                var indexPaths = [NSIndexPath]()
                self.stations?.each { (index, value) -> Void in
                    let needInsertStation = oldStations.find { $0.id == value.id }
                    if needInsertStation == nil {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                    }
                }
                if indexPaths.count > 0 {
                    self.collectionView.performBatchUpdates({ _ in
                        self.collectionView.insertItemsAtIndexPaths(indexPaths)
                    }) { _ in
                        NSLog("done")
                    }
                }
                self.loading = false
                self.editButton.enabled = true
            }) { _ in
                self.loading = false
        }
    }
    
    func deleteStation(){
        if let selectedIndexes = self.collectionView.indexPathsForSelectedItems() as? [NSIndexPath]
            where selectedIndexes.count > 0 {
                
                var stationids = [String]()
                selectedIndexes.map {
                    stationids.append(self.stations![$0.item].id)
                }
                
                var params = Dictionary<String, AnyObject>()
                params["stations"] = stationids
                
                AlamofireController.request(.DELETE, "/me/leave/stations", parameters: params, success: { (result) -> () in
                    self.collectionView.performBatchUpdates({ () -> Void in
                        /**
                        *  remove the mark of the selected cells
                        */
                        selectedIndexes.map {
                            self.collectionView(self.collectionView, didDeselectItemAtIndexPath: $0)
                        }
                        /**
                        *  remove the cells of select
                        */
                        self.collectionView.deleteItemsAtIndexPaths(selectedIndexes)
                        let userinfo = UserEntity(result)
                        me.stations = userinfo.stations
                        me.groups = userinfo.groups
                        self.stations = self.stations?.filter { !stationids.contains($0.id) }
                        
                    }, completion: { finished in
                            
                        if self.stations!.count < 1 {
                            self.editButton.enabled = false
                        }
//                        self.collectionView.reloadItemsAtIndexPaths(self.collectionView.indexPathsForVisibleItems())
                    })
                })
                return ;
        }
    }
}


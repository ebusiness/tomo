//
//  MyStationsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/09/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MyStationsViewController: BaseViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    let markImage = UIImage(named: "ok")!
    let editImage = Util.coloredImage(UIImage(named: "delete_sign")!, color: UIColor.whiteColor())
    let saveImage = Util.coloredImage(UIImage(named: "delete")!, color: UIColor.whiteColor())
    
    var loading = false
    
    var groups = [GroupEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alwaysShowNavigationBar = true
        self.collectionView.allowsMultipleSelection = true
        
        Util.changeImageColorForButton(addButton, color: UIColor.whiteColor())
        
        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadInitData()
    }
    
    @IBAction func addTapped(sender: AnyObject) {
        let vc = Util.createViewControllerWithIdentifier("modalStationSelector", storyboardName: "Home")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MyStationsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("identifier", forIndexPath: indexPath) as! StationCollectionViewCell
        cell.group = self.groups[indexPath.item]
        cell.setupDisplay()

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (screenWidth - 2.0) / 3.0
        let height = width / 4.0 * 3.0
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let vc = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        vc.group = self.groups[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - Network and data process
extension MyStationsViewController {
    
    private func loadInitData() {
        
        if me.groups == nil {
            return
        }
        
        let updates: (() -> Void) = { _ in
            self.deleteGroupsIfNeeded() {
                if me.groups!.count != self.groups.count {
                    self.loadMyStatios()
                }
            }
        }
        
        self.collectionView.performBatchUpdates(updates, completion: nil)
    }
    
    private func deleteGroupsIfNeeded(completion: ()->()) {
        gcd.async(.Default) {
            
            var needDeleteIndexPaths = [NSIndexPath]()
            
            let myGroups = me.groups ?? []
            
            self.groups.each { (index, value) -> Void in
                if !myGroups.contains(value.id) {
                    needDeleteIndexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                    self.groups.removeAtIndex(index)
                }
            }
            
            gcd.async(.Main) {
                if needDeleteIndexPaths.count > 0 {
                    self.collectionView.deleteItemsAtIndexPaths(needDeleteIndexPaths)
                }
                completion()
            }
        }
    }
    
    private func loadMyStatios(){
        if loading {
            return
        }
        
        loading = true
        
        let parameter: [String: AnyObject] = [
            "category": "mine",
            "type": "station"
        ]
        
        AlamofireController.request(.GET, "/groups", parameters: parameter, success: { object in
            gcd.async(.Default) {
                let newGroups: [GroupEntity] = GroupEntity.collection(object) ?? []
                
                var needInsertIndexPaths = [NSIndexPath]()
                newGroups.each { (_, group) -> Void in
                    let needInsertGroup = self.groups.find { $0.id == group.id } == nil
                    if needInsertGroup {
                        needInsertIndexPaths.append(NSIndexPath(forItem: self.groups.count, inSection: 0))
                        self.groups.append(group)
                    }
                }
                gcd.async(.Main) {
                    if needInsertIndexPaths.count > 0 {
                        self.collectionView.insertItemsAtIndexPaths(needInsertIndexPaths)
                    }
                    self.loading = false
                }
            }
        }) { _ in
            self.loading = false
        }

    }
    
}


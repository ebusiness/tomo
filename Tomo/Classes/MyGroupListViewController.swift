//
//  MyGroupListViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MyGroupListViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var groups = [GroupEntity]()
    
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        self.collectionView.registerNib(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
        if self.groups.count > 0 {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        } else {
            var image = Util.imageWithColor(NavigationBarColorHex, alpha: 1)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage(named:"text_protection")?.scaleToFillSize(CGSizeMake(320, 5))
        }
        self.loadMoreContent()
    }
}


// MARK: UICollectionViewDataSource

extension MyGroupListViewController {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groups.count
    }
    
}

// MARK: UICollectionViewDelegate

extension MyGroupListViewController {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GroupCollectionViewCell
        
        cell.group = self.groups[indexPath.item]
        cell.setupDisplay()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.navigationItem.titleView?.endEditing(true)
        let vc = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        vc.group = groups[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Internal methods

extension MyGroupListViewController {
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading {
            return
        }
        
        isLoading = true
        
        AlamofireController.request(.GET, "/groups", parameters: ["category": "mine"], success: { groups in
            
            let oldDataCount = self.groups.count
            let groups: [GroupEntity]? = GroupEntity.collection(groups)
            
            if let groups = groups {
                self.groups = groups
                self.collectionView.reloadData()
//                self.appendRows(groups.count)
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
            }
            self.isLoading = false
        }) { err in
                self.isLoading = false
        }
        
    }

    private func appendRows(rows: Int) {
        
        let firstIndex = self.groups.count - rows
        let lastIndex = self.groups.count
        
        var indexPathes = [NSIndexPath]()
        
        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        self.collectionView?.insertItemsAtIndexPaths(indexPathes)
    }
    
}




//
//  GroupCollectionViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/11.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class GroupDiscoverViewController: UICollectionViewController {
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let loadTriggerHeight = CGFloat(88.0)
    
    var groups = [GroupEntity]()
    var page = 0
    
    var isLoading = false
    var isExhausted = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView?.registerNib(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

        self.loadMoreContent()
    }
}

// MARK: - Navigation

extension GroupDiscoverViewController {
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
}

// MARK: Actions

extension GroupDiscoverViewController {
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: UIScrollView delegate

extension GroupDiscoverViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (contentHeight - screenHeight - loadTriggerHeight) < offsetY {
            self.loadMoreContent()
        }
    }
}


// MARK: UICollectionViewDataSource

extension GroupDiscoverViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groups.count
    }

}

// MARK: UICollectionViewDelegate

extension GroupDiscoverViewController {
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GroupCollectionViewCell
        
        cell.group = self.groups[indexPath.item]
        cell.setupDisplay()
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        vc.group = groups[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var edge = (UIScreen.mainScreen().bounds.width - 1) / 2.0
        
        return CGSizeMake(edge, edge/3*4)
    }
}

// MARK: Internal methods

extension GroupDiscoverViewController {
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        AlamofireController.request(.GET, "/groups", parameters: ["category": "discover", "page": self.page], success: { groups in
            
            let groups: [GroupEntity]? = GroupEntity.collection(groups)
            
            if let groups = groups {
                self.groups.extend(groups)
                self.appendRows(groups.count)
            }
            
            self.page++
            self.isLoading = false
            
        }) { err in
            self.isLoading = false
            self.isExhausted = true
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


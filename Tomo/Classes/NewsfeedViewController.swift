//
//  NewsfeedViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

let count = 30

class NewsfeedViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var newsfeeds: NSFetchedResultsController!
    
    var sizes = [CGSize]()
    
    var cellForHeight: NewsfeedCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerNib(UINib(nibName: "NewsfeedCell", bundle: nil), forCellWithReuseIdentifier: "NewsfeedCell")
        newsfeeds = DBController.newsfeeds()
        
        setupLayout()
        
        setupSizes()
    }
    
    func setupLayout() {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }

    func setupSizes() {
        for i in 0..<count {
            let size = CGSizeMake(CGFloat(arc4random() % 250 + 250), CGFloat(arc4random() % 250 + 250))
            sizes.append(size)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NewsfeedViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NewsfeedCell", forIndexPath: indexPath) as NewsfeedCell
        
        cell.imageSize = sizes[indexPath.item]
        
        cell.configCell()
        
        return cell
    }
}

extension NewsfeedViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        if cellForHeight == nil {
            cellForHeight = Util.createViewWithNibName("NewsfeedCell") as NewsfeedCell
        }
        
        let cellWidth = (collectionView.bounds.width - 3 * 10) / 2
        let imageSize = sizes[indexPath.item]
        
        cellForHeight.imageSize = imageSize

        var size = cellForHeight.sizeOfCell(cellWidth)
        size.width = cellWidth
        
        return size
    }

}


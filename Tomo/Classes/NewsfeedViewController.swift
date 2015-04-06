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
    
    var postsFRC: NSFetchedResultsController!
    
    var count: Int {
        return (postsFRC.sections as [NSFetchedResultsSectionInfo])[0].numberOfObjects
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postsFRC = DBController.newsfeeds()
        postsFRC.delegate = self
        
        collectionView.registerNib(UINib(nibName: "NewsfeedCell", bundle: nil), forCellWithReuseIdentifier: "NewsfeedCell")
        newsfeeds = DBController.newsfeeds()
        
        setupLayout()
        
        setupSizes()
        
        ApiController.getNewsfeed { (error) -> Void in
            println("getNewsfeed done")
        }
    }
    
    func setupLayout() {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }

    func setupSizes() {
        for i in 0..<count {
            let size = CGSizeMake(CGFloat(arc4random() % 500 + 500), CGFloat(arc4random() % 500 + 500))
            sizes.append(size)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SeguePostDetail" {
            let vc = segue.destinationViewController as PostDetailViewController
//            vc.post = sender as Post
            let indexPath = sender as NSIndexPath
            let post = postsFRC.objectAtIndexPath(indexPath) as Post
            let imageSize = sizes[indexPath.item]
            
            vc.post = post
            vc.imageSize = imageSize
        }
    }

}

// MARK: - UICollectionView

extension NewsfeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let post = postsFRC.objectAtIndexPath(indexPath) as Post
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NewsfeedCell", forIndexPath: indexPath) as NewsfeedCell
        
        cell.imageSize = sizes[indexPath.item]
        cell.post = post
        
        cell.configCell()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let post = postsFRC.objectAtIndexPath(indexPath) as Post
        
        performSegueWithIdentifier("SeguePostDetail", sender: indexPath)
    }
}

// MARK: - layout

extension NewsfeedViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        let post = postsFRC.objectAtIndexPath(indexPath) as Post
        
        if cellForHeight == nil {
            cellForHeight = Util.createViewWithNibName("NewsfeedCell") as NewsfeedCell
        }
        
        let cellWidth = (collectionView.bounds.width - 3 * 10) / 2
        let imageSize = sizes[indexPath.item]
        
        cellForHeight.imageSize = imageSize
        cellForHeight.post = post
        
        var size = cellForHeight.sizeOfCell(cellWidth)
        size.width = cellWidth
        
        return size
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension NewsfeedViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        setupSizes()
        self.collectionView.reloadData()
    }
}


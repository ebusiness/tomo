//
//  BookmarkedPostsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class BookmarkedPostsViewController: MyAccountBaseController {
    
    var frc: NSFetchedResultsController!
    var objectChanges = Dictionary<NSFetchedResultsChangeType, [NSIndexPath]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load local post data
        frc = DBController.myBookmarkedPosts()
        frc.delegate = self
        
        var postCellNib = UINib(nibName: "PostCell", bundle: nil)
        self.tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        var postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        self.tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")
    }
    
}

extension BookmarkedPostsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var post = frc.objectAtIndexPath(indexPath) as! Post
        var cell: PostCell!
        
        if post.imagesmobile.count > 0 {
            
            cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell", forIndexPath: indexPath) as! PostImageCell
            
            let subviews = (cell as! PostImageCell).scrollView.subviews
            
            for subview in subviews {
                subview.removeFromSuperview()
            }
            
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        }
        
        cell.post = post
        cell.setupDisplay()
        
        return cell
    }
}

extension BookmarkedPostsViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
        vc.post = frc.objectAtIndexPath(indexPath) as! Post
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension BookmarkedPostsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        objectChanges.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if objectChanges[type] == nil {
            objectChanges[type] = [NSIndexPath]()
        }
        
        switch type {
        case .Insert:
            if let newIndexPath = newIndexPath {
                objectChanges[type]!.append(newIndexPath)
            }
        case .Delete:
            if let indexPath = indexPath {
                objectChanges[type]!.append(indexPath)
            }
        case .Update:
            if let indexPath = indexPath {
                objectChanges[type]!.append(indexPath)
            }
        case .Move:
            // TODO:
            println("move")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // TODO: move,update,delete
        //        let insertedItems = self.objectChanges[.Insert]
        //        if insertedItems?.count > 0 {
        //            self.tableView.insertItemsAtIndexPaths(insertedItems!)
        //        }
        //
        //        let deleteItems = self.objectChanges[.Delete]
        //        if deleteItems?.count > 0 {
        //            self.tableView.deleteItemsAtIndexPaths(deleteItems!)
        //        }
    }
    
}

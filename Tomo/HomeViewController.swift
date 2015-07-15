//
//  HomeViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var frc: NSFetchedResultsController!
    var objectChanges = Dictionary<NSFetchedResultsChangeType, [NSIndexPath]>()
    
    var pointNow: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load local post data
        frc = DBController.newsfeeds()
        frc.delegate = self
        
        var postCellNib = UINib(nibName: "PostCell", bundle: nil)
        tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        var postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")

        var tableViewController = UITableViewController()
        tableViewController.tableView = tableView

        var refresh = UIRefreshControl()
        refresh.addTarget(self, action: "test", forControlEvents: UIControlEvents.ValueChanged)
        
        tableViewController.refreshControl = refresh
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load reomte data
        ApiController.getNewsfeed() { (error) -> Void in
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.navigationController!.navigationBarHidden
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postdetail" {
            if let post = sender as? Post {
                let vc = segue.destinationViewController as! PostViewController
                vc.post = post
            }
        }
    }
    
    func test() {
        println("###############")
        return
        
    }
    
    @IBAction func addPostBtnTapped(sender: UIBarButtonItem) {
        
        let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: "AddPost") as! UINavigationController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < pointNow?.y {
            setTabBarVisible(true, animated: true)
        } else if scrollView.contentOffset.y > pointNow?.y {
            setTabBarVisible(false, animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset;
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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

extension HomeViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let post: AnyObject = frc.objectAtIndexPath(indexPath)
        self.performSegueWithIdentifier("postdetail", sender: post)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension HomeViewController: NSFetchedResultsControllerDelegate {
    
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
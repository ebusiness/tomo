//
//  HomeViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class HomeViewController: BaseTableViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorLabel: UILabel!
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let loadTriggerHeight = CGFloat(88.0)
    
    var contents = [AnyObject]()
    var latestContent: AnyObject?
    var oldestContent: AnyObject?
    
    var isLoading = false
    var isExhausted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var postCellNib = UINib(nibName: "PostCell", bundle: nil)
        tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        var postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")
        
        var RecommendSiteTableCellNib = UINib(nibName: "RecommendSiteTableCell", bundle: nil)
        tableView.registerNib(RecommendSiteTableCellNib, forCellReuseIdentifier: "RecommendSiteTableCell")
        
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        clearsSelectionOnViewWillAppear = false

        var refresh = UIRefreshControl()
        refresh.addTarget(self, action: "loadNewContent", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl = refresh
        
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        loadMoreContent()
    }
    
    override func becomeActive() {
        self.loadNewContent()
    }
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postdetail" {
            if let post = sender as? PostEntity {
                let vc = segue.destinationViewController as! PostViewController
                vc.post = post
            }
        }
    }
    
    @IBAction func addedPost(segue: UIStoryboardSegue) {
        // exit addPostView
    }
}

// MARK: UITableView datasource

extension HomeViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let groups = contents[indexPath.item] as? [GroupEntity] {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RecommendSiteTableCell", forIndexPath: indexPath) as! RecommendSiteTableCell
            cell.groups = groups
            cell.delegate = self
            return cell
            
        } else if let post = contents[indexPath.row] as? PostEntity {
            
            var cell: PostCell!
            
            if post.images?.count > 0 {
                
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
            
        } else {
            return UITableViewCell()
        }

    }
}

// MARK: UITableView delegate

extension HomeViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let post = contents[indexPath.row] as? PostEntity {
            self.performSegueWithIdentifier("postdetail", sender: post)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let post = contents.get(indexPath.row) as? PostEntity {
            
            var textHeight = 0
            
            if post.content.length > 150 {
                // one character take 18 points height, 
                // and 150 characters will take 7 rows
                textHeight = 18 * 7
            } else {
                // one row have 24 characters
                textHeight = post.content.length / 24 * 18
            }
            
            if post.images?.count > 0 {
                return CGFloat(472 + textHeight)
            } else {
                return CGFloat(108 + textHeight)
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
}

// MARK: UIScrollView delegate

extension HomeViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        super.scrollViewDidScroll(scrollView)
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (contentHeight - screenHeight - loadTriggerHeight) < offsetY {
            loadMoreContent()
        }
        
        if offsetY < 0 {
            indicatorLabel.alpha = abs(offsetY)/64
            activityIndicator.alpha = abs(offsetY)/64
        }
    }
}

// MARK: Internal methods

extension HomeViewController {
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }

        isLoading = true
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let oldestContent = oldestContent as? PostEntity {
            params["before"] = oldestContent.createDate.timeIntervalSince1970
        }
        
        AlamofireController.request(.GET, "/posts", parameters: params, success: { result in
            
            AlamofireController.request(.GET, "/groups", parameters: nil, success: { groups in
                
                let posts: [PostEntity]? = PostEntity.collection(result)
                let groups: [GroupEntity]? = GroupEntity.collection(groups)
                
                var rowNumber = 0
                
                if let loadPosts: [AnyObject] = posts {
                    self.contents += loadPosts
                    rowNumber += loadPosts.count
                }
                
                if let loadGroups: AnyObject = groups as? AnyObject {
                    
                    if rowNumber > 0 {
                        let insertIndex = arc4random_uniform(UInt32(rowNumber/2)) + 1
                        self.contents.insert(loadGroups, atIndex: Int(insertIndex))
                    }
                    rowNumber += 1
                }
                
                self.appendRows(rowNumber)
                
                self.isLoading = false
                
            }) { err in
                
            }
            
        }) { err in
            
            self.isLoading = false
            self.isExhausted = true
        }
    }
    
    func loadNewContent() {
        
        // skip if already in loading
        if isLoading {
            return
        }

        isLoading = true
        
        activityIndicator.startAnimating()
        indicatorLabel.text = "正在加载"
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let latestContent = latestContent as? PostEntity {
            // TODO - This is a dirty solution
            params["after"] = latestContent.createDate.timeIntervalSince1970 + 1
        }
        
        AlamofireController.request(.GET, "/posts", parameters: params, success: { result in
            
            if let loadPosts:[PostEntity] = PostEntity.collection(result) {
                self.contents = loadPosts + self.contents
                self.prependRows(loadPosts.count)
            } else {
                // the response is not post
            }
            self.endRefreshing()
            
        }) { err in
            
            self.endRefreshing()
        }
    }
    
    private func endRefreshing() {
        
        self.isLoading = false
        self.refreshControl?.endRefreshing()
        self.activityIndicator.stopAnimating()
        self.activityIndicator.alpha = 0
        self.indicatorLabel.alpha = 0
        self.indicatorLabel.text = "向下拉动加载更多内容"
    }

    private func appendRows(rows: Int) {
        
        let firstIndex = contents.count - rows
        let lastIndex = contents.count
        
        var indexPathes = [NSIndexPath]()
        
        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        // hold the oldest content for pull-up loading
        oldestContent = contents.last
        
        // hold the latest content for pull-down loading
        if firstIndex == 0 {
            latestContent = contents.first
        }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
        
    }
    
    private func prependRows(rows: Int) {
        
        var indexPathes = [NSIndexPath]()
        
        for index in 0..<rows {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        // hold the latest content for pull-up loading
        latestContent = contents.first
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
    }
}
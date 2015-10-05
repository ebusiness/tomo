//
//  GroupListTableViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/11.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class GroupListViewController: BaseTableViewController {
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let loadTriggerHeight = CGFloat(88.0)
    
    var groups = [GroupEntity]()
    
    var isLoading = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let GroupSectionHeaderNib = UINib(nibName: "GroupSectionHeaderView", bundle: nil)
        self.tableView.registerNib(GroupSectionHeaderNib, forHeaderFooterViewReuseIdentifier: "GroupHeader")
        
        let postCellNib = UINib(nibName: "PostCell", bundle: nil)
        self.tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        let postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        self.tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")
        
        self.tableView.estimatedRowHeight = 550
        self.tableView.rowHeight = UITableViewAutomaticDimension
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

// MARK: - Navigation

extension GroupListViewController {
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - UITableView DataSource

extension GroupListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.groups.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let posts = self.groups[section].posts {
            return posts.count
        } else {
            return 0
        }
    }
}

// MARK: - UITableView Delegate

extension GroupListViewController {
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("GroupHeader") as! GroupSectionHeaderView
        
        header.group = self.groups[section]
        header.delegate = self.navigationController
        header.setupDisplay()
        
        return header
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: PostCell!
        
        if let posts = self.groups[indexPath.section].posts {
            
            let post = posts[indexPath.row]
            
            if post.images?.count > 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell", forIndexPath: indexPath) as! PostImageCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
            }
            
            cell.post = post
            cell.setupDisplay()
        }
        
        return cell
    }
}

// MARK: Internal methods

extension GroupListViewController {
    
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
                if oldDataCount > 0 {
                    self.reloadCells()
                } else {
                    self.appendRows(groups.count)
                }
            }
            self.isLoading = false
            
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            
        }) { err in
            self.isLoading = false
        }
        
    }

    private func reloadCells(){
        if let indexPaths = self.tableView.indexPathsForVisibleRows() {
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
    }
    
    private func appendRows(rows: Int) {
        
        let firstIndex = self.groups.count - rows
        
        var indexSet = NSIndexSet(indexesInRange: NSMakeRange(firstIndex, rows))
        
        self.tableView.beginUpdates()
        self.tableView.insertSections(indexSet, withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
    
}

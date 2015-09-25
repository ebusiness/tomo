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
    var page = 0
    
    var isLoading = false
    var isExhausted = false

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

    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        let rect = self.tableView.rectForHeaderInSection(1)
//        println(rect)
//        println(scrollView.contentOffset.y)
//        if let topCell = self.tableView.visibleCells().get(0) as? UITableViewCell {
//            println(tableView.indexPathForCell(topCell)?.section)
//        }
    }
}

// MARK: Internal methods

extension GroupListViewController {
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        AlamofireController.request(.GET, "/groups", parameters: ["page": self.page, "category": "mine"], success: { groups in
            
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
        
        var indexSet = NSIndexSet(indexesInRange: NSMakeRange(firstIndex, rows))
        
        self.tableView.beginUpdates()
        self.tableView.insertSections(indexSet, withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
    
}

//
//  NewsfeedViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewsfeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var newsfeeds: NSFetchedResultsController!
    var cellForHeight: NewsfeedCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newsfeeds = DBController.newsfeeds()
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

// MARK: - TableView

extension NewsfeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newsfeed = newsfeeds.objectAtIndexPath(indexPath) as Newsfeed
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsfeedCell", forIndexPath: indexPath) as NewsfeedCell
        cell.newsfeed = newsfeed
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = newsfeeds.sections as [NSFetchedResultsSectionInfo]
        return s[section].numberOfObjects
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let newsfeed = newsfeeds.objectAtIndexPath(indexPath) as Newsfeed
//
//        if cellForHeight == nil {
//            cellForHeight = self.tableView.dequeueReusableCellWithIdentifier("NewsfeedCell") as? NewsfeedCell
//        }
//        
//        cellForHeight.newsfeed = newsfeed
//        
//        return calculateHeightForConfiguredSizingCell(cellForHeight)
//    }
//    
//    func calculateHeightForConfiguredSizingCell(cell: UITableViewCell) -> CGFloat {
//        cell.bounds = CGRectMake(0,0,tableView.bounds.width,cell.bounds.height)
//        cell.setNeedsLayout()
//        cell.layoutIfNeeded()
//        
//        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
//        
//        return size.height + 1
//    }
}

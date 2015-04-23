//
//  GroupListViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var frc: NSFetchedResultsController!
    
    var count: Int {
        return (frc.sections as! [NSFetchedResultsSectionInfo])[0].numberOfObjects
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        frc = DBController.groups()
        frc.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ApiController.getGroups { (error) -> Void in
            
        }
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

// MARK: - UITableView

extension GroupListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return count
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 168
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath) as! GroupCell
        
        let group = frc.objectAtIndexPath(indexPath) as! Group
        
        cell.group = group
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let group = frc.objectAtIndexPath(indexPath) as! Group

    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension GroupListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}

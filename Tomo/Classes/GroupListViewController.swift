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
    var station:String = "";
    
    func numberOfRowsInSection(section: Int) -> Int {
        return (frc.sections as! [NSFetchedResultsSectionInfo])[section].numberOfObjects
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        frc = DBController.groups(station)
        frc.delegate = self
        frc.performFetch(nil)
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return frc.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let title = frc.sectionIndexTitles[section] as! String
//        return GroupSection(rawValue: title.toInt()!)?.groupSectionTitle()
//    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 57
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = frc.sectionIndexTitles[section] as! String
        
        let headerView = Util.createViewWithNibName("GroupHeaderView") as! GroupHeaderView
        headerView.groupSection = GroupSection(rawValue: title.toInt()!)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let group = frc.objectAtIndexPath(indexPath) as! Group
        
        return GroupCell.height(group: group)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath) as! GroupCell
        
        configCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configCell(cell: GroupCell?, indexPath: NSIndexPath) {
        if let cell = cell {
            let group = frc.objectAtIndexPath(indexPath) as! Group
            cell.group = group
            cell.delegate = self
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let group = frc.objectAtIndexPath(indexPath) as! Group

        let vc = Util.createViewControllerWithIdentifier("NewsfeedViewController", storyboardName: "Newsfeed") as! NewsfeedViewController
        vc.displayMode = .Group
        vc.group = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension GroupListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            println("move")
        case .Update:
            println("update")
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let indexPath = indexPath {
                configCell(tableView.cellForRowAtIndexPath(indexPath) as? GroupCell, indexPath: indexPath)
            }
        case .Move:
            if let indexPath = indexPath, newIndexPath = newIndexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
//        tableView.reloadData()
    }
}

// MARK: - GroupCellDelegate

extension GroupListViewController: GroupCellDelegate {
    
    func didTapMemberListOfGroupCell(cell: GroupCell) {
        let vc = Util.createViewControllerWithIdentifier("FriendListViewController", storyboardName: "Chat") as! FriendListViewController
        vc.displayMode = .List
        vc.users = cell.group.participants.array as! [User]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
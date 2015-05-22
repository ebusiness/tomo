//
//  AnnouncementsViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class AnnouncementsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var makeAllReadBtn: UIBarButtonItem!
    
    var frc: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateMakeAllReadBtnStatus()
        
        frc = DBController.allAnnouncements()
        frc.delegate = self
    }
    
    func updateMakeAllReadBtnStatus() {
        makeAllReadBtn.enabled = DBController.unreadAnnouncementsCount() > 0
    }
    
    // MARK: - Action
    
    @IBAction func makeAllReadBtnTapped(sender: UIBarButtonItem) {
        DBController.makeAllAnnouncementsRead()
        
        makeAllReadBtn.enabled = false
        
        (self.navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueWebViewController" {
            let ann = sender as! Announcements
            let vc = segue.destinationViewController as! WebViewController
            vc.navigationTitle = ann.title
            vc.path = ann.path
        }
    }
}

extension AnnouncementsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let announcement = frc.objectAtIndexPath(indexPath) as! Announcements
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AnnouncementCell", forIndexPath: indexPath) as! AnnouncementCell
        cell.announcement = announcement
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let announcement = frc.objectAtIndexPath(indexPath) as! Announcements
        if announcement.isRead != true {
            announcement.isRead = true
            DBController.save()
        }
        
        performSegueWithIdentifier("SegueWebViewController", sender: announcement)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension AnnouncementsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let indexPath = indexPath where type == .Update {
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            updateMakeAllReadBtnStatus()
            (self.navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
        }
    }
    
}

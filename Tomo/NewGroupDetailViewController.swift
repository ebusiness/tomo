//
//  NewGroupDetailViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewGroupDetailViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var group: Group?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        if let backImage = UIImage(named: "left") {
            let image = Util.coloredImage(backImage, color: UIColor.whiteColor())
            backButton?.setImage(image, forState: UIControlState.Normal)
        }
        
        if let settingImage = UIImage(named: "settings") {
            let image = Util.coloredImage(settingImage, color: UIColor.whiteColor())
            settingButton?.setImage(image, forState: UIControlState.Normal)
        }
        
        if let memberImage = UIImage(named: "group") {
            let image = Util.coloredImage(memberImage, color: UIColor.whiteColor())
            memberButton?.setImage(image, forState: UIControlState.Normal)
        }
        
        var postCellNib = UINib(nibName: "PostCell", bundle: nil)
        tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        var postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")
        
        var tableViewController = UITableViewController()
        tableViewController.tableView = tableView
        
        var refresh = UIRefreshControl()
        refresh.addTarget(self, action: "test", forControlEvents: UIControlEvents.ValueChanged)
        
        tableViewController.refreshControl = refresh
        
        groupNameLabel.text = group?.name
        introductionLabel.text = group?.detail
        
        if let cover_ref = group!.cover_ref {
            coverImageView.sd_setImageWithURL(NSURL(string: cover_ref))
        }
        
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

extension NewGroupDetailViewController {
    
    @IBAction func backToList(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
}

extension NewGroupDetailViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        
        return cell
    }
    
}

extension NewGroupDetailViewController: UITableViewDelegate {
    
}

//
//  NewSettingViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewSettingViewController: UITableViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var myPostsCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.layer.cornerRadius = photoImageView.bounds.width / 2
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.borderWidth = 1
        photoImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        if let editImage = UIImage(named: "edit_user") {
            let image = Util.coloredImage(editImage, color: UIColor.whiteColor())
            editButton?.setImage(image, forState: UIControlState.Normal)
        }
        
        ApiController.getMyInfo({ (error) -> Void in
            if error == nil {
                self.updateUI()
            }
        })
    }
    
    func updateUI() {
        user = DBController.myUser()
        
        nickNameLabel.text = user?.nickName
        
        bioLabel.text = user?.bioText
        
        if let url = user?.photo_ref {
            photoImageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: DefaultAvatarImage)
        }
        
        fullNameLabel.text = user?.fullName()
        
        genderLabel.text = user?.genderText()
        
//        birthDayLabel.text = user?.birthDay.
        
        addressLabel.text = user?.address

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell == myPostsCell {
            
            let vc = Util.createViewControllerWithIdentifier("NewsfeedViewController", storyboardName: "Newsfeed") as! NewsfeedViewController
            vc.user = user
            vc.displayMode = .Account
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if cell == logoutCell {
            
            let alertController = UIAlertController(title: "退出账号", message: "真的要退出当前的账号吗？", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            let logoutAction = UIAlertAction(title: "退出", style: .Destructive, handler: {(_) -> () in
                DBController.clearDBForLogout();
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(logoutAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        }
    }

    // MARK: - Navigation

    @IBAction func profileDidFinishEdit(segue: UIStoryboardSegue) {

    }

}

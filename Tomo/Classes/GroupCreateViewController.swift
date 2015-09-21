//
//  GroupCreateViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/11.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class GroupCreateViewController: BaseTableViewController {

    @IBOutlet var groupNameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var stationTextField: UITextField!
    @IBOutlet var introductionTextField: UITextField!
    
    @IBOutlet weak var groupCoverImageView: UIImageView!
    private var cover: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - Actions

extension GroupCreateViewController {
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func create(sender: AnyObject) {
        
        var param = Dictionary<String, AnyObject>()
        
        if self.groupNameTextField.text.length > 0 {
            param["name"] = self.groupNameTextField.text
        } else {
            return
        }
        
        param["introduction"] = self.introductionTextField.text
        param["address"] = self.addressTextField.text
        param["station"] = self.stationTextField.text
        
        let coverName = NSUUID().UUIDString
        let coverPath = NSTemporaryDirectory() + coverName
        
        if let cover = self.cover {
            cover.saveToPath(coverPath)
            param["cover"] = coverName
        }
        
        AlamofireController.request(.POST, "/groups", parameters: param, success: { group in
            
            let groupInfo = GroupEntity(group)
            if let cover = self.cover {
                
                let remotePath =  Constants.groupCoverPath(groupId: groupInfo.id)
                
                let progressView = self.getProgressView()
                
                S3Controller.uploadFile(coverPath, remotePath: remotePath, done: { (error) -> Void in
                    progressView.removeFromSuperview()
                    self.performSegueWithIdentifier("groupCreated", sender: groupInfo)
                    
                }).progress { _, sendBytes, totalBytes in
                    
                    let progress = Float(sendBytes)/Float(totalBytes)
                    
                    gcd.sync(.Main) { () -> () in
                        progressView.progress = progress
                        println(progress)
                        
                    }
                }
            } else {
                self.performSegueWithIdentifier("groupCreated", sender: groupInfo)
            }
            
        }) { err in
            
        }
    }
    
    @IBAction func changeCover(sender: UITapGestureRecognizer) {
        
        let block:CameraController.CameraBlock = { (image,_) ->() in
            
            self.cover = image
            self.groupCoverImageView.image = image
        }
        
        Util.alertActionSheet(self, optionalDict: [
            
            "拍摄":{ (_) -> Void in
                CameraController.sharedInstance.open(self, sourceType: .Camera, completion: block)
            },
            "从相册选择":{ (_) -> () in
                CameraController.sharedInstance.open(self, sourceType: .SavedPhotosAlbum, completion: block)
            }
        ])
    }
}

extension GroupCreateViewController {

    func getProgressView() -> UIProgressView {
        
        let progressView = UIProgressView(frame: CGRectZero)
        progressView.trackTintColor = Util.UIColorFromRGB(0x009688, alpha: 0.1)
        progressView.tintColor = Util.UIColorFromRGB(0x009688, alpha: 1)
        
        self.tableView.tableHeaderView!.addSubview(progressView)
        
        progressView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tableView.tableHeaderView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[progressView(==20)]", options: nil, metrics: nil, views: ["progressView" : progressView]))
        self.tableView.tableHeaderView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressView]|", options: nil, metrics: nil, views: ["progressView" : progressView]))
        return progressView
    }
    
}

// MARK: - UITableView DataSorce

extension GroupCreateViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        if section == 0 {
            return 4
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
}

extension GroupCreateViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) where cell.contentView.subviews.count > 0 {
            
            let views: AnyObject? = cell.contentView.subviews.filter { $0 is UITextView || $0 is UITextField }
            if let views = views as? [UIView], lastView = views.last {
                lastView.becomeFirstResponder()
            }
        }
    }
    
}

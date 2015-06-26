//
//  GroupAddTableViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/23.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupAddTableViewController: BaseTableViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stationLabel: UILabel!
    
    var content: String?
    var imagePath: String?
    
    var group: Group?
    
    var stationTableViewController: StationTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stationLabel.text = DBController.myStations().first?.name
        
        if let group = group {
            self.navigationItem.rightBarButtonItem?.title = "保存"
            
            titleTF.text = group.name
            textView.text = group.detail
            
            if let imagePath = group.cover_ref {
                imageView.sd_setImageWithURL(NSURL(string: imagePath))
            }
            
            textView.textColor = UIColor.blackColor()
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let stationTableViewController = stationTableViewController, station = stationTableViewController.selectedStation {
            stationLabel.text = station.name
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
            stationTableViewController = StationTableViewController()
            stationTableViewController?.displayMode = .SingleSelection
        
            navigationController?.pushViewController(stationTableViewController!, animated: true)
        }
    }

    // MARK: - Action
    
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func addImageTapped(sender: UITapGestureRecognizer) {
//        if group != nil {
//            return
//        }
        
        let atvc = Util.createViewControllerWithIdentifier("AlertTableView", storyboardName: "ActionSheet") as! AlertTableViewController
        
        let cameraAction = AlertTableViewController.tappenDic(title: "写真を撮る",tappen: { (sender) -> () in
            DBCameraController.openCamera(self, delegate: self,isQuad: true)
        })
        let albumAction = AlertTableViewController.tappenDic(title: "写真から選択",tappen: { (sender) -> () in
            DBCameraController.openLibrary(self, delegate: self,isQuad: true)
        })
        atvc.show(self, data: [cameraAction,albumAction])
    }
    
    @IBAction func send(sender: AnyObject) {

        if let group = group {
            var para = Dictionary<String, String>()
            
            para["name"] = titleTF.text
            para["description"] = textView.text
            
            Util.showHUD(maskType: .Clear)
            
            ApiController.editGroup(groupId: group.id!, param: para, done: { (error) -> Void in
                if let path = self.imagePath {
                    ApiController.changeGroupCover(path, groupId: group.id!, done: { (error) -> Void in
                        Util.dismissHUD()
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                } else {
                    Util.dismissHUD()
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })

        } else {
        
            ApiController.createGroup(titleTF.text, content: content, type: .Public, localImagePath: imagePath, stationId: stationTableViewController?.selectedStation?.id, done: { (groupId, error) -> Void in
                if let groupId = groupId, imagePath = self.imagePath {
                    ApiController.changeGroupCover(imagePath, groupId: groupId, done: { (error) -> Void in
                        
                    })
                }
            })
        
            navigationController?.popViewControllerAnimated(true)
        }
    }
}

// MARK: - UITextViewDelegate

extension GroupAddTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if group == nil && (content == nil || content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        content = textView.text
        
//        if content != nil && content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
//            self.navigationItem.rightBarButtonItem?.enabled = true
//        } else {
//            self.navigationItem.rightBarButtonItem?.enabled = false
//        }
    }
}

// MARK: - UITextFieldDelegate

extension GroupAddTableViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        navigationItem.rightBarButtonItem?.enabled = string.length > 0 || textField.text.length - range.length > 0
        
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        navigationItem.rightBarButtonItem?.enabled = textField.text.length > 0
    }

}


// MARK: - UINavigationControllerDelegate

extension GroupAddTableViewController: UINavigationControllerDelegate {
    
    
}
// MARK: - DBCameraViewControllerDelegate

extension GroupAddTableViewController: DBCameraViewControllerDelegate {
    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        
        let name = NSUUID().UUIDString
        imagePath = NSTemporaryDirectory() + name
        
        let newImage = image.normalizedImage()
        
        newImage.saveToPath(imagePath)
        
        cameraViewController.restoreFullScreenMode()
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.imageView.image = newImage
        })
    }
    func dismissCamera(cameraViewController: AnyObject!) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        cameraViewController.restoreFullScreenMode()
    }
}

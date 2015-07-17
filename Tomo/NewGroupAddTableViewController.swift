//
//  NewGroupAddViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/15.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewGroupAddTableViewController: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introductionTextView: UITextView!
    
    var imagePath: String?
    var groupName: String?
    var introduction: String?
    var station: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cancelImage = UIImage(named: "delete_sign") {
            let image = Util.coloredImage(cancelImage, color: UIColor.whiteColor())
            cancelButton?.setImage(image, forState: UIControlState.Normal)
        }
        
        if let photoImage = UIImage(named: "screenshot") {
            let image = Util.coloredImage(photoImage, color: UIColor.whiteColor())
            photoButton?.setImage(image, forState: UIControlState.Normal)
        }
        
        if let createImage = UIImage(named: "checkmark") {
            let image = Util.coloredImage(createImage, color: UIColor.whiteColor())
            createButton?.setImage(image, forState: UIControlState.Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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

extension NewGroupAddTableViewController {
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addImage(sender: AnyObject) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "拍摄", style: .Default, handler: { (_) -> Void in
            DBCameraController.openCamera(self, delegate: self)
        })
        let chooseFromLibraryAction = UIAlertAction(title: "从相册选择", style: .Default, handler: { (_) -> () in
            DBCameraController.openLibrary(self, delegate: self)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func create(sender: AnyObject) {
        
        ApiController.createGroup(nameTextField.text!, content: introduction, type: .Public, localImagePath: imagePath, stationId: nil, done: { (groupId, error) -> Void in
            if let groupId = groupId, imagePath = self.imagePath {
                ApiController.changeGroupCover(imagePath, groupId: groupId, done: { (error) -> Void in
                })
            }
        })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension NewGroupAddTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension NewGroupAddTableViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        groupName = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        createButton.enabled = groupName?.length > 0
        
        return true
    }
}

extension NewGroupAddTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = nil
        textView.textColor = UIColor.blackColor()
    }
    
    func textViewDidChange(textView: UITextView) {
        introduction = textView.text
    }
}

extension NewGroupAddTableViewController: DBCameraViewControllerDelegate {
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

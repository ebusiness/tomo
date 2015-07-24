//
//  NewAccountEditViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewAccountEditViewController: MyAccountBaseController {
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var birthDayTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    var path: String?
    var user:User!
    var isAvatar = true
    var headerView:MyAccountHeaderViewController! // for update image realtime when take a photo
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Util.changeImageColorForButton(saveButton,color: UIColor.whiteColor())
        
        ApiController.getMyInfo({ (error) -> Void in
            if error == nil {
                self.updateUI()
            }
        })
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let vc = segue.destinationViewController as? MyAccountHeaderViewController{
            
            vc.photoImageViewTapped = { (sender)->() in
                
                self.imageViewTapped(true)
            }
            
            vc.coverImageViewTapped = { (sender)->() in
                
                self.imageViewTapped(false)
            }
            self.headerView = vc
        }
        
        if segue.identifier == "segue_save" {
            updateUser()
        }
    }

}

extension NewAccountEditViewController{
    
    func updateUI() {
        
        user = DBController.myUser()
        
        nickNameTextField.text = user.nickName
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        birthDayTextField.text = user.birthDay?.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        genderTextField.text = user.genderText()
        addressTextField.text = user.address
        //        stationLabel.text = (user.stations.array.last as? Station)?.name
        telTextField.text = user.telNo
        bioTextView.text = user.bioText
    }
    
    func updateUser() {
        
        user.nickName = nickNameTextField.text
        user.bioText = bioTextView.text
        user.firstName = firstNameTextField.text
        user.lastName = lastNameTextField.text
        //        user.gender =
        //        user.birthDay =
        user.telNo = telTextField.text
        user.address = addressTextField.text
        
        DBController.save()
        
        ApiController.editUser(user, done: { (error) -> Void in
            
        })
    }
    
    func imageViewTapped(isAvatar:Bool) {
        
        self.isAvatar = isAvatar
        
        Util.alertActionSheet(self, optionalDict: [
            
            "拍摄":{ (_) -> Void in
                DBCameraController.openCamera(self, delegate: self,isQuad: isAvatar)
            },
            "从相册选择":{ (_) -> () in
                DBCameraController.openLibrary(self, delegate: self,isQuad: isAvatar)
            }
            ])
    }
}
    
    
extension NewAccountEditViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
}

// MARK: - DBCameraViewControllerDelegate

extension NewAccountEditViewController: DBCameraViewControllerDelegate {
    
    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        
        let name = NSUUID().UUIDString
        path = NSTemporaryDirectory() + name
        
        let newImage = image.normalizedImage()
        
        newImage.saveToPath(path)
        
        self.presentedViewController?.dismissViewControllerAnimated(false, completion: { () -> Void in
            let remotePath =  self.isAvatar ? Constants.avatarPath(fileName: name) : Constants.coverPath(fileName: name)
            
            S3Controller.uploadFile(name: name, localPath: self.path!, remotePath: remotePath, done: { (error) -> Void in
                #if DEBUG
                    println(error)
                    println("done")
                #endif
                
                if error == nil {
                    if self.isAvatar {
                        ApiController.editAvatarName(name, done: { (error) -> Void in
                            
                            self.headerView.updateUI()
                        })
                    } else {
                        ApiController.editCoverName(name, done: { (error) -> Void in
                            
                            self.headerView.updateUI()
                        })
                    }
                }
            })
        })
    }
    
    func dismissCamera(cameraViewController: AnyObject!) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        cameraViewController.restoreFullScreenMode()
    }
}

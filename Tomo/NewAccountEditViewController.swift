//
//  NewAccountEditViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewAccountEditViewController: UITableViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var birthDayTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    var user: User!
    var path: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.layer.cornerRadius = photoImageView.bounds.width / 2
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.borderWidth = 1
        photoImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        ApiController.getMyInfo({ (error) -> Void in
            if error == nil {
                self.updateUI()
            }
        })
    }
    
    func updateUI() {
        
        user = DBController.myUser()
        
        if let photo_ref = user.photo_ref {
            photoImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
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

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        updateUser()
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
    
    @IBAction func photoImageViewTapped() {
        
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

}

// MARK: - DBCameraViewControllerDelegate

extension NewAccountEditViewController: DBCameraViewControllerDelegate {
    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: AvatarMaxWidth, height: AvatarMaxWidth))
        
        let name = NSUUID().UUIDString
        path = NSTemporaryDirectory() + name
        
        let newImage = image.normalizedImage()
        
        newImage.saveToPath(path)
        
        self.presentedViewController?.dismissViewControllerAnimated(false, completion: { () -> Void in
            let remotePath = Constants.avatarPath(fileName: name)
            
            S3Controller.uploadFile(name: name, localPath: self.path!, remotePath: remotePath, done: { (error) -> Void in
                println(error)
                println("done")
                
                if error == nil {
                    ApiController.editAvatarName(name, done: { (error) -> Void in
                        
                    })
                }
            })
        })
    }
    func dismissCamera(cameraViewController: AnyObject!) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        cameraViewController.restoreFullScreenMode()
    }
}

//
//  AccountEditViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class AccountEditViewController: MyAccountBaseController {
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var genderPicker: UIPickerView!
    
    @IBOutlet weak var birthDayPicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    var path: String?
    var user:User! {
        didSet{
            
            nickNameTextField.text = user.nickName
            firstNameTextField.text = user.firstName
            lastNameTextField.text = user.lastName
//            birthDayTextField.text = user.birthDay?.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
            addressTextField.text = user.address
            //        stationLabel.text = (user.stations.array.last as? Station)?.name
            telTextField.text = user.telNo
            bioTextView.text = user.bioText
            
            if let gender = user.gender {
                
                self.genderPicker.selectRow(user.gender == "男" ? 0 : 1 , inComponent: 0, animated: true)
                
            }
            if let birthDay = user.birthDay {
                
                self.birthDayPicker.setDate(birthDay, animated: true)
                
            }
        }
    }
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
            
            self.updateUser()
            DBController.save()
            
            ApiController.editUser(user, done: { (error) -> Void in
                
            })
        }
    }

}

extension AccountEditViewController{
    
    func updateUI() {
        
        user = DBController.myUser()
    }
    
    func updateUser() {
        
        user.nickName = nickNameTextField.text
        user.bioText = bioTextView.text
        user.firstName = firstNameTextField.text
        user.lastName = lastNameTextField.text
        user.birthDay = self.birthDayPicker.date
        user.telNo = telTextField.text
        user.address = addressTextField.text
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
    
    
extension AccountEditViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
    }
}

// MARK: - DBCameraViewControllerDelegate

extension AccountEditViewController: DBCameraViewControllerDelegate {
    
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

extension AccountEditViewController:UIPickerViewDelegate{
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        
        if pickerView == genderPicker {
            var pickerLabel:UILabel!
            
            if let label = view as? UILabel {
                
                pickerLabel = label
                
            } else {
                
                pickerLabel = UILabel()
                
            }
            
            pickerLabel.textAlignment = .Right
            pickerLabel.font = UIFont.systemFontOfSize(14)
            pickerLabel.text = row == 0 ? "男" : "女"
            
            return pickerLabel
        }
        
        return view
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        user.gender = row == 0 ? "男" : "女"
    }
}

extension AccountEditViewController:UIPickerViewDataSource{
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == genderPicker {
            return 2
        }
        return 0
    }
    
    
}

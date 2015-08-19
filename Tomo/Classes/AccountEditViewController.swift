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
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    var user:UserEntity! {
        didSet{
            
            nickNameTextField.text = user.nickName
            
            if let bio = user.bio where bio.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                bioTextView.text = bio
            }
            
            if let lastName = user.lastName {
                lastNameTextField.text = lastName.trimmed()
            }
            
            if let firstName = user.firstName {
                firstNameTextField.text = firstName.trimmed()
            }
            
            genderLabel.text = user.gender ?? "男"
            
            if let birthDay = user.birthDay {
                birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
            }
            
            if let telNo = user.telNo {
                telTextField.text = telNo
            }
            
            if let address = user.address {
                addressTextField.text = address.trimmed()
            }
        }
    }
    var isAvatar = true
    var headerView:MyAccountHeaderViewController! // for update image realtime when take a photo
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Util.changeImageColorForButton(saveButton,color: UIColor.whiteColor())
        
        self.user =  me
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        
        if segue.identifier == "segue_save" {

            self.updateUser()
            
        } else if segue.identifier == "gender_picker" {
            
            let vc = segue.destinationViewController as! PickerTableViewController
            
            vc.pickerData = ["男","女"]
            vc.selected = self.user.gender
            vc.didSelected = { (selected)->() in
                self.genderLabel.text = selected
                self.user.gender = selected
                self.updateUser()
            }
            
        } else if segue.identifier == "birthday_picker" {
            
            let vc = segue.destinationViewController as! DatePickerViewController
            vc.date = user.birthDay
            
            vc.didSelected = { (selected)->() in
                self.birthDayLabel.text = selected.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
                self.user.birthDay = selected
                self.updateUser()
            }
        
        } else if let vc = segue.destinationViewController as? MyAccountHeaderViewController{
                
                vc.photoImageViewTapped = { (sender)->() in
                    
                    self.imageViewTapped(true)
                }
                
                vc.coverImageViewTapped = { (sender)->() in
                    
                    self.imageViewTapped(false)
                }
                self.headerView = vc
        }
    }
    
    
    override func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "tomoid": "tomoid",
            "nickName": "nickName",
            "gender": "gender",
            "photo_ref": "photo",
            "cover_ref": "cover",
            "bioText": "bio",
            "firstName": "firstName",
            "lastName": "lastName",
            "birthDay": "birthDay",
            "telNo": "telNo",
            "address": "address",
            ])
        // edit user
        let responseDescriptor = RKResponseDescriptor(mapping: userMapping, method: .PATCH, pathPattern: "/users/:id", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptor)
        
        
        let inverseMapping = userMapping.inverseMapping()
        inverseMapping.addAttributeMappingsFromDictionary(["photo":"photo","cover":"cover"])

        let requestDescriptor = RKRequestDescriptor(mapping: inverseMapping, objectClass: UserEntity.self, rootKeyPath: nil, method: RKRequestMethod.Any)
        self.manager.addRequestDescriptor(requestDescriptor)
    }

}

extension AccountEditViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) where cell.subviews.count > 0 {
            
            let views: AnyObject? = cell.subviews[0].subviews.filter { $0 is UITextView || $0 is UITextField }
            if let views = views as? [UIView], lastView = views.last {
                lastView.becomeFirstResponder()
            }
        }
    }
    
}

extension AccountEditViewController: UITextViewDelegate {
    var defaultbio:String {
        get {
            return "一个彰显个性的签名"
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == defaultbio {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.markedTextRange == nil {
            let max = self.getMaxLength(textView)
            if textView.text.length > max {
                textView.text = textView.text.substringToIndex(advance(textView.text.startIndex, max))
            }
            
            self.setLengthToLabel(textView)
            
        }
    }
}

extension AccountEditViewController:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if NSStringFromClass(touch.view.classForCoder) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
    
}

extension AccountEditViewController {
    
    @IBAction func textFieldDidChange(sender: UITextField) {
        
        if sender.markedTextRange == nil {
            let max = self.getMaxLength(sender)
            if sender.text.length > max {
                sender.text = sender.text.substringToIndex(advance(sender.text.startIndex, max))
            }
            
            self.setLengthToLabel(sender)
        }
    }
    
    @IBAction func tableTapped(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
    
    func updateUser(){
        
        user.nickName = nickNameTextField.text
        user.bio = bioTextView.text
        user.firstName = firstNameTextField.text
        user.lastName = lastNameTextField.text
        user.telNo = telTextField.text
        user.address = addressTextField.text
        
        self.manager.patchObject(user, path: "/users/\(me.id)", parameters: nil, success: { (operation, result) -> Void in
            if let result = result.firstObject as? UserEntity {
                me = result
                self.user = result
                self.headerView.updateUI()
            }
            
            }, failure: { (operation, error) -> Void in
                
        })
    }
}

extension AccountEditViewController {
    
    func getMaxLength(inputView: UIView) -> Int{
        
        let views = inputView.superview?.subviews.filter { $0 is UILabel && $0.tag == 2 }
        
        if let views = views, label = views.last as? UILabel ,count = label.text?.toInt(){
            return count
        }
        
        return Int.max
    }

    func setLengthToLabel(inputView: UIView){
        let views = inputView.superview?.subviews.filter { $0 is UILabel && $0.tag == 1 }
        
        if let views = views, label = views.last as? UILabel {
            var textCount = 0
            if let inputView = inputView as? UITextView {
                textCount = (inputView.text ?? "" ).length
            } else if let inputView = inputView as? UITextField {
                textCount = (inputView.text ?? "" ).length
            }
            label.text = toString( textCount )
        }
    }
    
}

// MARK: - DBCameraViewControllerDelegate

extension AccountEditViewController: DBCameraViewControllerDelegate {
    
    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        
        let name = NSUUID().UUIDString
        let path = NSTemporaryDirectory() + name
        
        let newImage = image.normalizedImage()
        
        newImage.saveToPath(path)
        
        self.presentedViewController?.dismissViewControllerAnimated(false, completion: { () -> Void in
            let remotePath =  self.isAvatar ? Constants.avatarPath(fileName: name) : Constants.coverPath(fileName: name)
            
            S3Controller.uploadFile(name: name, localPath: path, remotePath: remotePath, done: { (error) -> Void in
                #if DEBUG
                    println(error)
                    println("done")
                #endif
                
                if error == nil {
                    if self.isAvatar {
                        self.user.photo = name
                    } else {
                        self.user.cover = name
                    }
                    self.updateUser()
                }
            })
        })
    }
    
    func dismissCamera(cameraViewController: AnyObject!) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        cameraViewController.restoreFullScreenMode()
    }
}

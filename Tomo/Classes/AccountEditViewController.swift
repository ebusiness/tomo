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
            self.setLengthToLabel(nickNameTextField)
            
            if let bio = user.bio where bio.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                bioTextView.text = bio
                bioTextView.textColor = UIColor.blackColor()
                self.setLengthToLabel(bioTextView)
            }
            
            if let lastName = user.lastName {
                lastNameTextField.text = lastName.trimmed()
                self.setLengthToLabel(lastNameTextField)
            }
            
            if let firstName = user.firstName {
                firstNameTextField.text = firstName.trimmed()
                self.setLengthToLabel(firstNameTextField)
            }
            
            genderLabel.text = user.gender ?? "男"
            
            if let birthDay = user.birthDay {
                birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
            }
            
            if let telNo = user.telNo {
                telTextField.text = telNo
                self.setLengthToLabel(telTextField)
            }
            
            if let address = user.address {
                addressTextField.text = address.trimmed()
                self.setLengthToLabel(addressTextField)
            }
        }
    }
    
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
}

extension AccountEditViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) where cell.contentView.subviews.count > 0 {
            
            let views: AnyObject? = cell.contentView.subviews.filter { $0 is UITextView || $0 is UITextField }
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
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.trimmed().length == 0 {
            
            textView.textColor = UIColor.lightGrayColor()
            textView.text = defaultbio
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
        
        let block:CameraController.CameraBlock = { (image,_) ->() in
            let image = image!.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
            
            let name = NSUUID().UUIDString
            let path = NSTemporaryDirectory() + name
            image.saveToPath(path)
            
            let remotePath =  isAvatar ? Constants.avatarPath(fileName: name) : Constants.coverPath(fileName: name)
            
            S3Controller.uploadFile(name: name, localPath: path, remotePath: remotePath, done: { (error) -> Void in
                #if DEBUG
                    println(error)
                    println("done")
                #endif
                
                if error == nil {
                    if isAvatar {
                        self.user.photo = name
                    } else {
                        self.user.cover = name
                    }
                    self.updateUser()
                }
            })

        }
        
        Util.alertActionSheet(self, optionalDict: [
            
            "拍摄":{ (_) -> Void in
                CameraController.sharedInstance.open(self, sourceType: .Camera, allowsEditing: isAvatar, completion: block)
            },
            "从相册选择":{ (_) -> () in
                CameraController.sharedInstance.open(self, sourceType: .SavedPhotosAlbum, allowsEditing: isAvatar, completion: block)
            }
            ])
    }
    
    func updateUser(){
        var params = Dictionary<String,AnyObject>()
        
        if nickNameTextField.text != me.nickName {
            params["nickName"] = nickNameTextField.text
        }
        
        if firstNameTextField.text != me.firstName ?? "" {
            params["firstName"] = firstNameTextField.text
        }
        
        if lastNameTextField.text != me.lastName ?? "" {
            params["lastName"] = lastNameTextField.text
        }
        
        if telTextField.text != me.telNo ?? "" {
            params["telNo"] = telTextField.text
        }
        
        if addressTextField.text != me.address ?? "" {
            params["address"] = addressTextField.text
        }
        
        if bioTextView.textColor == UIColor.blackColor() || bioTextView.text != defaultbio {
            if bioTextView.text != me.bio ?? "" {
                params["bio"] = bioTextView.text
            }
        }
        
        if user.gender != me.gender {
            params["gender"] = user.gender
        }
        
        if user.birthDay != me.birthDay {
            params["birthDay"] = user.birthDay
        }
        
        if user.photo != me.photo {
            params["photo"] = user.photo
        }
        
        if user.cover != me.cover {
            params["cover"] = user.cover
        }
        
        if params.count > 0 {
            AlamofireController.request(.PATCH, "/me", parameters: params, success: { result in
                me = UserEntity(result)
                self.user = me
                self.headerView.updateUI()
            }) { err in
                    
            }
        }
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
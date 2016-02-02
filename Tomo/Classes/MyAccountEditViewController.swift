//
//  MyAccountEditViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class MyAccountEditViewController: UITableViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var nickNameTextField: UITextField!

    @IBOutlet weak var bioTextView: UITextView!

    @IBOutlet weak var lastNameTextField: UITextField!

    @IBOutlet weak var firstNameTextField: UITextField!

    @IBOutlet weak var genderLabel: UILabel!

    @IBOutlet weak var birthDayLabel: UILabel!

    @IBOutlet weak var telTextField: UITextField!

    @IBOutlet weak var addressTextField: UITextField!

    @IBOutlet weak var saveButton: UIBarButtonItem!

    let placeholderBio = "个性签名（20个字以内）"
    let placeholderSelect = "未选择"

    var inputCover = me.cover
    var inputAvatar = me.photo
    var inputGender = me.gender
    var inputBirthDay = me.birthDay

    let headerHeight = TomoConst.UI.ScreenHeight * 0.382 - 58
    let headerViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.ScreenHeight * 0.382 + 58)

    override func viewDidLoad() {

        super.viewDidLoad()

        self.configDisplay()
    }

    override func viewWillDisappear(animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "UpdateFinished" {

            self.updateUser()
            
        } else if segue.identifier == "gender_picker" {
            
            let vc = segue.destinationViewController as! PickerTableViewController
            vc.selected = me.gender

            vc.didSelected = {
                self.genderLabel.text = $0
                self.inputGender = $0
            }
            
        } else if segue.identifier == "birthday_picker" {
            
            let vc = segue.destinationViewController as! DatePickerViewController
            vc.date = me.birthDay
            
            vc.didSelected = {
                self.birthDayLabel.text = $0.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
                self.inputBirthDay = $0
            }
        }
    }
}

// MARK: - UITableView delegate

extension MyAccountEditViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if let cell = tableView.cellForRowAtIndexPath(indexPath) where cell.contentView.subviews.count > 0 {
            
            let views: AnyObject? = cell.contentView.subviews.filter { $0 is UITextView || $0 is UITextField }
            if let views = views as? [UIView], lastView = views.last {
                lastView.becomeFirstResponder()
            }
        }
    }
}

// MARK: - UITextView delegate

extension MyAccountEditViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text != self.placeholderBio { return }
        textView.text = ""
        textView.textColor = UIColor.blackColor()
    }
    
    func textViewDidChange(textView: UITextView) {

        guard textView.markedTextRange == nil else { return }

        let maxLengthBio = 20

        if textView.text.length > maxLengthBio {
            textView.text = textView.text[0 ..< maxLengthBio]
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {

        guard textView.text.trimmed().length != 0 else { return }
        
        textView.textColor = TomoConst.UI.PlaceHolderColor
        textView.text = self.placeholderBio
    }
}

extension MyAccountEditViewController:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {

        if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
}

// MARK: UIScrollView Delegate

extension MyAccountEditViewController {

    override func scrollViewDidScroll(scrollView: UIScrollView) {

        self.configNavigationBarByScrollPosition()
    }
}


// MARK: - Actions

extension MyAccountEditViewController {
    
    @IBAction func textFieldDidChange(sender: UITextField) {

        guard sender.markedTextRange == nil else { return }

        var maxLength = 0

        switch sender.tag {
        case 1:
            maxLength = 12
        case 2, 3:
            maxLength = 3
        case 4:
            maxLength = 13
        case 5:
            maxLength = 20
        default:
            break
        }

        if sender.text!.length > maxLength {
            sender.text = sender.text![0 ..< maxLength]
        }
    }
    
    @IBAction func tableTapped(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func coverTapped(sender: UITapGestureRecognizer) {

        let block:CameraController.CameraBlock = { image, _ in

            guard let image = image else { return }

            let (filePath, fileName) = self.saveImage(image)

            S3Controller.uploadFile(filePath, remotePath: Constants.coverPath(), done: { error in

                guard error == nil else {
                    #if DEBUG
                        print(error)
                        print("done")
                    #endif
                    return
                }

                if let cover = me.cover {
                    SDImageCache.sharedImageCache().removeImageForKey(cover)
                }

                self.inputCover = fileName
                self.updateUser()
            })
        }

        Util.alertActionSheet(self, optionalDict: [

            "拍摄":{ (_) -> Void in
                CameraController.sharedInstance.open(self, sourceType: .Camera, allowsEditing: false, completion: block)
            },
            "从相册选择":{ (_) -> () in
                CameraController.sharedInstance.open(self, sourceType: .SavedPhotosAlbum, allowsEditing: false, completion: block)
            }
        ])
    }

    @IBAction func avatarTapped(sender: UITapGestureRecognizer) {

        let block:CameraController.CameraBlock = { image, _ in

            guard let image = image else { return }

            let (filePath, fileName) = self.saveImage(image)

            S3Controller.uploadFile(filePath, remotePath: Constants.avatarPath(), done: { error in

                guard error == nil else {
                    #if DEBUG
                        print(error)
                        print("done")
                    #endif
                    return
                }

                if let photo = me.photo {
                    SDImageCache.sharedImageCache().removeImageForKey(photo)
                }

                self.inputAvatar = fileName
                self.updateUser()

            })

        }

        Util.alertActionSheet(self, optionalDict: [

            "拍摄":{ (_) -> Void in
                CameraController.sharedInstance.open(self, sourceType: .Camera, allowsEditing: true, completion: block)
            },
            "从相册选择":{ (_) -> () in
                CameraController.sharedInstance.open(self, sourceType: .SavedPhotosAlbum, allowsEditing: true, completion: block)
            }
        ])
    }

}

// MARK: - Internal methods

extension MyAccountEditViewController {

    private func configDisplay() {

        // give the avatar white border
        self.avatarImageView.layer.borderWidth = 2
        self.avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: self.headerViewSize)

        if let cover = me.cover {
            self.coverImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: TomoConst.Image.DefaultCover)
        }

        if let avatar = me.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: avatar), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.nickNameTextField.text = me.nickName

        if let bio = me.bio where bio.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.bioTextView.text = bio
            self.bioTextView.textColor = UIColor.blackColor()
        }

        if let lastName = me.lastName {
            self.lastNameTextField.text = lastName.trimmed()
        }

        if let firstName = me.firstName {
            self.firstNameTextField.text = firstName.trimmed()
        }

        if let gender = me.gender {
            self.genderLabel.text = gender
            self.genderLabel.textColor = UIColor.blackColor()
        }

        if let birthDay = me.birthDay {
            self.birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
            self.birthDayLabel.textColor = UIColor.blackColor()
        }

        if let telNo = me.telNo {
            self.telTextField.text = telNo
        }

        if let address = me.address {
            self.addressTextField.text = address.trimmed()
        }
    }

    private func updateUser(){

        var parameters = Router.Setting.MeParameter()

        if self.nickNameTextField.text != me.nickName {
            parameters.nickName = nickNameTextField.text!
        }

        if self.firstNameTextField.text != me.firstName ?? "" {
            parameters.firstName = firstNameTextField.text!
        }

        if self.lastNameTextField.text != me.lastName ?? "" {
            parameters.lastName = lastNameTextField.text!
        }

        if self.telTextField.text != me.telNo ?? "" {
            parameters.telNo = telTextField.text!
        }

        if self.addressTextField.text != me.address ?? "" {
            parameters.address = addressTextField.text!
        }

        if self.bioTextView.textColor == UIColor.blackColor() || bioTextView.text != self.placeholderBio {
            if self.bioTextView.text != me.bio ?? "" {
                parameters.bio = bioTextView.text!
            }
        }

        if self.inputGender != me.gender  {
            parameters.gender = self.inputGender
        }

        if self.inputBirthDay != me.birthDay {
            parameters.birthDay = self.inputBirthDay
        }

        if self.inputAvatar != me.photo {
            parameters.photo = self.inputAvatar
        }

        if self.inputCover != me.cover {
            parameters.cover = self.inputCover
        }

        guard parameters.getParameters() != nil else { return }

        Router.Setting.UpdateUserInfo(parameters: parameters).response {
            if $0.result.isFailure { return }
            me = Account($0.result.value!)
            self.configDisplay()
        }
    }

    private func saveImage(image: UIImage) -> (filePath: String, fileName: String) {

        let tempImage = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        let name = NSUUID().UUIDString
        let path = NSTemporaryDirectory() + name
        tempImage.saveToPath(path)

        return (path, name)
    }

    private func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > self.headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = self.headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }

}
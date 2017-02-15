//
//  MyAccountEditViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

final class MyAccountEditViewController: UITableViewController {

    @IBOutlet weak fileprivate var coverImageView: UIImageView!

    @IBOutlet weak fileprivate var avatarImageView: UIImageView!

    @IBOutlet weak fileprivate var nickNameTextField: UITextField!

    @IBOutlet weak fileprivate var bioTextView: UITextView!

    @IBOutlet weak fileprivate var lastNameTextField: UITextField!

    @IBOutlet weak fileprivate var firstNameTextField: UITextField!

    @IBOutlet weak fileprivate var genderLabel: UILabel!

    @IBOutlet weak fileprivate var birthDayLabel: UILabel!

    @IBOutlet weak fileprivate var telTextField: UITextField!

    @IBOutlet weak fileprivate var addressTextField: UITextField!

    @IBOutlet weak fileprivate var saveButton: UIBarButtonItem!

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

    override func viewWillDisappear(_ animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "UpdateFinished" {

            self.updateUser()

        } else if segue.identifier == "gender_picker" {

            let vc = segue.destination as? PickerTableViewController
            vc?.selected = me.gender

            vc?.didSelected = {
                self.genderLabel.text = $0
                self.inputGender = $0
            }

        } else if segue.identifier == "birthday_picker" {

            let vc = segue.destination as? DatePickerViewController
            vc?.date = me.birthDay

            vc?.didSelected = {
                self.birthDayLabel.text = $0.toString(dateStyle: .medium, timeStyle: .none)
                self.inputBirthDay = $0
            }
        }
    }
}

// MARK: - UITableView delegate

extension MyAccountEditViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let cell = tableView.cellForRow(at: indexPath), !cell.contentView.subviews.isEmpty {

            let views: Any? = cell.contentView.subviews.filter { $0 is UITextView || $0 is UITextField }
            if let views = views as? [UIView], let lastView = views.last {
                lastView.becomeFirstResponder()
            }
        }
    }
}

// MARK: - UITextView delegate

extension MyAccountEditViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text != self.placeholderBio { return }
        textView.text = ""
        textView.textColor = UIColor.black
    }

    func textViewDidChange(_ textView: UITextView) {

        guard textView.markedTextRange == nil else { return }

        let maxLengthBio = 20

        if textView.text.characters.count > maxLengthBio {
            textView.text = textView.text.substring(with: 0 ..< maxLengthBio)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        guard !textView.text.trimmed().isEmpty else { return }

        textView.textColor = TomoConst.UI.PlaceHolderColor
        textView.text = self.placeholderBio
    }
}

extension MyAccountEditViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
}

// MARK: UIScrollView Delegate

extension MyAccountEditViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        self.configNavigationBarByScrollPosition()
    }
}

// MARK: - Actions

extension MyAccountEditViewController {

    @IBAction func textFieldDidChange(_ sender: UITextField) {

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

        if sender.text!.characters.count > maxLength {
            sender.text = sender.text!.substring(with: 0 ..< maxLength)
        }
    }

    @IBAction func tableTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func coverTapped(_ sender: UITapGestureRecognizer) {

        let block: CameraController.CameraBlock = { image, _ in

            guard let image = image else { return }

            let (filePath, fileName) = self.saveImage(image: image)

            S3Controller.uploadFile(localPath: filePath, remotePath: Constants.coverPath(), done: { error in

                guard error == nil else {
                    #if DEBUG
                        print(error ?? "no error?")
                        print("done")
                    #endif
                    return
                }

                if let cover = me.cover {
                    SDImageCache.shared().removeImage(forKey: cover)
                }

                self.inputCover = fileName
                self.updateUser()
            })
        }

        Util.alertActionSheet(parentvc: self, optionalDict: [

            "拍摄": { (_) -> Void in
                CameraController.sharedInstance.open(vc: self, sourceType: .camera, allowsEditing: false, completion: block)
            },
            "从相册选择": { (_) -> () in
                CameraController.sharedInstance.open(vc: self, sourceType: .savedPhotosAlbum, allowsEditing: false, completion: block)
            }
        ])
    }

    @IBAction func avatarTapped(_ sender: UITapGestureRecognizer) {

        let block: CameraController.CameraBlock = { image, _ in

            guard let image = image else { return }

            let (filePath, fileName) = self.saveImage(image: image)

            S3Controller.uploadFile(localPath: filePath, remotePath: Constants.avatarPath(), done: { error in

                guard error == nil else {
                    #if DEBUG
                        print(error ?? "no error?")
                        print("done")
                    #endif
                    return
                }

                if let photo = me.photo {
                    SDImageCache.shared().removeImage(forKey: photo)
                }

                self.inputAvatar = fileName
                self.updateUser()

            })

        }

        Util.alertActionSheet(parentvc: self, optionalDict: [

            "拍摄": { (_) -> Void in
                CameraController.sharedInstance.open(vc: self, sourceType: .camera, allowsEditing: true, completion: block)
            },
            "从相册选择": { (_) -> () in
                CameraController.sharedInstance.open(vc: self, sourceType: .savedPhotosAlbum, allowsEditing: true, completion: block)
            }
        ])
    }

}

// MARK: - Internal methods

extension MyAccountEditViewController {

    fileprivate func configDisplay() {

        // give the avatar white border
        self.avatarImageView.layer.borderWidth = 2
        self.avatarImageView.layer.borderColor = UIColor.white.cgColor

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: self.headerViewSize)

        if let cover = me.cover {
            self.coverImageView.sd_setImage(with: URL(string: cover), placeholderImage: TomoConst.Image.DefaultCover)
        }

        if let avatar = me.photo {
            self.avatarImageView.sd_setImage(with: URL(string: avatar), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.nickNameTextField.text = me.nickName

        if let bio = me.bio, bio.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            self.bioTextView.text = bio
            self.bioTextView.textColor = UIColor.black
        }

        if let lastName = me.lastName {
            self.lastNameTextField.text = lastName.trimmed()
        }

        if let firstName = me.firstName {
            self.firstNameTextField.text = firstName.trimmed()
        }

        if let gender = me.gender {
            self.genderLabel.text = gender
            self.genderLabel.textColor = UIColor.black
        }

        if let birthDay = me.birthDay {
            self.birthDayLabel.text = birthDay.toString(dateStyle: .medium, timeStyle: .none)
            self.birthDayLabel.textColor = UIColor.black
        }

        if let telNo = me.telNo {
            self.telTextField.text = telNo
        }

        if let address = me.address {
            self.addressTextField.text = address.trimmed()
        }
    }

    fileprivate func updateUser() {

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

        if self.bioTextView.textColor == UIColor.black || bioTextView.text != self.placeholderBio {
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

            // TODO: this is wrong! 'me' was completly replaced by new object!
            // and everyObserver listening on the replaced 'me' will fail !!!!
            me = Account($0.result.value!)

            me.editProfile()
            self.configDisplay()
        }
    }

    fileprivate func saveImage(image: UIImage) -> (filePath: String, fileName: String) {

        let tempImage = image.scaleToFitSize(CGSize(width: maxWidth, height: maxWidth))
        let name = NSUUID().uuidString
        let path = NSTemporaryDirectory() + name
        tempImage?.save(toPath: path)

        return (path, name)
    }

    fileprivate func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > self.headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = self.headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(rgbValue: 0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }

}

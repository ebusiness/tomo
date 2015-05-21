//
//  AccountEditViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/22.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class AccountEditViewController: BaseTableViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var siteTF: UITextField!
    @IBOutlet weak var telTF: UITextField!
    @IBOutlet weak var profileLabelLeft: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    
    @IBOutlet weak var avatarCell: UITableViewCell!
    @IBOutlet weak var stationCell: UITableViewCell!
    
    var user: User!
    var path: String?
    
    var textViewInputVC: TextViewInputViewController?
    var stationTableViewController: StationTableViewController?
    
    var readOnlyMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        
        if readOnlyMode {
            if DBController.isInvitedUser(user) || DBController.isFriend(user) {
                logoutLabel.text = "追加済み"
            } else if user.id == Defaults["myId"].string {
                logoutLabel.text = "本人"
            } else {
                logoutLabel.text = "追加"
            }
            self.navigationItem.rightBarButtonItem = nil;
            avatarCell.accessoryType = .None
            stationCell.accessoryType = .None
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        
        ApiController.getUserInfo(user.id!, done: { (error) -> Void in
            if error == nil {
                self.updateUI()
            }
        })
    }
    
    func updateUI() {
        if user == nil {
            user = DBController.myUser()
        }
        
        if let vc = textViewInputVC {
            tableView.reloadData()
            
            DBController.save()
            
            ApiController.editUser(user, done: { (error) -> Void in
                
            })
            
            textViewInputVC = nil
            
            return
        }
        
        if let stationTableViewController = stationTableViewController, station = stationTableViewController.selectedStation {
            user.nearestSt = station.name
            
            DBController.save()
            ApiController.editUser(user, done: { (error) -> Void in
                
            })
        }
        
        if let path = path {
            userImage.image = UIImage(contentsOfFile: path)
        } else if let photo_ref = user.photo_ref {
            userImage.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
        //名前
        nameTF.text = user.fullName()
        //誕生日
        birthdayLabel.text = user.birthDay?.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        
        //性別
        sexLabel.text = user.gender
        //住所
        addressTF.text = user.address
        //駅
        stationLabel.text = user.nearestSt
        //個人サイト
        siteTF.text = user.webSite
        //Tel
        telTF.text = user.telNo
        //自己紹介
        profileLabel.text = user.bioText
        idLabel.text = user.tomoid
    }
    
    func updateUser() {
        let fullName = nameTF.text
        let names = fullName.componentsSeparatedByString(" ")
        if names.count > 1 {
            user.firstName = names[0]
            user.lastName = names[1]
        } else {
            user.firstName = fullName
            user.lastName = ""
        }
        
        user.address = addressTF.text
        user.nearestSt = stationLabel.text
        user.webSite = siteTF.text
        user.telNo = telTF.text
        user.bioText = profileLabel.text
        
        DBController.save()
        
        ApiController.editUser(user, done: { (error) -> Void in
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueBioEdit" {
            textViewInputVC = segue.destinationViewController as? TextViewInputViewController
            textViewInputVC?.user = user
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return !readOnlyMode
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            let vc = Util.createViewControllerWithIdentifier("NewsfeedViewController", storyboardName: "Newsfeed") as! NewsfeedViewController
            vc.user = user
            vc.displayMode = .Account
            
            if readOnlyMode {
                vc.displayMode = .User
            }
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if readOnlyMode {
            if indexPath.section != 3 {
                return
            }
            
            if DBController.isFriend(user) || DBController.isInvitedUser(user) {
                return
            }
            
            if user.id == Defaults["myId"].string {
                return
            }
            
            logoutLabel.text = "追加済み"
            ApiController.invite(user.id!, done: { (error) -> Void in
                if error == nil {
                    Util.showSuccess("友達追加リクエストを送信しました。")
                }
            })
            
            return
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            let atvc = Util.createViewControllerWithIdentifier("AlertTableView", storyboardName: "ActionSheet") as! AlertTableViewController
            
            let cameraAction = AlertTableViewController.tappenDic(title: "写真を撮る",tappen: { (sender) -> () in
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                picker.allowsEditing = true
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            })
            let albumAction = AlertTableViewController.tappenDic(title: "写真から選択",tappen: { (sender) -> () in
                let picker = UIImagePickerController()
                picker.sourceType = .PhotoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            })
            atvc.show(self, data: [cameraAction,albumAction])
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            nameTF.becomeFirstResponder()
        }
        
        // MARK: - 誕生日
        if indexPath.section == 2 && indexPath.row == 0 {
            ActionSheetDatePicker.showPickerWithTitle("誕生日", datePickerMode: .Date, selectedDate: user.birthDay ?? kBirthdayDefault, minimumDate: kBirthdayMin, maximumDate: kBirthdayMax, doneBlock: { (picker, selectedDate, origin) -> Void in
                self.user.birthDay = (selectedDate as! NSDate)
                
                DBController.save()
                
                self.birthdayLabel.text = self.user.birthDay?.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
                
                ApiController.editUser(self.user, done: { (error) -> Void in
                    
                })
            }, cancelBlock: nil, origin: view)
        }
        
        // MARK: - 性別
        if indexPath.section == 2 && indexPath.row == 1 {
            let rows = ["男","女"]
            var initRow = 0
            if let gender = user.gender {
                initRow = find(rows, gender) ?? 0
            }
            
            ActionSheetStringPicker.showPickerWithTitle("性別", rows: rows, initialSelection: initRow, doneBlock: { (picker, index, value) -> Void in
                self.user.gender = (value as! String)
                
                self.sexLabel.text = self.user.gender
                
                DBController.save()
                
                ApiController.editUser(self.user, done: { (error) -> Void in
                    
                })
                
            }, cancelBlock: nil, origin: view)
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 2 {
                addressTF.becomeFirstResponder()
            }
            
            if indexPath.row == 3 {
                if stationTableViewController == nil {
                    stationTableViewController = storyboard?.instantiateViewControllerWithIdentifier("StationTableViewController") as? StationTableViewController
                    stationTableViewController?.selectedStation = DBController.myStation()
                }
                
                navigationController?.pushViewController(stationTableViewController!, animated: true)
            }
            
            if indexPath.row == 4 {
                siteTF.becomeFirstResponder()
            }
            
            if indexPath.row == 5 {
                telTF.becomeFirstResponder()
            }
        }
        
        if indexPath.section == 3 {
            
            let acvc = Util.createViewControllerWithIdentifier("AlertConfirmView", storyboardName: "ActionSheet") as! AlertConfirmViewController
            
            acvc.show(self, content: "ログアウトしますか。", action: { () -> () in                
                DBController.clearDBForLogout();
                
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                
                Util.changeRootViewController(from: self, to: main)
            })
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 6 {
            return heightForBioCell(tableView.bounds.width)
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func heightForBioCell(width: CGFloat) -> CGFloat {
        let labelWidth = width - 20 - 15 - CGRectGetMaxX(profileLabelLeft.frame)
        
        profileLabel.text = user.bioText
        
        let maxSize = CGSize(width: labelWidth, height: .max)
        return max(44, 8 + 8 + profileLabel.sizeThatFits(maxSize).height + 1)
    }
}

// MARK: - UITextFieldDelegate

extension AccountEditViewController: UITextFieldDelegate {
    
    // When clicking on the field, use this method.
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if readOnlyMode {
            return false
        }
        
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        
        // Setup the buttons to be put in the system.
        
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("endEditingNow"))
        var toolbarButtons = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil), item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        textField.inputAccessoryView = keyboardDoneButtonView
        
        return true
    }
    
    func endEditingNow(){
        self.view.endEditing(true)
        updateUser()
    }
    
}

// MARK: - UINavigationControllerDelegate

extension AccountEditViewController: UINavigationControllerDelegate {
    
    
}

// MARK: - UIImagePickerControllerDelegate

extension AccountEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: AvatarMaxWidth, height: AvatarMaxWidth))
        
        let name = NSUUID().UUIDString
        path = NSTemporaryDirectory() + name
        
        let newImage = image.normalizedImage()
        
        newImage.saveToPath(path)
        
        picker.dismissViewControllerAnimated(false, completion: { () -> Void in
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
}

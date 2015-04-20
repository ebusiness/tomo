//
//  AccountEditViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/22.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum EditKey: String {
    case Name = "名前"
}

class AccountEditViewController: UITableViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var siteTF: UITextField!
    @IBOutlet weak var telTF: UITextField!
    @IBOutlet weak var profileLabelLeft: UILabel!
    
    var user: User!
    var path: String?
    
    var editKeyAtIndexPath = Dictionary<NSIndexPath, EditKey>()
    
    @IBOutlet weak var birthdayLabel: UILabel!
//    var nameEditVC: AccountNameEditTableViewController?
//    var genderSelectVC: GenderSelectViewController?
    
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var profileLabel: UILabel!
    
    @IBOutlet weak var bioCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = DBController.myUser()
        profileLabel.text = user.bioText
        
        editKeyAtIndexPath[NSIndexPath(forRow: 1, inSection: 0)] = .Name
        
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        
        idLabel.text = Defaults["email"].string

//        sexLabel.text =
//        stationLabel.text = 
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        
        ApiController.getUserInfo(Defaults["myId"].string!, done: { (error) -> Void in
            if error == nil {
                self.updateUI()
            }
        })
    }
    
    func updateUI() {
        user = DBController.myUser()
        
        if let path = path {
            userImage.image = UIImage(contentsOfFile: path)
        } else if let photo_ref = user.photo_ref {
            userImage.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
        //名前
        nameTF.text = user.fullName()
        //誕生日
        birthdayLabel.text = user.birthDay?.toString()
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "SegueNameEdit" {
//            nameEditVC = segue.destinationViewController as? AccountNameEditTableViewController
//            nameEditVC?.user = user
//        }
//        
//        if segue.identifier == "SegueGender" {
//            let vc = segue.destinationViewController as GenderSelectViewController
//            vc.user = user
//        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cameraAction = UIAlertAction(title: "写真を撮る", style: .Default, handler: { (action) -> Void in
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                picker.allowsEditing = true
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            })
            let albumAction = UIAlertAction(title: "写真から選択", style: .Default, handler: { (action) -> Void in
                let picker = UIImagePickerController()
                picker.sourceType = .PhotoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (action) -> Void in
                
            })
            
            alertController.addAction(cameraAction)
            alertController.addAction(albumAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            nameTF.becomeFirstResponder()
        }
        
        if indexPath.section == 2 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let logoutAction = UIAlertAction(title: "ログアウト", style: .Destructive, handler: { (action) -> Void in
                
                Defaults["shouldAutoLogin"] = false
                
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                
                Util.changeRootViewController(from: self, to: main)
            })

            let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (action) -> Void in
                
            })
            
            alertController.addAction(logoutAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 6 {
            return heightForCell(tableView.bounds.width)
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func heightForCell(width: CGFloat) -> CGFloat {
        let labelWidth = width - 20 - 15 - CGRectGetMaxX(profileLabelLeft.frame)
        
        profileLabel.text = user.bioText
        
        let maxSize = CGSize(width: labelWidth, height: .max)
        return 8 + 8 + profileLabel.sizeThatFits(maxSize).height + 1
    }
}

extension AccountEditViewController: UITextFieldDelegate {
    
    // When clicking on the field, use this method.
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        
        // Setup the buttons to be put in the system.
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("endEditingNow") )
        var toolbarButtons = [item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        textField.inputAccessoryView = keyboardDoneButtonView
        
        return true
    }
    
}

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

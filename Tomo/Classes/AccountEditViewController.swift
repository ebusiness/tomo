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
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var tomoIDCell: UITableViewCell!
    @IBOutlet weak var birthdayCell: UITableViewCell!
    @IBOutlet weak var sexCell: UITableViewCell!
    @IBOutlet weak var addressCell: UITableViewCell!
    @IBOutlet weak var siteCell: UITableViewCell!
    @IBOutlet weak var telCell: UITableViewCell!
    @IBOutlet weak var introductionCell: UITableViewCell!
    @IBOutlet weak var stationCell: UITableViewCell!
    @IBOutlet weak var statusCell: UITableViewCell!

    var user: User!
    var path: String?
    
    var textViewInputVC: TextViewInputViewController?
    var stationTableViewController: StationTableViewController?
    
    var readOnlyMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        statusCell.hidden = true
        if readOnlyMode {
            statusCell.hidden = false
            if DBController.isInvitedUser(user) || DBController.isFriend(user) {
                logoutLabel.text = "追加済み"
            } else if user.id == Defaults["myId"].string {
                logoutLabel.text = "本人"
                statusCell.hidden = true
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
        
        if let stationTableViewController = stationTableViewController {
//            user.nearestSt = station.name
            
            user.stations = NSOrderedSet(array: stationTableViewController.selectedStations)
            
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
        nameTF.text = user.nickName
        //誕生日
        birthdayLabel.text = user.birthDay?.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        
        //性別
        sexLabel.text = user.gender
        //住所
        addressTF.text = user.address
        //駅
        stationLabel.text = (user.stations.array.last as? Station)?.name
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
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //　ステータス
        if cell == statusCell { self.didSelectStatusCell() }
        //　編集モード、あるいは本人ではない場合　以下の編集処理をしない
        else if readOnlyMode || user.id != Defaults["myId"].string { return }
        //　プロファイル写真
        else if cell == avatarCell { self.didSelectAvatarCell() }
        //　名前
        else if cell == nameCell {  self.didSelectNameCell() }
        //　tomoID
        else if cell == tomoIDCell { self.didSelectTomoIDCell() }
        //　誕生日
        else if cell == birthdayCell { self.didSelectBirthdayCell() }
        //　性別
        else if cell == sexCell { self.didSelectSexCell() }
        //　住所
        else if cell == addressCell { self.didSelectAddressCell() }
        //　現場
        else if cell == stationCell { self.didSelectStationCell() }
        //　個人サイト
        else if cell == siteCell { self.didSelectSiteCell() }
        //　Tel
        else if cell == telCell { self.didSelectTelCell() }
        //　自己紹介
        else if cell == introductionCell { self.didSelectIntroductionCell() }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 6 {
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

// MARK: - DBCameraViewControllerDelegate

extension AccountEditViewController: DBCameraViewControllerDelegate {
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

// MARK: - didSelectRowAtIndexPath

extension AccountEditViewController {
    //　プロファイル写真
    func didSelectAvatarCell(){
        let atvc = Util.createViewControllerWithIdentifier("AlertTableView", storyboardName: "ActionSheet") as! AlertTableViewController

        let cameraAction = AlertTableViewController.tappenDic(title: "写真を撮る",tappen: { (sender) -> () in
            DBCameraController.openCamera(self, delegate: self,isQuad: true)
        })
        let albumAction = AlertTableViewController.tappenDic(title: "写真から選択",tappen: { (sender) -> () in
            DBCameraController.openLibrary(self, delegate: self,isQuad: true)
        })
        atvc.show(self, data: [cameraAction,albumAction])
    }
    //　名前
    func didSelectNameCell() { nameTF.becomeFirstResponder() }
    //　tomoID
    func didSelectTomoIDCell() {  }
    //　誕生日
    func didSelectBirthdayCell() {
        ActionSheetDatePicker.showPickerWithTitle("誕生日", datePickerMode: .Date, selectedDate: user.birthDay ?? kBirthdayDefault, minimumDate: kBirthdayMin, maximumDate: kBirthdayMax, doneBlock: { (picker, selectedDate, origin) -> Void in
            self.user.birthDay = (selectedDate as! NSDate)
            
            DBController.save()
            
            self.birthdayLabel.text = self.user.birthDay?.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
            
            ApiController.editUser(self.user, done: { (error) -> Void in
                
            })
            }, cancelBlock: nil, origin: view)
    }
    //　性別
    func didSelectSexCell() {
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
    //　住所
    func didSelectAddressCell() {
        addressTF.becomeFirstResponder()
    }
    //　現場
    func didSelectStationCell() {
        stationTableViewController = StationTableViewController()
        //                stationTableViewController?.selectedStation = DBController.myStation()
        
        navigationController?.pushViewController(stationTableViewController!, animated: true)
    }
    //　個人サイト
    func didSelectSiteCell() {
        siteTF.becomeFirstResponder()
    }
    //　Tel
    func didSelectTelCell() {
        telTF.becomeFirstResponder()
    }
    //　自己紹介
    func didSelectIntroductionCell() {  }
    //　ステータス
    func didSelectStatusCell(){
        if readOnlyMode{
            
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
        }
    }
    
}
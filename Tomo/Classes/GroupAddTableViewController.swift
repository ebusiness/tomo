//
//  GroupAddTableViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/23.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupAddTableViewController: UITableViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var content: String?
    var imagePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem?.enabled = false
    }

    // MARK: - Action
    
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func addImageTapped(sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "写真を撮る", style: .Default, handler: { (action) -> Void in
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.delegate = self
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let albumAction = UIAlertAction(title: "写真から選択", style: .Default, handler: { (action) -> Void in
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func send(sender: AnyObject) {
        ApiController.createGroup(titleTF.text, content: content, type: .Public, localImagePath: imagePath, done: { (groupId, error) -> Void in
            if let groupId = groupId, imagePath = self.imagePath {
                ApiController.changeGroupCover(imagePath, groupId: groupId, done: { (error) -> Void in
                    
                })
            }
        })
        
        navigationController?.popViewControllerAnimated(true)
    }
}

// MARK: - UITextViewDelegate

extension GroupAddTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if content == nil || content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        content = textView.text
        
//        if content != nil && content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
//            self.navigationItem.rightBarButtonItem?.enabled = true
//        } else {
//            self.navigationItem.rightBarButtonItem?.enabled = false
//        }
    }
}

// MARK: - UITextFieldDelegate

extension GroupAddTableViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        navigationItem.rightBarButtonItem?.enabled = string.length > 0 || textField.text.length - range.length > 0
        
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        navigationItem.rightBarButtonItem?.enabled = textField.text.length > 0
    }

}

// MARK: - UIImagePickerControllerDelegate

extension GroupAddTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        
        let name = NSUUID().UUIDString
        imagePath = NSTemporaryDirectory() + name
        
        let newImage = image.normalizedImage()
        
        newImage.saveToPath(imagePath)
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.imageView.image = newImage
        })
    }
}

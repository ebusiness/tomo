//
//  CameraController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/19.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import AVFoundation

class CameraController: NSObject {
    typealias CameraBlock = (image: UIImage?, videoPath: String?) -> ()
    
    private let picker = UIImagePickerController()
    private var completion: CameraBlock!
    private var vc:UIViewController!
    
    class var sharedInstance : CameraController {
        struct Static {
            static let instance : CameraController = CameraController()
        }
        return Static.instance
    }
    
    private override init() {
        super.init()
        picker.delegate = self
        picker.videoMaximumDuration = 10
    }
    
    func open(vc:UIViewController, sourceType: UIImagePickerControllerSourceType, withVideo:Bool = false, allowsEditing: Bool = false, completion: CameraBlock ){
        self.completion = completion
        picker.sourceType = sourceType
        picker.allowsEditing = allowsEditing
        picker.mediaTypes = [kUTTypeImage as String]
        if withVideo { picker.mediaTypes.append(kUTTypeMovie as String) }
        self.vc = vc
        
        self.presentViewController()
    }
    
    private func presentViewController(){
        
        let status = picker.sourceType == .Camera ?
            AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo).rawValue : PHPhotoLibrary.authorizationStatus().rawValue
        
        switch status {
        case 0://NotDetermined
            self.requestAuthorization()
        case 1://Restricted
            fallthrough
        case 2://Denied
            showServiceDisabledAlert()
        case 3://Authorized
            if UIImagePickerController.isSourceTypeAvailable(picker.sourceType) {
                vc.presentViewController(picker, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    private func requestAuthorization(){
        if picker.sourceType == .Camera {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                if granted {
                    self.presentViewController()
                } else {
                    self.showServiceDisabledAlert()
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization({ status in
                if status == .Authorized {
                    self.presentViewController()
                } else {
                    self.showServiceDisabledAlert()
                }
            })
        }
    }
    
    private func showServiceDisabledAlert() {
        
        let title = picker.sourceType == .Camera ? "現場Tomo需要访问您的相机" : "現場Tomo需要访问您的照片",
        message = picker.sourceType == .Camera ? "为了能够拍照，请您允许現場Tomo访问您的相机" : "为了能够在您发表的帖子中加入照片，请您允许現場Tomo访问您的照片"
        
        Util.alert(vc, title: title, message: message, cancel: "不允许", ok: "允许") { _ in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate

extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    //MARK: - Delegates
    //What to do when the picker returns with a photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        gcd.async(.Default) {
            let mediaType = info["UIImagePickerControllerMediaType"] as! String
            
            if mediaType == kUTTypeMovie as String {
                let url = info[UIImagePickerControllerMediaURL] as! NSURL
                let path = url.path!
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, nil, nil)
                
                gcd.sync(.Main) {
                    self.completion(image: nil, videoPath: path)
                }
                
            } else {
                var imageTaked:UIImage!
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    imageTaked = image
                } else {
                    imageTaked = info[UIImagePickerControllerOriginalImage] as! UIImage
                }
                if picker.sourceType == .Camera {
                    UIImageWriteToSavedPhotosAlbum(imageTaked, nil, nil, nil)
                }
                imageTaked = self.resize(imageTaked)
                
                gcd.sync(.Main) {
                    self.completion(image: imageTaked, videoPath: nil)
                }
            }
        }
    }
    
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // TODO - refactor out
    private func resize(image: UIImage) -> UIImage {
        
        let imageData = UIImageJPEGRepresentation(image, 1)!
        
        // if the image smaller than 1MB, do nothing
        if !(imageData.length/1024/1024 > 1) {
            return image.normalizedImage()
        }
        
        // modify this value to change result size
        let resizeFactor:CGFloat = 1
        
        // based on iPhone6 plus screen
        let widthBase = UIScreen.mainScreen().bounds.size.width * resizeFactor
        let heigthBase = UIScreen.mainScreen().bounds.size.height * resizeFactor
        
        return image.scaleToFitSize( CGSizeMake(widthBase, heigthBase) ).normalizedImage()
    }
}


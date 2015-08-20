//
//  CameraController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/19.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class CameraController: NSObject {
    typealias CameraBlock = (image: UIImage?, videoPath: String?) -> ()
    
    private let picker = UIImagePickerController()
    private var completion: CameraBlock!
    
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
    
    func open(vc:UIViewController,sourceType: UIImagePickerControllerSourceType, withVideo:Bool = false, allowsEditing: Bool = false, completion: CameraBlock ){
        
        if sourceType == .Camera {
            let avstatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            if avstatus !=  .NotDetermined && avstatus !=  .Authorized {
                Util.showInfo("请允许本App使用相机")
                return
            }
        } else {
            let status = ALAssetsLibrary.authorizationStatus()
            if status != .NotDetermined && status != .Authorized {
                Util.showInfo("请允许本App访问相册")
                return
            }
        }
        
        self.completion = completion
        picker.sourceType = sourceType
        picker.allowsEditing = allowsEditing
        picker.mediaTypes = [kUTTypeImage]
        if withVideo { picker.mediaTypes.append(kUTTypeMovie) }
        vc.presentViewController(picker, animated: true, completion: nil)
    }
}


// MARK: - UIImagePickerControllerDelegate

extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    //MARK: - Delegates
    //What to do when the picker returns with a photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let mediaType = info["UIImagePickerControllerMediaType"] as! String
        
        var name: String!
        var localURL: NSURL!
        var remotePath: String!
        
        if mediaType == kUTTypeMovie as! String {
            let url = info[UIImagePickerControllerMediaURL] as! NSURL
            let path = url.path!
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, nil, nil)
            self.completion(image: nil, videoPath: path)
            
        } else {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                self.completion(image: image.normalizedImage(), videoPath: nil)
            } else {
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                self.completion(image: image.normalizedImage(), videoPath: nil)
            }
        }
    }
    
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}


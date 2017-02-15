//
//  CameraController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/19.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import AVFoundation

class CameraController: NSObject {
    typealias CameraBlock = (_ image: UIImage?, _ videoPath: String?) -> ()

    private let picker = UIImagePickerController()
    fileprivate var completion: CameraBlock!
    private var vc: UIViewController!

    static let sharedInstance: CameraController = CameraController()

    private override init() {
        super.init()
        picker.delegate = self
        picker.videoMaximumDuration = 10
    }

    func open(vc: UIViewController, sourceType: UIImagePickerControllerSourceType, withVideo: Bool = false, allowsEditing: Bool = false, completion: @escaping CameraBlock ) {
        self.completion = completion
        picker.sourceType = sourceType
        picker.allowsEditing = allowsEditing
        picker.mediaTypes = [kUTTypeImage as String]
        if withVideo { picker.mediaTypes.append(kUTTypeMovie as String) }
        self.vc = vc

        self.presentViewController()
    }

    private func presentViewController() {

        let status = picker.sourceType == .camera ?
            AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo).rawValue: PHPhotoLibrary.authorizationStatus().rawValue

        switch status {
        case 0: //NotDetermined
            self.requestAuthorization()
        case 1: //Restricted
            fallthrough
        case 2: //Denied
            showServiceDisabledAlert()
        case 3: //Authorized
            if UIImagePickerController.isSourceTypeAvailable(picker.sourceType) {
                vc.present(picker, animated: true, completion: nil)
            }
        default:
            break
        }
    }

    private func requestAuthorization() {
        if picker.sourceType == .camera {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                if granted {
                    self.presentViewController()
                } else {
                    self.showServiceDisabledAlert()
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization({ status in
                if status == .authorized {
                    self.presentViewController()
                } else {
                    self.showServiceDisabledAlert()
                }
            })
        }
    }

    private func showServiceDisabledAlert() {

        let title = picker.sourceType == .camera ? "現場Tomo需要访问您的相机" : "現場Tomo需要访问您的照片",
        message = picker.sourceType == .camera ? "为了能够拍照，请您允许現場Tomo访问您的相机" : "为了能够在您发表的帖子中加入照片，请您允许現場Tomo访问您的照片"

        Util.alert(parentvc: vc, title: title, message: message, cancel: "不允许", ok: "允许") { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(url!)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : Any]!) {
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }

    //MARK: - Delegates
    //What to do when the picker returns with a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)

        gcd.async(.default) {
            let mediaType = info["UIImagePickerControllerMediaType"] as? String

            if mediaType == kUTTypeMovie as String {
                let url = info[UIImagePickerControllerMediaURL] as? URL
                let path = url?.path
                UISaveVideoAtPathToSavedPhotosAlbum(path!, self, nil, nil)

                gcd.sync(.main) {
                    self.completion?(nil, path)
                }

            } else {
                var imageTaked: UIImage!
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    imageTaked = image
                } else {
                    imageTaked = info[UIImagePickerControllerOriginalImage] as? UIImage
                }
                if picker.sourceType == .camera {
                    UIImageWriteToSavedPhotosAlbum(imageTaked, nil, nil, nil)
                }
                imageTaked = self.resize(image: imageTaked)

                gcd.sync(.main) {
                    self.completion?(imageTaked, nil)
                }
            }
        }
    }

    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // TODO - refactor out
    private func resize(image: UIImage) -> UIImage {

        let imageData = UIImageJPEGRepresentation(image, 1)!

        // if the image smaller than 1MB, do nothing
        if !(imageData.count/1024/1024 > 1) {
            return image.normalizedImage()
        }

        // modify this value to change result size
        let resizeFactor: CGFloat = 1

        // based on iPhone6 plus screen
        let widthBase = UIScreen.main.bounds.size.width * resizeFactor
        let heigthBase = UIScreen.main.bounds.size.height * resizeFactor

        return image.scale( toFit: CGSize(width: widthBase, height: heigthBase))!.normalizedImage()
    }
}

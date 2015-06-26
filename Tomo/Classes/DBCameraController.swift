//
//  DBCameraController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class DBCameraController:NSObject {
    //写真を撮る
    class func openCamera(vc:UIViewController,delegate:DBCameraViewControllerDelegate, isQuad:Bool = false){
        
        let container = DBCameraContainerViewController(delegate: delegate)
        container.setFullScreenMode()
        if isQuad {
            let cameraController = DBCameraViewController.initWithDelegate(delegate)
            cameraController.forceQuadCrop = true
            container.cameraViewController = cameraController
        }
        presentView(vc, rootViewController: container)
    }
    //写真から選択
    class func openLibrary(vc:UIViewController,delegate:DBCameraViewControllerDelegate, isQuad:Bool = false){
        
        let libraryViewController = DBCameraLibraryViewController()
        libraryViewController.delegate = delegate
        if isQuad {
            let cameraController = DBCameraViewController.initWithDelegate(delegate)
            cameraController.forceQuadCrop = true
        }
        libraryViewController.useCameraSegue = true
        libraryViewController.forceQuadCrop = isQuad
        presentView(vc, rootViewController: libraryViewController)
    }
    //presentViewController
    private class func presentView(vc:UIViewController,rootViewController:UIViewController){
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.navigationBarHidden = true
        vc.presentViewController(nav, animated: true, completion: nil)
    }
}

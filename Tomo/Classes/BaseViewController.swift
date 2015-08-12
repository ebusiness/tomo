//
//  BaseViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let manager = RKObjectManager(baseURL: kAPIBaseURL)
    var alwaysShowNavigationBar = false
    
    override func loadView() {
        super.loadView()
        self.manager.registerRequestOperationClass(RestKitErrorHanding.self)
        self.setupMapping()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        let backitem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backitem
        
        let backimage = UIImage(named: "back")!
        navigationController?.navigationBar.backIndicatorImage = backimage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backimage
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if self.alwaysShowNavigationBar {
            
            self.extendedLayoutIncludesOpaqueBars = false
            self.automaticallyAdjustsScrollViewInsets = true
            var image = Util.imageWithColor(NavigationBarColorHex, alpha: 1)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage(named:"text_protection")?.scaleToFillSize(CGSizeMake(320, 5))
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.translucent = true
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    
    deinit {       
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupMapping(){
    
    }
}
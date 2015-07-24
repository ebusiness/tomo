//
//  BaseTableViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    var topConstraint:NSLayoutConstraint?
    var headerHeight:CGFloat = 160 - 64

    var whenShowNavigationBar : ( (CGFloat)->() )?
    var whenHideNavigationBar : ( (CGFloat)->() )?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")

        self.setBackButton()
        self.setTopConstraint()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
        #if DEBUG
            Util.showInfo("メモリー不足")
        #endif
    }
    
    deinit {
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


extension BaseTableViewController {
    
    func setBackButton() {
        
        let backitem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backitem
        
        let backimage = UIImage(named: "back")!
        navigationController?.navigationBar.backIndicatorImage = backimage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backimage
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    func setTopConstraint() {
        
        if let headerView = self.tableView.tableHeaderView where headerView.frame.size.height >= self.headerHeight + 64 {
            
            for c in headerView.constraints() {
                
                if c.firstAttribute == .Top {
                    self.topConstraint = c as? NSLayoutConstraint
                    break
                }
            }
            
        }
        
    }
}

extension BaseTableViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if let topConstraint = self.topConstraint {
            
            let y = scrollView.contentOffset.y
            
            if y < 0 || self.headerHeight > y {
                
                self.whenHideNavigationBar?(y)
                topConstraint.constant = y
                
            } else {
                
                self.whenShowNavigationBar?(y)
                
            }

//            if y < 0 { // pull down
//                navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
//                topConstraint.constant = y
//            } else if self.headerHeight > y {
//                let alpha = y / self.headerHeight
//                navigationController?.navigationBar.backgroundColor = Util.UIColorFromRGB(0xFF00FF, alpha: alpha )
//                topConstraint.constant = y / 2
//            } else {
//                navigationController?.navigationBar.backgroundColor = Util.UIColorFromRGB(0xFF00FF, alpha: 1 )
//            }
        }
    }
}

extension BaseTableViewController {
    
    func setNavigationBarBackgroundImage (image:UIImage?,alpha:CGFloat){
        
        if let naviSubViews = self.navigationController?.navigationBar.subviews {
            
            naviSubViews.map{ (v) -> () in
                
                if let imageview = v as? UIImageView
                    where imageview.frame.size.width == self.navigationController?.navigationBar.frame.size.width
                {
                    
                    imageview.image = image
                    imageview.alpha = alpha
                    if imageview.tag != 1 {
                        
                        imageview.tag = 1
                        imageview.contentMode = UIViewContentMode.ScaleAspectFill
                        imageview.clipsToBounds = true
                        
                        let textProtectionImageview = UIImageView(frame: CGRectMake(0, 0, imageview.frame.size.width, imageview.frame.size.height))
                        textProtectionImageview.image = UIImage(named: "text_protection")
                        textProtectionImageview.contentMode = UIViewContentMode.ScaleToFill
                        textProtectionImageview.clipsToBounds = true
                        
                        imageview.addSubview(textProtectionImageview)
                        
                    }
                }
            }
        }
        
    }
    
}


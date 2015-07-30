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
    var navigationImageView:UIImageView?

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

        if self.automaticallyAdjustsScrollViewInsets { return } //nothing under the navigationBar
        
        if let topConstraint = self.topConstraint {
            
            let y = scrollView.contentOffset.y
            
            if let whenHideNavigationBar = self.whenHideNavigationBar ,whenShowNavigationBar = self.whenShowNavigationBar {
                
                if y < 0 || self.headerHeight > y {
                    
                    whenHideNavigationBar(y)
                    topConstraint.constant = y
                    
                } else {
                    
                    whenShowNavigationBar(y)
                    
                }
                
            } else {
                
                if y < 0 {
                    
                    topConstraint.constant = y
                    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
                    
                } else {
                    
                    var image = Util.imageWithColor(0x673AB7, alpha: y/self.headerHeight)
                    navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
                    
                }
            }
        }
    }
}

extension BaseTableViewController {
    
    func setNavigationBarBackgroundImage (image:UIImage?,alpha:CGFloat){
        
        if navigationImageView == nil {
            
            if let naviSubViews = self.navigationController?.navigationBar.subviews {
                
                naviSubViews.map{ (v) -> () in
                    
                    if let imageview = v as? UIImageView
                        where imageview.frame.size.width == self.navigationController?.navigationBar.frame.size.width
                    {
                        
                        imageview.contentMode = UIViewContentMode.ScaleAspectFill
                        imageview.clipsToBounds = true
                        
                        self.navigationImageView = imageview
                    }
                }
            }
        }
        
        if let imageview = navigationImageView,image = image {
            
            if self.navigationImageView?.subviews.count < 1 {
                
                let textProtectionImageview = UIImageView(frame: CGRectMake(0, 0, imageview.frame.size.width, imageview.frame.size.height))
                textProtectionImageview.image = UIImage(named: "text_protection")
                textProtectionImageview.contentMode = UIViewContentMode.ScaleToFill
                textProtectionImageview.clipsToBounds = true
                
                imageview.addSubview(textProtectionImageview)
                
            }
            imageview.image = image
            imageview.alpha = alpha
            
        } else {
            
            if let subv = self.navigationImageView?.subviews {
                
                for v in subv {
                    v.removeFromSuperview()
                }
            }
            
            self.navigationImageView?.image = nil
            self.navigationImageView?.alpha = 1
            
        }
        
    }
    
}


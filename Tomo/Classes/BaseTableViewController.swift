//
//  BaseTableViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    var topConstraint: NSLayoutConstraint?
    var headerHeight: CGFloat = 160 - 64
    var navigationImageView: UIImageView?
    var navigationTextProtection: UIImageView?

    var whenShowNavigationBar: ( (CGFloat)->() )?
    var whenHideNavigationBar: ( (CGFloat)->() )?
    
    var alwaysShowNavigationBar = false
    
    override func loadView() {
        super.loadView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackButton()
        self.setTopConstraint()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow() {
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
        
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
            self.setNavigationBarBackgroundImage(nil)
            self.navigationTextProtection?.alpha = 1
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollViewDidScroll(self.tableView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationImageView?.alpha = 0
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - Internal Methods

extension BaseTableViewController {
    
    func becomeActive() {
    }
    
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
            
            self.topConstraint = headerView.constraints().find { $0.firstAttribute == .Top } as? NSLayoutConstraint
        }
    }
    
    func changeHeaderView(height h: CGFloat, done: ( ()->() )? = nil ){
        
        let headerView = self.tableView.tableHeaderView as UIView!
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            headerView.frame.size.height = h
            self.tableView.tableHeaderView = headerView
            self.tableView.layoutIfNeeded()
            done?()
        })
    }
    
    func setNavigationBarBackgroundImage(image: UIImage?){
        
        if let naviSubViews = self.navigationController?.navigationBar.subviews where navigationImageView == nil {
            
            naviSubViews.map{ (v) -> () in
                
                if let imageview = v as? UIImageView
                    where imageview.frame.size.width == self.navigationController?.navigationBar.frame.size.width
                {
                    var frame = imageview.frame
                    frame.origin = CGPointMake(0, 0)
                    
                    imageview.subviews.map{ (subimage) -> () in
                        if let subimage = subimage as? UIImageView where subimage.tag == 1 {
                            
                            self.navigationImageView = subimage
                            return
                        }
                    }
                    if self.navigationImageView != nil { return }
                    
                    self.navigationTextProtection = UIImageView(frame: frame)
                    self.navigationTextProtection!.image = UIImage(named: "text_protection")
                    self.navigationTextProtection!.contentMode = UIViewContentMode.ScaleToFill
                    self.navigationTextProtection!.clipsToBounds = true
                    self.navigationTextProtection!.alpha = 0
                    
                    self.navigationImageView = UIImageView(frame: frame)
                    self.navigationImageView!.tag = 1
                    self.navigationImageView!.image = UIImage()
                    self.navigationImageView!.contentMode = UIViewContentMode.ScaleAspectFill
                    self.navigationImageView!.clipsToBounds = true
                    self.navigationImageView!.addSubview(self.navigationTextProtection!)
                    
                    imageview.insertSubview(self.navigationImageView!, atIndex: 0)
                }
            }
        }
        navigationImageView?.alpha = 1
        
        if let imageview = navigationImageView where imageview.image != image {
            if image != nil {
                self.navigationTextProtection?.alpha = 1
                self.navigationController?.navigationBar.shadowImage = UIImage(named:"text_protection")?.scaleToFillSize(CGSizeMake(320, 5))
            } else {
                self.navigationTextProtection?.alpha = 0
                self.navigationController?.navigationBar.shadowImage = UIImage()
            }
            imageview.image = image
        }
        
    }
}

// MARK: - ScrollView Delegate

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
                    
                    let image = Util.imageWithColor(NavigationBarColorHex, alpha: y/self.headerHeight)
                    navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
                    
                    if self.headerHeight <= y {
                        self.navigationController?.navigationBar.shadowImage = UIImage(named:"text_protection")?.scaleToFillSize(CGSizeMake(320, 5))
                    } else {
                        self.navigationController?.navigationBar.shadowImage = UIImage()
                    }
                }
            }
        }
    }
}

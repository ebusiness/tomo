//
//  BaseViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var alwaysShowNavigationBar = false
    var topConstraint: NSLayoutConstraint?
    var headerHeight: CGFloat = 160 - 64
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getTopConstraint()
        
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
}

extension BaseViewController {
    
    func getTopConstraint() {
        if let tableView = self.view.subviews.first as? UITableView, headerView = tableView.tableHeaderView where headerView.frame.size.height >=  self.headerHeight + 64 {
            
            for c in headerView.constraints() {
                
                if c.firstAttribute == .Top {
                    self.topConstraint = c as? NSLayoutConstraint
                    break
                }
            }
        }
    }
}

// MARK: - ScrollView Delegate

extension BaseViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.automaticallyAdjustsScrollViewInsets { return } //nothing under the navigationBar
        
        if let topConstraint = self.topConstraint {
            let y = scrollView.contentOffset.y
            
            if y < 0 {
                topConstraint.constant = y
                navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            } else {
                var image = Util.imageWithColor(NavigationBarColorHex, alpha: y/self.headerHeight)
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

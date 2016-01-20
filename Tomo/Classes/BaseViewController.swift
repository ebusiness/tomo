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
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if self.alwaysShowNavigationBar {
            
            self.extendedLayoutIncludesOpaqueBars = false
            self.automaticallyAdjustsScrollViewInsets = true
            let image = Util.imageWithColor(NavigationBarColorHex, alpha: 1)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.translucent = true
        }
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    deinit {       
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension BaseViewController {
    
    func getTopConstraint() {
        if let headerView = (self.view.subviews.first as? UITableView)?.tableHeaderView where headerView.frame.size.height >=  self.headerHeight + 64 {
                
                self.topConstraint = headerView.constraints.find { $0.firstAttribute == .Top }
        }
    }
}

// MARK: - ScrollView Delegate

extension BaseViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.automaticallyAdjustsScrollViewInsets { return } //nothing under the navigationBar
        
        guard let topConstraint = self.topConstraint else { return }
        
        let y = scrollView.contentOffset.y
        
        if y < 0 {
            topConstraint.constant = y
            navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        } else {
            let image = Util.imageWithColor(NavigationBarColorHex, alpha: y/self.headerHeight)
            navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        }
    }
}

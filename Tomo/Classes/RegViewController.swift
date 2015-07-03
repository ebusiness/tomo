//
//  RegViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RegViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var upImageView: UIImageView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var regPageDatas = [RegPageData]()
    
    var pages: Int {
        return regPageDatas.count
    }
    
    var currentPage: Int {
        return pageControl.currentPage
    }
    
    var lastContentOffset = CGPointZero
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.loginButton.hidden = true
        
        loadRegPageData()
        
        pageControl.numberOfPages = pages
        
        setupPageView()
        
        backImageView.image = UIImage(named: regPageDatas[1].imageName)
        upImageView.image = UIImage(named: regPageDatas[0].imageName)
        
        backImageView.alpha = 0
        upImageView.alpha = 1
        
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 2
    }
    
    func loadRegPageData() {
        let array = Util.arrayFromPlist("RegPageData")
        for dic in array {
            let regPageData = RegPageData(dic: dic as! NSDictionary)
            regPageDatas.append(regPageData)
        }
    }
    
    func setupPageView() {
        
        var lastPageView: RegPageView?
        
        for i in 0..<pages {
            let pageView = Util.createViewWithNibName("RegPageView") as! RegPageView
            pageView.regPageData = regPageDatas[i]
            
            scrollView.addSubview(pageView)
            pageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            scrollView.addConstraint(NSLayoutConstraint(item: pageView, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: pageView, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1.0, constant: 0))
            
            if let lastPageView = lastPageView {
                scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[lastPageView][pageView]", options: .AlignAllTop | .AlignAllBottom, metrics: nil, views: ["lastPageView" : lastPageView, "pageView" : pageView]))
            } else {
                scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[pageView]|", options: nil, metrics: nil, views: ["pageView" : pageView]))
                scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[pageView]|", options: nil, metrics: nil, views: ["pageView" : pageView]))
            }

            lastPageView = pageView
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize.width = CGFloat(pages) * scrollView.bounds.width
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func login_wechat(sender: AnyObject) {
        OpenidController.instance.wxCheckAuth({ (result) -> () in
            self.loginCheck(result)
            
            }, failure: { (errCode, errMessage) -> () in
                
                println(errCode)
                println(errMessage)
                
        })
    }
    
    func loginCheck(result: Dictionary<String, AnyObject>){
        Util.showMessage("ログイン")
        //        if Defaults["shouldTypeLoginInfo"].bool == true {
        //            Util.showInfo("Tomoid、またパスワードが変更されましたため、ご入力ください。")
        //            return;
        //        }
        
        if let uid = result["_id"] as? String {
            ApiController.getMyInfo({ (error) -> Void in
                if let err = error{
                    Util.showError(err)
                } else {
                    if let user = DBController.myUser() {//auto login
                        Defaults["shouldAutoLogin"] = true
                    }
                    RegViewController.changeRootToTab(self)
                }
            })
        }else{
            let password = NSUUID().UUIDString
            var tomoid = NSUUID().UUIDString
            if let openid = result["openid"] as? String ,type = result["type"] as? String {
                tomoid = openid + "@" + type
                OpenidController.instance.getUserInfo(type, done: { (openidInfo) -> Void in
                    var nickname = tomoid
                    if let oinfo = openidInfo{
                        nickname = oinfo["nickname"] as! String
                    }
                    
                    
                    ApiController.signUp(email: tomoid, password: password, firstName: nickname, lastName: type) { (error) -> Void in
                        if let error = error {
                            Util.showError(error)
                        }
                        
                        DBController.clearDB()
                        
                        Defaults["shouldAutoLogin"] = true
                        
                        ApiController.addOpenid(result, done: { (error) -> Void in
                            println(error)
                        })
                        //get user detail
                        ApiController.getMyInfo({ (error) -> Void in
                            if error == nil{
                                RegViewController.changeRootToTab(self)
                                
                            }
                        })
                    }
                })
            }
        }
        
        
    }
    
    class func changeRootToTab(from:UIViewController){
        Util.dismissHUD()
        let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
        Util.changeRootViewController(from: from, to: tab)
    }

}

// MARK: - UIScrollViewDelegate

extension RegViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let percentage = scrollView.contentOffset.x / pageWidth
        
        let p = Int(percentage)
        
        let maxpage = Int(scrollView.contentSize.width/pageWidth)
        
        if maxpage == (p + 1) {
            self.loginButton.hidden = false
            pageControl.hidden = true
            self.loginButton.alpha = 1
        }else{
            self.loginButton.hidden = true
            pageControl.hidden = false
        }
//        if (p + 1) == maxpage && self.loginButton.hidden {
//            self.loginButton.hidden = false
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                self.loginButton.alpha = 1
//            })
//        }else if !self.loginButton.hidden && (p + 2) == maxpage {
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                self.loginButton.alpha = 0
//                }) { (finished) -> Void in
//                    self.loginButton.hidden = true
//            }
//        }
        
        let alpha = percentage - CGFloat(p)
        
//        println(alpha)
        
        //right
        if scrollView.contentOffset.x > lastContentOffset.x {
            if p == regPageDatas.count - 1 {
                pageControl.currentPage = p
                return
            }
            
            lastContentOffset = scrollView.contentOffset
            
            //偶
            if p % 2 == 0 {
                backImageView.alpha = alpha
                upImageView.alpha = 1 - alpha
                
                //换页前
                if p == currentPage {
                    // TODO: change once
                    backImageView.image = UIImage(named: regPageDatas[min(regPageDatas.count - 1, p+1)].imageName)
                }
            } else {
                upImageView.alpha = alpha
                backImageView.alpha = 1 - alpha
                
                if p == currentPage {
                    upImageView.image = UIImage(named: regPageDatas[min(regPageDatas.count - 1, p+1)].imageName)
                }
            }
            
            if p > currentPage {
                pageControl.currentPage = p
            }
            
            return
        }
        
        //left
        if scrollView.contentOffset.x < lastContentOffset.x {
            lastContentOffset = scrollView.contentOffset
            
            //偶
            if p % 2 == 0 {
                backImageView.alpha = alpha
                
                upImageView.alpha = 1 - alpha
                
                if alpha > 0 {
                    upImageView.image = UIImage(named: regPageDatas[p].imageName)
                }
            } else {
                upImageView.alpha = alpha
                backImageView.alpha = 1 - alpha
                
                if alpha > 0 {
                    backImageView.image = UIImage(named: regPageDatas[p].imageName)
                }
            }
            
            if p < currentPage && alpha < 0.1 {
                pageControl.currentPage = p
            }
        }
    }
}

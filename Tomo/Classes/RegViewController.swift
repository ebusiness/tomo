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
    
    @IBOutlet weak var testSegment: UISegmentedControl!
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
        OpenidController.instance.wxCheckAuth(
            success: { (result) -> () in
                RegViewController.changeRootToTab(self)
            },
            failure: { (errCode, errMessage) -> () in
                
                println(errCode)
                println(errMessage)
            })
    }
    
    @IBAction func testLogin(sender: UISegmentedControl) {
        
        var param = Dictionary<String, String>()
        
        switch testSegment.selectedSegmentIndex
        {
        case 0:
            Defaults["myId"] = "55a319577b6eb5a66e91edaa"
            param["id"] = "55a319577b6eb5a66e91edaa"
        case 1:
            Defaults["myId"] = "55a31bc959a1af7373c1d099"
            param["id"] = "55a31bc959a1af7373c1d099"
        case 2:
            Defaults["myId"] = "55a31c7759a1af7373c1d09e"
            param["id"] = "55a31c7759a1af7373c1d09e"
        case 3:
            Defaults["myId"] = "55a31d0a59a1af7373c1d0a3"
            param["id"] = "55a31d0a59a1af7373c1d0a3"
        case 4:
            Defaults["myId"] = "55a31dcb59a1af7373c1d0a8"
            param["id"] = "55a31dcb59a1af7373c1d0a8"
        default:
            break;
        }
        
        let tomo_test_login = kAPIBaseURLString + "/mobile/user/testLogin"
        
        Manager.sharedInstance.request(.GET, tomo_test_login, parameters: param, encoding: ParameterEncoding.URL)
            .responseJSON { (_, res, JSON, _) in
                
                let result = JSON as! Dictionary<String, AnyObject>
                
                if let id = result["id"] as? String,
                    nickName = result["nickName"] as? String{
                        me.id = id
                        me.nickName = nickName
                        
                        me.tomoid = result["tomoid"] as? String
                        me.gender = result["gender"] as? String
                        me.photo = result["photo_ref"] as? String
                        me.cover = result["cover_ref"] as? String
                        me.bio = result["bioText"] as? String
                        me.firstName = result["firstName"] as? String
                        me.lastName = result["lastName"] as? String
                        
                        if let dateString = result["birthDay"] as? String {
                            me.birthDay = dateString.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                        }
                        
                        me.friends = result["friends"] as? [String]
                        me.invited = result["invited"] as? [String]
                        
                        me.telNo = result["telNo"] as? String
                        me.address = result["address"] as? String
//                        me.notificationCount = result["notificationCount"] as? Int
                        
                        var invitations = [NotificationEntity]()
                        
                        if let friendInvitations = result["friendInvitations"] as? Array<AnyObject> {
                            
                            for obj in friendInvitations {
                                
                                if let invitationRaw = obj as? Dictionary<String, AnyObject> {
                                    
                                    let notification = NotificationEntity()
                                    notification.id = invitationRaw["_id"] as? String
                                    
                                    if let dateString = result["createDate"] as? String {
                                        notification.createDate = dateString.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                                    }
                                    
                                    if let fromRaw = invitationRaw["_from"] as? Dictionary<String, String> {
                                        
                                        let from = UserEntity()
                                        from.id = fromRaw["_id"]
                                        from.photo = fromRaw["photo_ref"]
                                        from.nickName = fromRaw["nickName"]
                                        
                                        notification.from = from
                                    }
                                    
                                    invitations.push(notification)
                                }
                            }
                        }
                        
                        me.friendInvitations = invitations
                        
                        var messages = [MessageEntity]()
                        
                        if let newMessages = result["newMessages"] as? Array<AnyObject> {
                            
                            for obj in newMessages {
                                
                                if let messageRaw = obj as? Dictionary<String, String> {
                                    
                                    let message = MessageEntity()
                                    message.id = messageRaw["_id"]
                                    message.createDate = messageRaw["createDate"]?.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                                    
                                    let from = UserEntity()
                                    from.id = messageRaw["_from"]
                                    
                                    message.from = from
                                    
                                    messages.push(message)
                                }
                            }
                        }
                        
                        me.newMessages = messages
                }
                
                RegViewController.changeRootToTab(self)
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

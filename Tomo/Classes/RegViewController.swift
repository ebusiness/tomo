//
//  RegViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RegViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var upImageView: UIImageView!
    
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
        
        loadRegPageData()
        
        pageControl.numberOfPages = pages
        
        setupPageView()
        
        backImageView.image = UIImage(named: regPageDatas[1].imageName)
        upImageView.image = UIImage(named: regPageDatas[0].imageName)
        
        backImageView.alpha = 0
        upImageView.alpha = 1
    }
    
    func loadRegPageData() {
        let array = Util.arrayFromPlist("RegPageData")
        for dic in array {
            let regPageData = RegPageData(dic: dic as NSDictionary)
            regPageDatas.append(regPageData)
        }
    }
    
    func setupPageView() {
        var lastPageView: RegPageView?
        
        for i in 0..<pages {
            let pageView = Util.createViewWithNibName("RegPageView") as RegPageView
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UIScrollViewDelegate

extension RegViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let percentage = scrollView.contentOffset.x / pageWidth
        
        let p = Int(percentage)
        
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

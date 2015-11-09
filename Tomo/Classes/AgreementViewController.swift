//
//  AgreementViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/11/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class AgreementViewController: BaseViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alwaysShowNavigationBar = true
        webView.scrollView.bounces = false
        
        if let htmlPath = NSBundle.mainBundle().pathForResource("statements", ofType: "html") {
            let url = NSURL.fileURLWithPath(htmlPath)
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


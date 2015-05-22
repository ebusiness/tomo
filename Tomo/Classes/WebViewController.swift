//
//  WebViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var navigationTitle: String?
    var path: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = navigationTitle
        
        let req = NSURLRequest(URL: NSURL(string: path)!)
        webView.loadRequest(req)
    }

}

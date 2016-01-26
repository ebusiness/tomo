//
//  AgreementViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/11/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class AgreementViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        if let htmlPath = NSBundle.mainBundle().pathForResource("statements", ofType: "html") {
            let url = NSURL.fileURLWithPath(htmlPath)
            let request = NSURLRequest(URL: url)
            self.webView.loadRequest(request)
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UINavigationBar Delegate

extension AgreementViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}


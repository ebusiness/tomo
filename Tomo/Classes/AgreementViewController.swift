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

        if let htmlPath = Bundle.main.path(forResource: "statements", ofType: "html") {
            let url = NSURL.fileURL(withPath: htmlPath)
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UINavigationBar Delegate

extension AgreementViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

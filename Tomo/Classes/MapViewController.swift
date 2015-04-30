//
//  MapViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MapViewController: BaseViewController,UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        webView.hidden = true
        let req = NSURLRequest(URL: NSURL(string: mapPath)!)
        webView.loadRequest(req)
        webView.delegate = self
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
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL {
            if url.scheme == "genbatomo" {
                scheme(url)
                return false;
            }
        }
        return true;
    }
    
    func scheme(url:NSURL){
        if let host = url.host {
            
            let param = urlComponentsToDict(url);
            
            switch host {
            case"groups":
                let vc = Util.createViewControllerWithIdentifier("GroupListViewController", storyboardName: "Group") as! GroupListViewController
                vc.station = param["station._id"]!;
                ApiController.getGroups(param, done: { (error) -> Void in
                     self.navigationController?.pushViewController(vc, animated: true)
                })
                break;
            default:
                break;
            }
        }
    }
    
    func urlComponentsToDict(url:NSURL) -> Dictionary<String, String> {
        
        let comp: NSURLComponents? = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
        
        var dict:Dictionary<String, String> = Dictionary<String, String>()
        
        for (var i=0; i < comp?.queryItems?.count; i++) {
            let item = comp?.queryItems?[i] as! NSURLQueryItem
            dict[item.name] = item.value
        }
        
        return dict
    }

}

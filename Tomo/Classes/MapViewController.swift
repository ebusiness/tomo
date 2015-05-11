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
        Util.showHUD()
        webView.loadRequest(req)
        webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        Util.dismissHUD()
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
                schemeResolve(url)
                return false;
            }
        }
        return true;
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        Util.dismissHUD()
    }
}
// MARK: - Common
extension MapViewController {
    // MARK: - query param
    func urlComponentsToDict(url:NSURL) -> Dictionary<String, String> {
        
        let comp: NSURLComponents? = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
        
        var dict:Dictionary<String, String> = Dictionary<String, String>()
        
        for (var i=0; i < comp?.queryItems?.count; i++) {
            let item = comp?.queryItems?[i] as! NSURLQueryItem
            dict[item.name] = item.value
        }
        return dict
    }
    
    func schemeResolve(url:NSURL){
        if let host = url.host {
            
            let param = urlComponentsToDict(url);
            
            switch host {
            case"groups":
                self.hostGroups(param);
                break;
            case"users":
                self.hostUsers(param);
                break;
            case"posts":
                self.hostPosts(param);
                break;
            case"posts1":
                self.hostPosts(param);
                break;
            default:
                break;
            }
        }
    }
    
}

// MARK: - Action
extension MapViewController {
    // group
    func hostGroups(param:Dictionary<String, String>){
        let vc = Util.createViewControllerWithIdentifier("GroupListViewController", storyboardName: "Group") as! GroupListViewController
        vc.station = param["station._id"]!;
        Util.showHUD(maskType: .None)
        ApiController.getGroups(param, done: { (error) -> Void in
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    // users
    func hostUsers(param:Dictionary<String, String>){

        Util.showHUD(maskType: .None)
        var searchKey = SearchType.Station.searchKey();
        
        ApiController.getUsers(key: searchKey, value: param[searchKey]!, done: { (users, error) -> Void in
            if let users = users {
                if users.count > 0 {
                    let vc = Util.createViewControllerWithIdentifier("FriendListViewController", storyboardName: "Chat") as! FriendListViewController
                    vc.displayMode = .List
                    vc.users = users
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            }
            
            Util.showInfo("見つかりませんでした。")
        })
    }
    // posts
    func hostPosts(param:Dictionary<String, String>){
        let vc = Util.createViewControllerWithIdentifier("NewsfeedViewController", storyboardName: "Newsfeed") as! NewsfeedViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
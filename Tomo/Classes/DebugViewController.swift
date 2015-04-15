//
//  DebugViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var versionLabel: UILabel!
    
    var titles = ["聊天", "用户帖子一览"]
    var names = ["Friend", "Friend"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = UIApplication.versionBuild()

//        SIOSocket.socketWithHost("http://tomo.e-business.co.jp", reconnectAutomatically: false, attemptLimit: -1, withDelay: 20, maximumDelay: 100, timeout: 30) { (soc) -> Void in
//            soc.onConnect = {() -> Void in
//                println("onConnect")
//            }
//            soc.on("no-session", callback: {(args) -> Void in
//                println("no-session")
//            })
//            
//            soc.on("message", callback: {(args) -> Void in
//                println(args)
//            })
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Util.showWhatsnew()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func showInfo(sender: AnyObject) {
        Util.showWhatsnew(checkVersion: false)
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

extension DebugViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DebugCell", forIndexPath: indexPath) as! UICollectionViewCell
        let label = cell.viewWithTag(1) as! UILabel
        label.text = titles[indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: names[indexPath.row]) as! UINavigationController
            
            (vc.topViewController as! FriendListViewController).nextView = NextView(rawValue: indexPath.item)
            
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
}

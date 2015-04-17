//
//  DebugViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class DebugViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var versionLabel: UILabel!
    
    var friendTitles = ["好友一览", "陌生人一览", "聊天", "好友帖子一览", "添加好友", "邀请中用户一览" ]
    var notificationTitles = ["好友请求一览"]
    
    var names = ["Friend","Notification"]
    
    var sectionTitles = Dictionary<Int, [String]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sectionTitles[0] = friendTitles
        sectionTitles[1] = notificationTitles
        
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return names.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DebugCell", forIndexPath: indexPath) as! UICollectionViewCell
        let label = cell.viewWithTag(1) as! UILabel
        
        label.text = sectionTitles[indexPath.section]![indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let name = names[indexPath.section]
        
        let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: name) as! UINavigationController
        
        if indexPath.section == 0 {
            (vc.topViewController as! FriendListViewController).nextView = NextView(rawValue: indexPath.item)
        }
        
        if indexPath.section == 1 {
            if indexPath.item == 0 {
                (vc.topViewController as! NotificationListViewController).notificationType = .FriendInvited
            }
        }
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionTitles[section]!.count
    }
}

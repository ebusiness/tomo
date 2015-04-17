//
//  FriendListViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum NextView: Int {
    case UserDetailFriend, UserDetail, Chat, Posts, AddFriend, UserDetailInvited
}

class FriendListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var users = [User]()

    
    var nextView: NextView!
//    var count: Int {
//        return (friends.sections as [NSFetchedResultsSectionInfo])[0].numberOfObjects
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if nextView == .UserDetail || nextView == .AddFriend {
            ApiController.getUsers({ (error) -> Void in
                self.users = DBController.users()
                self.tableView.reloadData()
            })
            return
        }
        
        if nextView == .UserDetailInvited {
            self.users = DBController.myUser().invited.array as! [User]
            self.tableView.reloadData()
            
            return
        }
        
        users = DBController.friends()
        
        ApiController.getFriends { (error) -> Void in
            if error == nil {
                self.users = DBController.friends()
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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

extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friend = users[indexPath.row] as User
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        cell.friend = friend
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let friend = users[indexPath.row] as User
        
        if nextView == .Chat {
//            let groupId = ChatController.startPrivateChat(user1: ChatController.myUser(), user2: friend)
            
            let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: "Message") as! MessageViewController
//            vc.groupId = groupId
            //Test
            vc.friend = friend
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if nextView == .Posts {
            let vc = Util.createViewControllerWithIdentifier("NewsfeedViewController", storyboardName: "Newsfeed") as! NewsfeedViewController
            vc.user = friend
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if nextView == .AddFriend {
            ApiController.invite(friend.id!, done: { (error) -> Void in
                if error == nil {
                    SVProgressHUD.showSuccessWithStatus("友達追加リクエストを送信しました。")
                    
                    self.users = DBController.users()
                    self.tableView.reloadData()
                }
            })
        }

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
}

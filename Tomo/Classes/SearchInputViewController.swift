//
//  SearchByStationViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum SearchType: String {
    case ID = "Tomo名"
    case Station = "駅名"
    
    static let searchTypes = [ID, Station]
    
    func searchKey() -> String {
        switch self {
        case .ID:
            return "email"
        case .Station:
            return "nearestSt"
        }
    }
}

class SearchInputViewController: BaseViewController {

    @IBOutlet weak var nameTF: UITextField!
    
    var searchType: SearchType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        nameTF.leftViewMode = .Always
        nameTF.leftView = spacerView
        nameTF.placeholder = searchType.rawValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        Util.dismissHUD()
    }
    
    @IBAction func searchBtnTapped(sender: AnyObject) {
        if nameTF.text.length > 0 {
            Util.showHUD(maskType: .None)
            
            ApiController.getUsers(key: searchType.searchKey(), value: nameTF.text, done: { (users, error) -> Void in
                if let users = users {
                    if users.count > 0 {
                        let vc = Util.createViewControllerWithIdentifier("FriendListViewController", storyboardName: "Chat") as! FriendListViewController
                        vc.users = users
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                }
                
                Util.showInfo("見つかりませんでした。")
            })
        }
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

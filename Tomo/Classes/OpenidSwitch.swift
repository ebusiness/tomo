//
//  OpenidSwitch.swift
//  Tomo
//
//  Created by Hikaru on 2015/05/08.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class OpenidSwitch: UISwitch {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ApiController.getOpenids { (error) -> Void in
            self.checkToken();
        }
    }
    
    func switchFlipped(){
        
        if self.restorationIdentifier == "openid_wechat" {
            OpenidController.instance.wxBinding({ (res) -> () in
                self.checkToken()
            }, failure: { (errCode, errMessage) -> () in
                println(errMessage)
                self.setOn(false, animated: true)
            })
        }else{
            OpenidController.instance.qqBinding({ (res) -> () in
                self.checkToken()
                }, failure: { (errCode, errMessage) -> () in
                    println(errMessage)
                    self.setOn(false, animated: true)
            })

        }
    }
    func checkToken(){
        let type:OpenIDRequestType = self.restorationIdentifier == "openid_wechat" ? .WeChat : .QQ;
        
        if let conffig = Openids.MR_findFirstWithPredicate(NSPredicate(format: "type=%@ AND id != nil", type.toString()), sortedBy: "id", ascending: false) as? Openids{
            if let id = conffig.id{
                self.openidon()
                return;
            }
        }
        self.addTarget(self, action: Selector("switchFlipped"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func openidon(){
        
        
//        var param = Dictionary<String, AnyObject>();
//        param["openid"] = _tencentOAuth?.openId
//        param["access_token"] = _tencentOAuth?.accessToken
//        //param["refresh_token"] =
//        param["expirationDate"] = _tencentOAuth?.expirationDate
//        param["type"] = OpenIDRequestType.QQ.toString()
//        
//        ApiController.addOpenid(param, done: { (error) -> Void in
//            println(error)
//        })
        
        
        self.setOn(true, animated: true)
        self.enabled = false
        self.removeTarget(self, action: Selector("switchFlipped"), forControlEvents: UIControlEvents.ValueChanged)
    }
}
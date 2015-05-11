//
//  SNSController.swift
//  spot
//
//  Created by Hikaru on 2015/02/12.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum OpenIDRequestType {
    case QQ,
    WeChat
    
    func toString()->String{
        switch self {
        case .QQ:
            return "qq"
        case .WeChat:
            return "wechat"
        }
    }
}

class OpenidController: NSObject {
    
    typealias snsSuccessHandler = (res: Dictionary<String, AnyObject>) -> ()
    typealias snsFailureHandler = (errCode:Int32,errMessage:String) -> ()
    var whenSuccess:snsSuccessHandler!
    var whenfailure:snsFailureHandler!
    var _isBinding :Bool = false;
    //インスタンス
    class var instance : OpenidController {
        struct Static {
            static let instance : OpenidController = OpenidController()
        }
        return Static.instance
    }
    
    //初期化
    private override init() {
        super.init()
        self.registWX()
        self.registQQ()

    }
}

//共通
extension OpenidController{
    
    func getConfig(type:OpenIDRequestType)->Openids?{
        if let conffig = Openids.MR_findFirstByAttribute("type", withValue: type.toString()) as? Openids {
            switch type{
            case .QQ:
                if conffig.access_token != nil && conffig.openid != nil && conffig.expirationDate != nil {
                    return conffig
                }
                break;
            case .WeChat:
                if conffig.access_token != nil && conffig.openid != nil && conffig.refresh_token != nil {
                    return conffig
                }
                break;
            }
        }
        return nil
    }
    
    //binding OpenidInfo
    func binding(type:OpenIDRequestType,openid:AnyObject!,access_token:AnyObject!,refresh_token:AnyObject?,expirationDate:AnyObject?){
        assert(NSThread.currentThread().isMainThread, "not main thread")
        
        var param = Dictionary<String, AnyObject>();
        param["openid"] = openid
        param["access_token"] = access_token
        param["refresh_token"] = refresh_token
        param["expirationDate"] = expirationDate
        param["type"] = type.toString()
        
        ApiController.addOpenid(param, done: { (error) -> Void in
            self.showSuccess(param)
        })
    }
    func checkToken(#openid: String, token: String, type: OpenIDRequestType, done: (Int?,Dictionary<String, AnyObject>) -> Void) {
        var param = Dictionary<String, String>()
        param["openid"] = openid
        param["access_token"] = token
        param["type"] = type.toString()
        
        let tomo_openid_login = kAPIBaseURLString + "/mobile/user/openid";
        
        Manager.sharedInstance.request(.POST, tomo_openid_login, parameters: param, encoding: ParameterEncoding.URL)
            .responseJSON { (_, res, JSON, _) in
                done(res?.statusCode,param)
                if(res?.statusCode == 200 ){
                    let result = JSON as! Dictionary<String, AnyObject>;
                    Defaults["myId"] = result["id"]
                    self.showSuccess(result)
                    
                    if type == .QQ {
                        self.saveQQ()
                    }else if type == .WeChat{
                        
                    }
                }
        }
        
        
    }
    /////////////////////////////////////////////////////////
    ///////エラーを表示する/////////////////////////////////////
    /////////////////////////////////////////////////////////
    func showError(errCode:Int32,errMessage:String){
        Util.showInfo(errMessage)
        self.whenfailure?(errCode:errCode,errMessage:errMessage)
    }
    func showSuccess(result: Dictionary<String, AnyObject>){
        Util.dismissHUD()
        self.whenSuccess?(res: result)
    }
}

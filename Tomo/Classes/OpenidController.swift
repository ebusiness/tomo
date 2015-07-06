//
//  SNSController.swift
//  spot
//
//  Created by Hikaru on 2015/02/12.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

private let csrf_state = "73746172626f796368696e61"
private let wxAppid = "wx4079dacf73fef72d"
private let wxAppSecret = "d4ec5214ea3ac56752ff75692fb88f48"

let tomo_openid_login = kAPIBaseURLString + "/mobile/user/openid"
let wx_url_access_token = "https://api.weixin.qq.com/sns/oauth2/access_token"
let wx_url_refresh_token = "https://api.weixin.qq.com/sns/oauth2/refresh_token"
let wx_url_userinfo = "https://api.weixin.qq.com/sns/userinfo"

class OpenidController: NSObject {
    
    typealias snsSuccessHandler = (res: Dictionary<String, AnyObject>) -> ()
    typealias snsFailureHandler = (errCode:Int32,errMessage:String?) -> ()
    var whenSuccess:snsSuccessHandler!
    var whenfailure:snsFailureHandler!

    // static initialize
    class var instance : OpenidController {
        struct Static {
            static let instance : OpenidController = OpenidController()
        }
        return Static.instance
    }
    
    private override init() {
        super.init()
        WXApi.registerApp(wxAppid)
    }
    
    func wxCheckAuth(success:snsSuccessHandler,failure:snsFailureHandler?) {
        
        self.whenSuccess = success;
        self.whenfailure = failure;
        
        if (!WXApi.isWXAppInstalled()) {
            Util.showInfo("微信没有安装")
            return;
        }
        
        self.checkToken()
    }
}

//共通
extension OpenidController {
    
    func wxSendAuth(){
        
        var req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = csrf_state
        
        WXApi.sendReq(req)
    }
    
    
    func getConfig()->Openids? {
        
        let config:AnyObject? = Openids.MR_findFirstByAttribute("type", withValue: "wechat")
        
        if let config = config as? Openids where config.access_token != nil && config.openid != nil && config.refresh_token != nil {
            return config
        } else {
            self.wxSendAuth()
        }
        
        return nil
    }
    
    func checkToken() {
        
        if let wxconfig = self.getConfig() {
            
            var param = Dictionary<String, String>()
            
            param["type"] = "wechat"
            param["openid"] = wxconfig.openid!
            param["access_token"] = wxconfig.access_token!
            
            Manager.sharedInstance.request(.POST, tomo_openid_login, parameters: param, encoding: ParameterEncoding.URL)
                .responseJSON { (_, res, JSON, _) in
                    
                    if res?.statusCode == 401 {//token 失效 或token,openid信息不全
                        self.refreshToken()//刷新access_token 延长access_token 有效期
                    } else if res?.statusCode == 404 {//用户不存在 注册
                        //self.getUserInfo()////授权OK 认证成功(access_token 2小时内有效 在有效期)
                        self.showSuccess(param)
                    } else if (res?.statusCode == 200) {
                        let result = JSON as! Dictionary<String, AnyObject>;
                        Defaults["myId"] = result["id"]
                        self.showSuccess(result)
                    }
            }
        }
    }
    
    private func getAccessToken(code:String){
        
        var params = Dictionary<String, String>()
        
        params["code"] = code
        params["appid"] = wxAppid
        params["secret"] = wxAppSecret
        params["grant_type"] = "authorization_code"
        
        Manager.sharedInstance.request(.GET, wx_url_access_token, parameters: params, encoding: ParameterEncoding.URL)
            .responseJSON {(_, _, JSON, _) in
                let result = JSON as! Dictionary<String, AnyObject>;
                if (!contains(result.keys, "errcode")) {
                    self.setCoreDataSNSInfo(result)
                } else {
                    let errcode = result["errcode"] as! Int;
                    let errmsg = result["errmsg"] as! String;
                    self.showError(Int32(errcode), errMessage: errmsg + __FUNCTION__)
                }
        }
    }
    
    private func refreshToken() {
        
        if let wxconfig = self.getConfig() {
            
            var params = Dictionary<String, String>()

            params["appid"] = wxAppid
            params["grant_type"] = "refresh_token"
            params["refresh_token"] = wxconfig.refresh_token!
            
            Manager.sharedInstance.request(.GET, wx_url_refresh_token, parameters: params, encoding: ParameterEncoding.URL)
                .responseJSON { (_, _, JSON, _) in
                    let result = JSON as! Dictionary<String, AnyObject>;
                    
                    if (!contains(result.keys, "errcode")) {
                        self.setCoreDataSNSInfo(result)
                    } else {
                        self.wxSendAuth()
                    }
            }
        }
    }
    
    func getUserInfo(done: (Dictionary<String, AnyObject>?) -> Void) {

        if let wxconfig = self.getConfig() {
            
            var params = Dictionary<String, String>()
            
            params["openid"] = wxconfig.openid!
            params["access_token"] = wxconfig.access_token!
            
            Manager.sharedInstance.request(.GET, wx_url_userinfo, parameters: params, encoding: ParameterEncoding.URL)
                .responseJSON { (_, _, JSON, _) in
                    let result = JSON as! Dictionary<String, AnyObject>;
                    if(!contains(result.keys, "errcode")){
                        assert(NSThread.currentThread().isMainThread, "not main thread")
                        done(result)
                    }else{
                        done(nil)
                    }
            }
        }
    }
    
    func setCoreDataSNSInfo(result:AnyObject){
        if let res = result as? Dictionary<String, AnyObject>{
            
            assert(NSThread.currentThread().isMainThread, "not main thread")
            
            Openids.MR_deleteAllMatchingPredicate(NSPredicate(format: "type = %@ ", "wechat"))
            
            var openids = Openids.MR_createEntity() as! Openids
            openids.openid = result["openid"] as! String?
            openids.access_token = result["access_token"] as! String?
            openids.refresh_token = result["refresh_token"] as! String?
            openids.type = "wechat"
            DBController.save(done: { () -> Void in
                self.checkToken()
            })
        }
    }
    
    func fixShareMessage(img:UIImage,_ description:String)->(UIImage,String?,String?){
        let desc = description.length > 128 ? description[0..<128] :description
        
        return (
            img.scaleToFitSize(CGSize(width: 100, height: 100)),
            desc,
            "@現場TOMO"
        )
    }
    
    /////////////////////////////////////////////////////////
    ///////エラーを表示する/////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    func showError(errCode:Int32,errMessage:String?){
        if let msg = errMessage {
            Util.showInfo(msg)
        }
        self.whenfailure?(errCode:errCode,errMessage:errMessage)
    }
    
    func showSuccess(result: Dictionary<String, AnyObject>){
        Util.dismissHUD()
        self.whenSuccess?(res: result)
    }
}

// MARK: WeiChatDelegate

extension OpenidController: WXApiDelegate {
    
    // WeChat request callback
    func onReq(req:BaseReq){
        if let temp = req as? GetMessageFromWXReq {
            // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
            println(temp.openID)
            
        } else if let temp = req as? ShowMessageFromWXReq {
            let msg = temp.message
            if let obj = msg.mediaObject as? WXAppExtendObject{
                //显示微信传过来的内容
                NSLog("openID: %@, 标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n附加消息:%@\n",
                    temp.openID,
                    msg.title,
                    msg.description,
                    obj.extInfo,
                    msg.thumbData.length,
                    msg.messageExt)
            }
        } else if let temp = req as? LaunchFromWXReq {
            let msg = temp.message
            NSLog("openID: %@, messageExt:%@", temp.openID, msg.messageExt)
        }
    }
    
    // WeChat response callback
    func onResp(resp:BaseResp) {
        
        if let temp = resp as? SendAuthResp {
            if (0 == temp.errCode && csrf_state == temp.state) {
                self.getAccessToken(temp.code)
            } else {
                self.showError(temp.errCode, errMessage: temp.errStr)
            }
        } else {
            
        }
    }
    
}

extension OpenidController{
    func handleOpenURL(url:NSURL)->Bool{
        println(url)
        return WXApi.handleOpenURL(url, delegate: OpenidController.instance)||TencentOAuth.HandleOpenURL(url);
    }
}

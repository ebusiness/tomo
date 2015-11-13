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

let wx_url_userinfo = "https://api.weixin.qq.com/sns/userinfo"
let wx_url_access_token = "https://api.weixin.qq.com/sns/oauth2/access_token"
let wx_url_refresh_token = "https://api.weixin.qq.com/sns/oauth2/refresh_token"

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

    func isWXAppInstalled() -> Bool {
        return WXApi.isWXAppInstalled()
    }

    func wxCheckAuth(success successHandler:snsSuccessHandler,failure failureHandler:snsFailureHandler?) {
        
        self.whenSuccess = successHandler
        self.whenfailure = failureHandler
        
        if (!WXApi.isWXAppInstalled()) {
            Util.showInfo("微信没有安装")
            self.failure(-2, errMessage: "微信没有安装")
        } else {
            if Defaults["openid"].string != nil && Defaults["access_token"].string != nil && Defaults["refresh_token"].string != nil {
                self.checkToken()
            } else {
                self.wxSendAuth()
            }
            
        }
        
    }
}

//共通
extension OpenidController {
    
    private func wxSendAuth(){
        
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = csrf_state
        
        WXApi.sendReq(req)
    }
    
    private func checkToken() {
        
        var param = Dictionary<String, String>()
        
        param["type"] = "wechat"
        param["openid"] = Defaults["openid"].string
        param["access_token"] = Defaults["access_token"].string
        
        AlamofireController.request(.POST, "/signin-wechat", parameters: param, success: { json in
            let result = json as! Dictionary<String, AnyObject>
            self.success(result)
        }) { errCode in
            if errCode == 401 {
                self.refreshAccessToken()
            } else if errCode == 404 {
                self.getUserInfo()
            }
        }
//        Manager.sharedInstance.request(.POST, tomo_openid_login, parameters: param)
//            .responseJSON { (_, res, json, _) in
//                
//                if res?.statusCode == 401 {
//                    self.refreshAccessToken()
//                } else if res?.statusCode == 404 {
//                    self.getUserInfo()
//                } else if (res?.statusCode == 200) {
//                    let result = json as! Dictionary<String, AnyObject>
//                    self.success(result)
//                }
//            }
    }
    
    private func getAccessToken(code:String){
        
        var params = Dictionary<String, String>()
        
        params["code"] = code
        params["appid"] = wxAppid
        params["secret"] = wxAppSecret
        params["grant_type"] = "authorization_code"
        
        Manager.sharedInstance.request(.GET, wx_url_access_token, parameters: params)
            .responseJSON {(_, _, json, _) in
                let result = json as! Dictionary<String, AnyObject>
                
                if (!contains(result.keys, "errcode")) {
                    self.saveOpenId(result)
                    self.checkToken()
                } else {
                    let errcode = result["errcode"] as! Int
                    let errmsg = result["errmsg"] as! String
                    self.failure(Int32(errcode), errMessage: errmsg + __FUNCTION__)
                }
            }
    }
    
    private func refreshAccessToken() {
        
        var params = Dictionary<String, String>()
        
        params["appid"] = wxAppid
        params["grant_type"] = "refresh_token"
        params["refresh_token"] = Defaults["refresh_token"].string
        
        Manager.sharedInstance.request(.GET, wx_url_refresh_token, parameters: params)
            .responseJSON { (_, _, json, _) in
                let result = json as! Dictionary<String, AnyObject>
                
                if (!contains(result.keys, "errcode")) {
                    self.saveOpenId(result)
                    self.checkToken()
                } else {
                    self.wxSendAuth()
                }
            }
    }
    
    private func getUserInfo() {

        var params = Dictionary<String, String>()
        
        params["openid"] = Defaults["openid"].string
        params["access_token"] = Defaults["access_token"].string
        
        Manager.sharedInstance
            .request(.GET, wx_url_userinfo, parameters: params)
            .responseJSON { (_, _, json, _) in
                var result = json as! Dictionary<String, AnyObject>
                
                if (!contains(result.keys, "errcode")) {
                    if let gender = result["sex"] as? String where gender == "2" {
                        result["sex"] = "女"
                    } else {
                        result["sex"] = "男"
                    }
                    
                    AlamofireController.request(.POST, "/signup-wechat", parameters: result, success: { userinfo in
                        if let userinfo = userinfo as? Dictionary<String, AnyObject> {
                            self.success(userinfo)
                        }
                    })
                }
            }
    }
    
    private func saveOpenId(info: Dictionary<String, AnyObject>) {
        Defaults["type"] = "wechat"
        Defaults["openid"] = info["openid"] as! String?
        Defaults["access_token"] = info["access_token"] as! String?
        Defaults["refresh_token"] = info["refresh_token"] as! String?
    }
    
    private func failure(errCode:Int32,errMessage:String?){
        if let msg = errMessage {
            Util.showInfo(msg)
        }
        self.whenfailure?(errCode:errCode,errMessage:errMessage)
    }
    
    private func success(result: Dictionary<String, AnyObject>){
        
        if nil != result["id"] as? String && nil != result["nickName"] as? String {
                
                me = UserEntity(result)
        }
        Util.dismissHUD()
        self.whenSuccess?(res: result)
    }
}


// MARK: Share
extension OpenidController {
    
    /*
    
    scene
    
    
    WXSceneSession  = 0,        /**< 聊天界面    */
    WXSceneTimeline = 1,        /**< 朋友圈      */
    WXSceneFavorite = 2,        /**< 收藏       */
    */
    //share url
    func wxShare(scence:Int32,img:UIImage?,description:String,url:String?){
        
        let message = self.wxGetRequestMesage(img, description: description)
        
        message.mediaTagName = "WECHAT_TAG_JUMP_SHOWRANK";
        
        let ext = WXWebpageObject()
        ext.webpageUrl = url
        message.mediaObject = ext;
        
        self.wxSendReq(message, scence: scence)
    }
    //share app
    func wxShare(scence:Int32,img:UIImage?,description:String,extInfo:String = "info"){
        
        let message = self.wxGetRequestMesage(img, description: description)
        
        
        message.messageExt = extInfo//"附加消息：Come from 現場TOMO" //返回到程序之后用
        message.mediaTagName = "WECHAT_TAG_JUMP_APP";
        //message.messageAction = "<action>\(messageAction)</action>" //不能返回  ..返回到程序之后用
        
        let ext = WXAppExtendObject()
//        ext.extInfo = extInfo //返回到程序之后用
        ext.url = "http://weixin.qq.com";//不设置不能发朋友圈. 虽然设置了,但未安装APP时,并不会访问该地址,而是微信开发者中心中设定的URL.如果没有设定,会打开 weixin.qq.com.
        let buffer:[UInt8] = [0x00, 0xff]
        let data = NSData(bytes: buffer, length: buffer.count)
        ext.fileData = data;
        
        message.mediaObject = ext;
        
        self.wxSendReq(message, scence: scence)
    }
    //get message
    private func wxGetRequestMesage(img:UIImage?,description:String)->WXMediaMessage{
        
        let message = WXMediaMessage()
        
        let (image,title,desc) = self.fixShareMessage(img,description)
        if let image = image {
            message.setThumbImage(image)
        }else{
            message.setThumbImage(UIImage(named: "icon_logo")!)
        }
        message.title = title
        message.description = desc
        
        return message
    }
    
    private func fixShareMessage(img:UIImage?,_ description:String)->(UIImage?,String?,String?){
        let desc = description.length > 128 ? description[0..<128] :description
        
        return (
            img?.scaleToFitSize(CGSize(width: 100, height: 100)),
            desc,
            "@現場TOMO"
        )
    }
    
    //send request
    private func wxSendReq(message:WXMediaMessage,scence:Int32){
        let req = SendMessageToWXReq()
        req.bText = false;
        req.message = message
        req.scene = scence
        
        WXApi.sendReq(req)
    }
}

// MARK: WeiChatDelegate

extension OpenidController: WXApiDelegate {
    
    // WeChat request callback
    func onReq(req:BaseReq){
        if let temp = req as? GetMessageFromWXReq {
            // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
//            println(temp.openID)
            
        } else if let temp = req as? ShowMessageFromWXReq {
            let msg = temp.message
            URLSchemesController.sharedInstance.handleOpenURL(NSURL(string: "tomo://post-new/\(msg.messageExt)")!)
//            if let obj = msg.mediaObject as? WXAppExtendObject {
//                //显示微信传过来的内容
//                NSLog("openID: %@, 标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n附加消息:%@\n",
//                    temp.openID,
//                    msg.title,
//                    msg.description,
//                    obj.extInfo,
//                    msg.thumbData.length,
//                    msg.messageExt)
//            }
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
                self.failure(temp.errCode, errMessage: temp.errStr)
            }
        } else {
            
        }
    }
    
}

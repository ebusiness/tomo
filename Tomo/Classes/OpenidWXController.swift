//
//  SNSWXController.swift
//  spot
//
//  Created by Hikaru on 2015/02/17.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

//WeChat
private let csrf_state = "73746172626f796368696e61"//于防止csrf攻击
private let wxAppid = "wx4079dacf73fef72d"
private let wxAppSecret = "d4ec5214ea3ac56752ff75692fb88f48"


//WeiChatHelper
extension OpenidController {
    func registWX(){
        WXApi.registerApp(wxAppid)
    }
    /////////////////////////////////////////////////////////
    ///////检验授权凭证////////////////////////////////////////
    /////////////////////////////////////////////////////////
    //检验授权凭证（access_token）是否有效
    func wxCheckAuth(success:snsSuccessHandler,failure:snsFailureHandler?){
        self.whenSuccess = success;
        self.whenfailure = failure;
        _isBinding = false;
    
        if(!WXApi.isWXAppInstalled()){
            Util.showInfo("WeiChatはインストールされていません")
            return;
        }
        self.wxCheckToken()
    }
    
    /////////////////////////////////////////////////////////
    ///////请求授权///////////////////////////////////////////
    /////////////////////////////////////////////////////////
    private func wxSendAuth(){
        //WXApi.isWXAppInstalled()
        var req = SendAuthReq()
        req.scope = "snsapi_userinfo" ;
        req.state = csrf_state ;
        WXApi.sendReq(req)
        //授权后 微信会回调  在回调中调用getAccessToken(code:String) 获取access_token及openid
    }
    
    /////////////////////////////////////////////////////////
    ///////获取access_token///////////////////////////////////
    /////////////////////////////////////////////////////////
    
    //获取access_token
    private func getAccessToken(code:String){
        Util.showHUD()
        let wx_url_access_token = "https://api.weixin.qq.com/sns/oauth2/access_token"
        let params = ["appid": wxAppid, "secret": wxAppSecret, "code": code,"grant_type":"authorization_code"]
    
        Manager.sharedInstance.request(.GET, wx_url_access_token, parameters: params, encoding: ParameterEncoding.URL)
            .responseJSON { (_, _, JSON, _) in
                let result = JSON as! Dictionary<String, AnyObject>;
                if(!contains(result.keys, "errcode")){
                    self.setCoreDataSNSInfo(result)
                }else{
                    let errcode = result["errcode"] as! Int;
                    let errmsg = result["errmsg"] as! String;
                    self.showError(Int32(errcode), errMessage: errmsg + __FUNCTION__)
                }
        }
    }
    
    /////////////////////////////////////////////////////////
    ///////刷新或续期access_token/////////////////////////////
    /////////////////////////////////////////////////////////
    //刷新或续期access_token
    private func refreshToken(){
        let wx_url_refresh_token = "https://api.weixin.qq.com/sns/oauth2/refresh_token"
        
        if let wxconfig = self.getWxConfig(){
            let params = ["appid": wxAppid, "grant_type": "refresh_token", "refresh_token": wxconfig.refresh_token! ]
            
            Manager.sharedInstance.request(.GET, wx_url_refresh_token, parameters: params, encoding: ParameterEncoding.URL)
                .responseJSON { (_, _, JSON, _) in
                    let result = JSON as! Dictionary<String, AnyObject>;
                    if(!contains(result.keys, "errcode")){
                        self.setCoreDataSNSInfo(result)
                    }else{
                        self.wxSendAuth()
                    }
            }
        }
    }
    
    /////////////////////////////////////////////////////////
    ///////获取用户个人信息（UnionID机制）///////////////////////
    /////////////////////////////////////////////////////////
    func getWechatUserInfo(done: (Dictionary<String, AnyObject>?) -> Void){
        let wx_url_userinfo = "https://api.weixin.qq.com/sns/userinfo"
        if let wxconfig = self.getWxConfig(){
            let params = ["access_token": wxconfig.access_token!, "openid": wxconfig.openid!]
            Manager.sharedInstance.request(.GET, wx_url_userinfo, parameters: params, encoding: ParameterEncoding.URL)
                .responseJSON { (_, _, JSON, _) in
                    let result = JSON as! Dictionary<String, AnyObject>;
                    if(!contains(result.keys, "errcode")){
                        assert(NSThread.currentThread().isMainThread, "not main thread")
                        done(result)
                    }else{
                        done(nil)
//                        let errcode = result["errcode"] as! Int;
//                        let errmsg = result["errmsg"] as! String;
                    }
            }
        }
    }
    //WeChat Openid Info
    private func getWxConfig()->Openids?{
        if let wxconfig = self.getConfig(.WeChat){
            return wxconfig
        }else{
            self.wxSendAuth()
        }
        return nil
    }
    private func wxCheckToken(){// サーバ側のチェック
        if let wxconfig = self.getWxConfig(){
            if _isBinding {
                self.binding(.WeChat, openid: wxconfig.openid!, access_token: wxconfig.access_token!, refresh_token: wxconfig.refresh_token, expirationDate: nil)
            }else {
                self.checkToken(openid: wxconfig.openid!, token: wxconfig.access_token!, type: .WeChat, done: { (statusCode,openidinfo) -> Void in
                    
                    if statusCode == 401 {//token 失效 或token,openid信息不全
                        self.refreshToken()//刷新access_token 延长access_token 有效期
                    }else if statusCode == 404 {//用户不存在 注册
                        //self.getUserInfo()////授权OK 认证成功(access_token 2小时内有效 在有效期)
                        self.showSuccess(openidinfo)
                    }
                })
            }
            
//            let wx_url_auth = "https://api.weixin.qq.com/sns/auth"
//            Manager.sharedInstance.request(.GET, wx_url_auth, parameters: params, encoding: ParameterEncoding.URL)
//                .responseJSON { (_, _, JSON, _) in
//                    let result = JSON as! Dictionary<String, AnyObject>;
//                    let errcode = result["errcode"] as! Int;
//                    let errmsg = result["errmsg"] as! String;
//                    if(0 == errcode){//授权OK 认证成功(access_token 2小时内有效 在有效期)
//                        self.getUserInfo()
//                    }else{
//                        self.refreshToken()//刷新access_token 延长access_token 有效期
//                    }
//            }
        }

    }
}



//Share
extension OpenidController {
    
    /*
    
    scene
    
    
    WXSceneSession  = 0,        /**< 聊天界面    */
    WXSceneTimeline = 1,        /**< 朋友圈      */
    WXSceneFavorite = 2,        /**< 收藏       */
    */
    func wxShare(scence:Int32,title:String,description:String){
        let message = WXMediaMessage()
        message.title = title //"現場TOMO　招待"
        message.description = description //"招待メッセージ。。。。。。。。。。。"
        message.setThumbImage(UIImage(named: "icon_logo"))
        

        message.messageExt = "附加消息：Come from 現場TOMO" //点击之后 返回到程序之后用
        message.messageAction = "<action>dotaliTest</action>" //点击之后 返回到程序之后用
        
        let ext = WXAppExtendObject()
        ext.extInfo = "<xml>附带信息附带信息附带信息</xml>" //点击之后 返回到程序之后用
        //ext.url = url  //设定了也无效 未安装APP的时候 会打开 微信开发者中心中 设定的 URL 如果没有设定 会打开 weixin.qq.com
        // 由于还没有上线 暂时设定为 案件通 的下载地址
        
        
        let buffer: [UInt8] = [0x00, 0xff]
        let data = NSData(bytes: buffer, length: buffer.count)
        
        ext.fileData = data;
        
        message.mediaObject = ext;
        
        
        let req = SendMessageToWXReq()
        req.bText = false;
        req.message = message
        
        req.scene = scence
        
        WXApi.sendReq(req)
        
    }
}

//WeiChatDelegate
extension OpenidController: WXApiDelegate {
    /////////////////////////////////////////////////////////
    ///////WXApiDelegate/////////////////////////////////////
    /////////////////////////////////////////////////////////
    //微信的请求
    func onReq(req:BaseReq){
        if let temp = req as? GetMessageFromWXReq {
            // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
            println(temp.openID)
            
        }else if let temp = req as? ShowMessageFromWXReq{
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
        }else if let temp = req as? LaunchFromWXReq{
            let msg = temp.message
            NSLog("openID: %@, messageExt:%@", temp.openID, msg.messageExt)
        }
    }
    //微信的回调
    func onResp(resp:BaseResp){
        if let temp = resp as? SendAuthResp{
            if(0 == temp.errCode && csrf_state == temp.state){
                //NSLog("code:%@,state:%@,errcode:%d", temp.code, temp.state, temp.errCode)
                self.getAccessToken(temp.code)
            }else{
                self.showError(temp.errCode, errMessage: temp.errStr)
            }
        }else if let temp = resp as? SendMessageToWXResp{//发送媒体消息结果
            NSLog("errcode:%d", resp.errCode)
            
        }else if let temp = resp as? AddCardToWXCardPackageResp{//微信返回第三方添加卡券结果
            for cardItem in temp.cardAry {
                NSLog("cardid:%@ cardext:%@ cardstate:%lu\n",cardItem.cardId,cardItem.extMsg,cardItem.cardState)
            }
        }
    }
    
}

//binding
extension OpenidController {
    func wxBinding(success:snsSuccessHandler,failure:snsFailureHandler?){
        
        self.whenSuccess = success;
        self.whenfailure = failure;
        _isBinding = true;
        
        if(!WXApi.isWXAppInstalled()){
            Util.showInfo("WeiChatはインストールされていません")
            return;
        }
        self.wxCheckToken()
    }
}

//setCoreData
extension OpenidController{
    func setCoreDataSNSInfo(result:AnyObject){
        if let res = result as? Dictionary<String, AnyObject>{
            assert(NSThread.currentThread().isMainThread, "not main thread")
            
            var openids = Openids.MR_createEntity() as! Openids
            openids.openid = result["openid"] as! String?
            openids.access_token = result["access_token"] as! String?
            openids.refresh_token = result["refresh_token"] as! String?
            openids.type = OpenIDRequestType.WeChat.toString()
            DBController.save(done: { () -> Void in
                self.wxCheckToken()
            })
        }
    }
}
//
//  SNSQQController.swift
//  spot
//
//  Created by Hikaru on 2015/02/17.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

//QQ
private let appid = "1103821830"
private var _tencentOAuth :TencentOAuth?
private typealias OpenidUserInfoAction = (Dictionary<String, AnyObject>?) -> Void
private var _done: OpenidUserInfoAction?
//WeiChatHelper
extension OpenidController {
    
    func registQQ(){
        _tencentOAuth = TencentOAuth(appId: appid, andDelegate: self)
        
        if let qqconfig = self.getConfig(.QQ){
            _tencentOAuth?.accessToken =  qqconfig.access_token
            _tencentOAuth?.openId = qqconfig.openid
            _tencentOAuth?.expirationDate = qqconfig.expirationDate

        }
    }
    func qqCheckAuth(success:snsSuccessHandler,failure:snsFailureHandler?){
        self.whenSuccess = success;
        self.whenfailure = failure;
        _isBinding = false;
        self.qqCheckToken();
    }
    
    private func qqCheckToken(){// サーバ側のチェック
        Util.showHUD()
        if let accessToken = _tencentOAuth?.accessToken,openid = _tencentOAuth?.openId{
            if ( "" != accessToken && "" != openid)
            {
                if _isBinding {
                    self.binding(.QQ,openid:_tencentOAuth?.openId!, access_token: _tencentOAuth?.accessToken!, refresh_token: nil, expirationDate: _tencentOAuth?.expirationDate)
                }else {
                    //_tencentOAuth?.getUserInfo()
                    self.checkToken(openid: openid, token: accessToken, type: .QQ, done: { (statusCode,openidinfo) -> Void in
                        if statusCode == 401 {//token 失效 或token,openid信息不全
                            self.qqSendAuth()
                        }else if statusCode == 404 {//用户不存在 注册
                            //self.getUserInfo()////授权OK 认证成功(access_token 2小时内有效 在有效期)
                            self.showSuccess(openidinfo)
                        }
                    })
                }
                return;
            }
        }
        self.qqSendAuth()
    }
    
    private func qqSendAuth(){
        let _permissions = [
            kOPEN_PERMISSION_GET_USER_INFO,
            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
            kOPEN_PERMISSION_GET_OTHER_INFO,
        ];
        _tencentOAuth?.authorize(_permissions, inSafari: false)
    }
    
    //save QQ OpenidInfo
    func saveQQ(){
        
        let accessToken = _tencentOAuth?.accessToken
        if (accessToken != nil && "" != accessToken){
            assert(NSThread.currentThread().isMainThread, "not main thread")
            
            var openids = Openids.MR_createEntity() as! Openids
            openids.openid = _tencentOAuth?.openId
            openids.access_token = _tencentOAuth?.accessToken
            openids.expirationDate =  _tencentOAuth?.expirationDate
            openids.type = OpenIDRequestType.QQ.toString()
            DBController.save(done: { () -> Void in
                println("saved")
            })
        }
    }
}


//binding
extension OpenidController {
    func qqBinding(success:snsSuccessHandler,failure:snsFailureHandler?){
        self.whenSuccess = success;
        self.whenfailure = failure;
        
        _isBinding = true;
        self.qqSendAuth()
    }
    func getQQUserInfo(done: (Dictionary<String, AnyObject>?) -> Void){
        _done = done;
        _tencentOAuth?.getUserInfo()
    }
}

//Share
extension OpenidController {
    
    /*
    分享到QQ
    0,        /**< 聊天界面    */
    1,        /**< 空间      */
    */
    func qqShare(scence:Int32,img:UIImage,description:String,url:String?){
        
        var uri:NSURL
        if let u = url {
            uri = NSURL(string: u)!
        }else{
            uri = NSURL(string: "genbatomo://main")!
        }
        
        let (image,title,desc) = self.fixShareMessage(img,description)
        let data = UIImagePNGRepresentation(image)
        
        let newsObj = QQApiNewsObject(URL: uri, title: title, description: desc, previewImageData: data, targetContentType: QQApiURLTargetTypeNews)
    
        let req = SendMessageToQQReq(content: newsObj)
        
        if 1 == scence{//空间
            QQApiInterface.SendReqToQZone(req)
        }else{ // 好友
            QQApiInterface.sendReq(req)
        }
    }
}

//WeiChatDelegate
extension OpenidController: TencentSessionDelegate {
    /////////////////////////////////////////////////////////
    ///////QQ委托/////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    internal func tencentDidLogin() {
        NSLog("登录完成");
        let accessToken = _tencentOAuth?.accessToken
        if (accessToken != nil && "" != accessToken)
        {
            self.qqCheckToken();
            //_tencentOAuth?.getUserInfo()
        }
        else
        {
            self.showError(-1, errMessage:"No Accesstoken")
            //NSLog("登录不成功 没有获取accesstoken");
        }
    }
    
    
    /**
    * Called when the user dismissed the dialog without logging in.
    */
    internal func tencentDidNotLogin(cancelled:Bool)
    {
        if (cancelled){
            self.showError(-2, errMessage:"キャンセルされました")
        }
        else {
            self.showError(-3, errMessage:"ログイン出来なかった")
        }
        
    }
    
    /**
    * Called when the notNewWork.
    */
    internal func tencentDidNotNetWork()
    {
        self.showError(-4, errMessage:"ネットワークに接続してください")
    }
    
    /**
    * Called when the logout.
    */
    internal func tencentDidLogout()
    {
        self.showError(-5, errMessage:"ログアウトしました")
    }
    
    internal func getUserInfoResponse(response: APIResponse!) {
        let res = response.jsonResponse as! Dictionary<String, AnyObject>;
        let ret = res["ret"] as! Int;
        if(0 != ret ){// -23 token is invalid
            _tencentOAuth?.accessToken = "";
            _done?(nil);
        }else{
            assert(NSThread.currentThread().isMainThread, "not main thread")
            _done?(res)
        }
    }
}
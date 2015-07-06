//
//  SNSWXController.swift
//  spot
//
//  Created by Hikaru on 2015/02/17.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

//WeChat
//private let csrf_state = "73746172626f796368696e61"//于防止csrf攻击
//private let wxAppid = "wx4079dacf73fef72d"
//private let wxAppSecret = "d4ec5214ea3ac56752ff75692fb88f48"


//Share
extension OpenidController {
    
    /*
    
    scene
    
    
    WXSceneSession  = 0,        /**< 聊天界面    */
    WXSceneTimeline = 1,        /**< 朋友圈      */
    WXSceneFavorite = 2,        /**< 收藏       */
    */
    //share url
    func wxShare(scence:Int32,img:UIImage,description:String,url:String?){
        
        let message = self.wxGetRequestMesage(img, description: description)
        
        message.mediaTagName = "WECHAT_TAG_JUMP_SHOWRANK";
        
        let ext = WXWebpageObject()
        ext.webpageUrl = url
        message.mediaObject = ext;
        
        self.wxSendReq(message, scence: scence)
    }
    //share app
    func wxShare(scence:Int32,img:UIImage,description:String,extInfo:String = "info"){
  
        let message = self.wxGetRequestMesage(img, description: description)
        
        
        message.messageExt = "附加消息：Come from 現場TOMO" //返回到程序之后用
        message.mediaTagName = "WECHAT_TAG_JUMP_APP";
        //message.messageAction = "<action>\(messageAction)</action>" //不能返回  ..返回到程序之后用
        
        let ext = WXAppExtendObject()
        ext.extInfo = "<xml>\(extInfo)</xml>" //返回到程序之后用
        ext.url = "http://weixin.qq.com";//不设置 不能发朋友圈 设置了也没有作用  未安装APP的时候 会打开 微信开发者中心中 设定的 URL 如果没有设定 会打开 weixin.qq.com
        let buffer:[UInt8] = [0x00, 0xff]
        let data = NSData(bytes: buffer, length: buffer.count)
        ext.fileData = data;
        
        message.mediaObject = ext;
        
        self.wxSendReq(message, scence: scence)
    }
    //get message
    private func wxGetRequestMesage(img:UIImage,description:String)->WXMediaMessage{
        
        let message = WXMediaMessage()
        
        let (image,title,desc) = self.fixShareMessage(img,description)
        
        message.setThumbImage(image)
        message.title = title
        message.description = desc

        return message
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

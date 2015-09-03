//
//  Constants.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

let kTomoService = "jp.co.e-business.tomo"
let kTomoPushToken = "token.push.tomo"
#if DEBUG
    let AmazonS3Bucket = "tomo-dev"
    let kAPIBaseURLString = "http://192.168.11.90:81"
    let SocketPort = "81"
#else
    let AmazonS3Bucket = "tomo-test"
    let kAPIBaseURLString = "http://tomo.e-business.co.jp"
    let SocketPort = "80"
#endif

let kS3BasePath = "https://s3-ap-northeast-1.amazonaws.com"

let kAPIBaseURL = NSURL(string: kAPIBaseURLString)

let MaxWidth: CGFloat = 500
let AvatarMaxWidth: CGFloat = 200
let GroupImageWidth: CGFloat = 80

let NavigationBarColorHex:UInt = 0x2196F3

let DefaultAvatarImage = UIImage(named: "avatar")!

class Constants: NSObject {
   
    class func postPath(#fileName: String) -> String {
        return "/users/\(me.id)/post/\(fileName)"
    }
    
    class func avatarPath(#fileName: String) -> String {
        return "/users/\(me.id)/photo/\(fileName)"
    }
    
    class func coverPath(#fileName: String) -> String {
        return "/users/\(me.id)/cover/\(fileName)"
    }
    
    class func groupCoverPath(#groupId: String, fileName: String) -> String {
        return "/groups/\(groupId)/cover/\(fileName)"
    }

}

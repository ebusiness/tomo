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
    let kAPIBaseURLString = "https://tomo.e-business.co.jp:81"
//    let kAPIBaseURLString = "https://192.168.11.93:81"
//    let kAPIBaseURLString = "https://192.168.11.83:81"
#else
    let AmazonS3Bucket = "tomo-test"
    let kAPIBaseURLString = "https://tomo.e-business.co.jp"
#endif

let kS3BasePath = "https://s3-ap-northeast-1.amazonaws.com"
let kDateFormat = "yyyy-MM-dd't'HH:mm:ss.SSSZ"

let kAPIBaseURL = NSURL(string: kAPIBaseURLString)

let MaxWidth: CGFloat = 500
let AvatarMaxWidth: CGFloat = 200
let GroupImageWidth: CGFloat = 80

let NavigationBarColorHex:UInt = 0x2196F3
let avatarBorderColor = Util.UIColorFromRGB(0xE0E0E0, alpha: 1).CGColor

let DefaultAvatarImage = UIImage(named: "avatar")!

class Constants: NSObject {
   
    class func postPath(#fileName: String) -> String {
        return "/users/\(me.id)/post/\(fileName)"
    }
    
    class func avatarPath() -> String {
        return "/users/\(me.id)/photo.png"
    }
    
    class func coverPath() -> String {
        return "/users/\(me.id)/cover.png"
    }
    
    class func groupCoverPath(#groupId: String) -> String {
        return "/groups/\(groupId)/cover.png"
    }

}

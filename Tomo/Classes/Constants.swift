//
//  Constants.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

let kTomoService = "jp.co.e-business.tomo"
#if DEBUG
    let AmazonS3Bucket = "genbatomopics"
    let kAPIBaseURLString = "http://tomo.e-business.co.jp:81"
    let SocketPort = "81"
#else
    let AmazonS3Bucket = "genbatomopics-test"
    let kAPIBaseURLString = "http://tomo.e-business.co.jp"
    let SocketPort = "80"
#endif

let kAPIBaseURL = NSURL(string: kAPIBaseURLString)

let MaxWidth = 500
let AvatarMaxWidth = 200
let GroupImageWidth: CGFloat = 80

let mapPath = kAPIBaseURLString + "/mobile/map"

let DefaultAvatarImage = UIImage(named: "avatar")!

//birthday
let kBirthdayDefault = NSDate(fromString: "1980/01/01", format: DateFormat.Custom("yyyy/MM/dd"))
//min
let kBirthdayMin = NSDate(fromString: "1940/01/01", format: DateFormat.Custom("yyyy/MM/dd"))
//max
let kBirthdayMax = NSDate()

class Constants: NSObject {
   
    class func postPath(#fileName: String) -> String {
        let myId = Defaults["myId"].string!
        return "/users/\(myId)/post/\(fileName)"
    }
    
    class func avatarPath(#fileName: String) -> String {
        let myId = Defaults["myId"].string!
        return "/users/\(myId)/photo/\(fileName)"
    }
}

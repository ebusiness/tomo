//
//  Constants.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

let kTomoService = "jp.co.e-business.tomo"

//let kAPIBaseURLString = "http://new.selink.jp"
let kAPIBaseURLString = "http://tomo.e-business.co.jp:81"

let kAPIBaseURL = NSURL(string: kAPIBaseURLString)

let MaxWidth = 500
let AvatarMaxWidth = 200

let mapPath = kAPIBaseURLString + "/mobile/map"

//let BackgroundSessionUploadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.uploadSession"
//let BackgroundSessionDownloadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.downloadSession"


let DefaultAvatarImage = UIImage(named: "avatar")!

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

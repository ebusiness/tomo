//
//  Constants.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

struct TomoConfig {

#if DEBUG
    struct Api {

        static let Protocol = "https"
        static let Domain = "192.168.11.98"

        static var Url: String {
            return "\(self.Protocol)://\(self.Domain)"
        }
    }

    struct AWS {
        struct S3 {
            static let Url = "https://s3-ap-northeast-1.amazonaws.com"
            static let Bucket = "tomo-dev"
        }
    }
#else
    struct Api {

        static let Protocol = "https"
        static let Domain = "api.genbatomo.com"

        static var Url: String {
            return "\(self.Protocol)://\(self.Domain)"
        }
    }

    struct AWS {
        struct S3 {
            static let Url = "https://s3-ap-northeast-1.amazonaws.com"
            static let Bucket = "tomo-prod"
        }
    }
#endif

    struct Date {
        static let Format = "yyyy-MM-dd't'HH:mm:ss.SSSZ"
    }

    struct Util {
        
    }
}

//let kDateFormat = "yyyy-MM-dd't'HH:mm:ss.SSSZ"

let MaxWidth: CGFloat = 500

let NavigationBarColorHex:UInt = 0x2196F3
let avatarBorderColor = UIColor.whiteColor().CGColor

let DefaultAvatarImage = UIImage(named: "avatar")!
let DefaultCoverImage = UIImage(named: "user_cover_default")!
let DefaultGroupImage = UIImage(named: "group_cover_default")!

class Constants: NSObject {
   
    class func postPath(fileName name: String) -> String {
        return "/users/\(me.id)/post/\(name)"
    }
    
    class func avatarPath() -> String {
        return "/users/\(me.id)/photo.png"
    }
    
    class func coverPath() -> String {
        return "/users/\(me.id)/cover.png"
    }
    
    class func groupCoverPath(groupId id: String) -> String {
        return "/groups/\(id)/cover.png"
    }

}

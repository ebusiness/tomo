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
    let AmazonS3Bucket = "genbatomopics"
    let kAPIBaseURLString = "http://tomo.e-business.co.jp:81"
    let SocketPort = "81"
#else
    let AmazonS3Bucket = "genbatomopics-test"
    let kAPIBaseURLString = "http://tomo.e-business.co.jp"
    let SocketPort = "80"
#endif

let kS3BasePath = "https://s3-ap-northeast-1.amazonaws.com"

let kAPIBaseURL = NSURL(string: kAPIBaseURLString)

let MaxWidth: CGFloat = 500
let AvatarMaxWidth: CGFloat = 200
let GroupImageWidth: CGFloat = 80

let NavigationBarColorHex:UInt = 0xFF5722

let DefaultAvatarImage = UIImage(named: "avatar")!

enum MediaMessage: Int {
    case Image, Voice, Video
    
    static let medias = [Image, Voice, Video]
    
    static func isMediaMessage(str: String) -> Bool {
        for media in medias {
            if str.hasPrefix(media.messagePrefix) {
                return true
            }
        }
        return false
    }
    
    static func mediaMessage(str: String) -> MediaMessage? {
        for media in medias {
            if str.hasPrefix(media.messagePrefix) {
                return media
            }
        }
        
        return nil
    }
    
    static func fileNameOfMessage(str: String) -> String? {
        for media in medias {
            if str.hasPrefix(media.messagePrefix) {
                return str.substringFromIndex(advance(str.startIndex, media.messagePrefix.length))
            }
        }
        return nil
    }
    
    static func messagePrefix(str: String) -> String? {
        return mediaMessage(str)?.messagePrefix
    }
    
    var messagePrefix: String {
        get {
            switch self {
            case .Image:
                return "[画像]"
            case .Voice:
                return "[音声]"
            case .Video:
                return "[動画]"
            }
        }
    }
    
    static func remotePath(#fileName: String, type: MediaMessage) -> String {
        switch type {
        case .Image:
            return "/messages/images/\(fileName)"
        case .Voice:
            return "/messages/voices/\(fileName)"
        case .Video:
            return "/messages/videos/\(fileName)"
        }
    }
    
    static func mediaMessageStr(#fileName: String, type: MediaMessage) -> String {
        return "\(type.messagePrefix)\(fileName)"
    }
    
    static func fullPath(str: String) -> String {
        return kS3BasePath.stringByAppendingPathComponent(AmazonS3Bucket).stringByAppendingPathComponent(remotePath(fileName: fileNameOfMessage(str)!, type: mediaMessage(str)!))
    }
    
    static func fullPath(#fileName: String, type: MediaMessage) -> String {
        return kS3BasePath.stringByAppendingPathComponent(AmazonS3Bucket).stringByAppendingPathComponent(remotePath(fileName: fileName, type: type))
    }
}

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

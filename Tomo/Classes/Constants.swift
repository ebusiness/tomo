//
//  Constants.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

//let kAPIBaseURLString = "http://new.selink.jp"
let kAPIBaseURLString = "http://tomo.e-business.co.jp"

let kAPIBaseURL = NSURL(string: kAPIBaseURLString)


// MARK: - S3

let CognitoRegionType = AWSRegionType.Unknown
let DefaultServiceRegionType = AWSRegionType.APNortheast1
//let CognitoIdentityPoolId: String = "YourPoolID"
let S3BucketName: String = "genbatomopics"
//let S3DownloadKeyName: String = "uploadfileswift.txt"

let BackgroundSessionUploadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.uploadSession"
let BackgroundSessionDownloadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.downloadSession"


class Constants: NSObject {
   
}

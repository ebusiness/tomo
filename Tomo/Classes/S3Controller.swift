//
//  S3Controller.swift
//  S3BackgroundTransferSampleSwift
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 Amazon. All rights reserved.
//

import UIKit
import Alamofire

class S3Controller: NSObject {

    @discardableResult
    class func uploadFile(localPath: String, remotePath: String, done: @escaping (Error?) -> Void) -> UploadRequest {
        let amazonS3Manager = AmazonS3RequestManager(bucket: TomoConfig.AWS.S3.Bucket,
            region: .APNortheast1,
            accessKey: AmazonS3AccessKey,
            secret: AmazonS3Secret)
        
        return amazonS3Manager.putObject(fileURL: URL(fileURLWithPath: localPath), destinationPath: remotePath, done: {(error) in
            done(error)
        })
    }
}



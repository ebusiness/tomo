//
//  S3Controller.swift
//  S3BackgroundTransferSampleSwift
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 Amazon. All rights reserved.
//

import UIKit

class S3Controller: NSObject {

    class func uploadFile(#name: String, path: String, done: (NSError?) -> Void) {
        let amazonS3Manager = AmazonS3RequestManager(bucket: AmazonS3Bucket,
            region: .APNortheast1,
            accessKey: AmazonS3AccessKey,
            secret: AmazonS3Secret)
        
        amazonS3Manager.putObject(NSURL(fileURLWithPath: path)!, destinationPath: Constants.postPath(fileName: name), done: {(error) in
            done(error)
        })
    }
    
//    class func uploadData(data: NSData, done: ((NSError?) -> Void)?) {
//        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
//        getPreSignedURLRequest.bucket = S3BucketName
//        getPreSignedURLRequest.key = NSUUID().UUIDString
//        getPreSignedURLRequest.HTTPMethod = AWSHTTPMethod.PUT
//        getPreSignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600)
//        
//        //Important: must set contentType for PUT request
//        let fileContentTypeStr = "text/plain"
//        getPreSignedURLRequest.contentType = fileContentTypeStr
//        
//        
//        AWSS3PreSignedURLBuilder.defaultS3PreSignedURLBuilder().getPreSignedURL(getPreSignedURLRequest) .continueWithBlock { (task:BFTask!) -> (AnyObject!) in
//            
//            if (task.error != nil) {
//                NSLog("Error: %@", task.error)
//            } else {
//                
//                let presignedURL = task.result as NSURL!
//                if (presignedURL != nil) {
//                    NSLog("upload presignedURL is: \n%@", presignedURL)
//                    
//                    var request = NSMutableURLRequest(URL: presignedURL)
//                    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
//                    request.HTTPMethod = "PUT"
//                    
//                    //contentType in the URLRequest must be the same as the one in getPresignedURLRequest
//                    request.setValue(fileContentTypeStr, forHTTPHeaderField: "Content-Type")
//                    
//                    let uploadFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory() + NSUUID().UUIDString)!
//                    
//                    if NSFileManager.defaultManager().fileExistsAtPath(uploadFileURL.path!) {
//                        NSFileManager.defaultManager().removeItemAtPath(uploadFileURL.path!, error:nil)
//                    }
//                    
//                    data.writeToURL(uploadFileURL, atomically: true)
//
//                    self.uploadTask = self.session?.uploadTaskWithRequest(request, fromFile: uploadFileURL)
//                    
//                    println(self.uploadTask)
//                    self.uploadTask?.resume()
//                    
//                }
//            }
//            return nil;
//            
//        }
//    }
}



//
//  S3Controller.swift
//  S3BackgroundTransferSampleSwift
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 Amazon. All rights reserved.
//

import UIKit

class S3Controller: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
   
    var session: NSURLSession?
    var uploadTask: NSURLSessionUploadTask?
    var done: ((NSError?) -> Void)?
    
    class var instance : S3Controller {
        struct Static {
            static let instance : S3Controller = S3Controller()
        }
        
        return Static.instance
    }
    
    override init() {
        super.init()
        
        setup()
        
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(BackgroundSessionUploadIdentifier)
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    

    
    private func setup() {
//        let credentialProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
//            CognitoRegionType,
//            identityPoolId: CognitoIdentityPoolId)
        
        let provider:AWSStaticCredentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIAIX5BK7WNTALYXFSQ",secretKey: "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")
        let configuration = AWSServiceConfiguration(
            region: DefaultServiceRegionType,
            credentialsProvider: provider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
    
    func uploadData(data: NSData, done: ((NSError?) -> Void)?) {
        
        if (self.uploadTask != nil) {
            return;
        }
        
        self.done = done
        
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.bucket = S3BucketName
        getPreSignedURLRequest.key = NSUUID().UUIDString
        getPreSignedURLRequest.HTTPMethod = AWSHTTPMethod.PUT
        getPreSignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600)
        
        //Important: must set contentType for PUT request
        let fileContentTypeStr = "text/plain"
        getPreSignedURLRequest.contentType = fileContentTypeStr
        
        
        AWSS3PreSignedURLBuilder.defaultS3PreSignedURLBuilder().getPreSignedURL(getPreSignedURLRequest) .continueWithBlock { (task:BFTask!) -> (AnyObject!) in
            
            if (task.error != nil) {
                NSLog("Error: %@", task.error)
            } else {
                
                let presignedURL = task.result as NSURL!
                if (presignedURL != nil) {
                    NSLog("upload presignedURL is: \n%@", presignedURL)
                    
                    var request = NSMutableURLRequest(URL: presignedURL)
                    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
                    request.HTTPMethod = "PUT"
                    
                    //contentType in the URLRequest must be the same as the one in getPresignedURLRequest
                    request.setValue(fileContentTypeStr, forHTTPHeaderField: "Content-Type")
                    
                    let uploadFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory() + NSUUID().UUIDString)!
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(uploadFileURL.path!) {
                        NSFileManager.defaultManager().removeItemAtPath(uploadFileURL.path!, error:nil)
                    }
                    
                    data.writeToURL(uploadFileURL, atomically: true)

                    self.uploadTask = self.session?.uploadTaskWithRequest(request, fromFile: uploadFileURL)
                    
                    println(self.uploadTask)
                    self.uploadTask?.resume()
                    
                }
            }
            return nil;
            
        }

    }
 
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        NSLog("UploadTask progress: %lf", progress)
        
        dispatch_async(dispatch_get_main_queue()) {
//            self.progressView.progress = progress
//            self.statusLabel.text = "Uploading..."
        }
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if let done = done {
            dispatch_async(dispatch_get_main_queue()) {
                done(error)
            }
        }
        
        if (error == nil) {
//            dispatch_async(dispatch_get_main_queue()) {
//                self.statusLabel.text = "Upload Successfully"
//            }
            NSLog("S3 UploadTask: %@ completed successfully", task);
        } else {
//            dispatch_async(dispatch_get_main_queue()) {
//                self.statusLabel.text = "Upload Failed"
//            }
            NSLog("S3 UploadTask: %@ completed with error: %@", task, error!.localizedDescription);
        }
        
        dispatch_async(dispatch_get_main_queue()) {
//            self.progressView.progress = Float(task.countOfBytesSent) / Float(task.countOfBytesExpectedToSend)
        }
        
        self.uploadTask = nil
        
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if ((appDelegate.backgroundUploadSessionCompletionHandler) != nil) {
            let completionHandler:() = appDelegate.backgroundUploadSessionCompletionHandler!;
            appDelegate.backgroundUploadSessionCompletionHandler = nil
            completionHandler
        }
        
        NSLog("Completion Handler has been invoked, background upload task has finished.");
    }
}



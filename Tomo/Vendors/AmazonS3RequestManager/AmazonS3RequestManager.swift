//
// AmazonS3RequestManager.swift
// AmazonS3RequestManager
//
// Based on `AFAmazonS3Manager` by `Matt Thompson`
//
// Created by Anthony Miller. 2015.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Alamofire
import MobileCoreServices

/**
 * MARK: Information
 */

/**
 MARK: Error Domain
 The Error Domain for `ZRAPI`
 */
private let AmazonS3RequestManagerErrorDomain = "com.AmazonS3RequestManager"

/**
 MARK: Error Codes
 The error codes for the `AmazonS3RequestManagerErrorDomain`
 - AccessKeyMissing: The `accessKey` for the request manager is `nil`. The `accessKey` must be set in order to make requests with `AmazonS3RequestManager`.
 - SecretMissing: The secret for the request manager is `nil`. The secret must be set in order to make requests with `AmazonS3RequestManager`.
 */
public enum AmazonS3RequestManagerErrorCodes: Int {
    
    case AccessKeyMissing = 1,
    SecretMissing
    
}

/**
 MARK: Amazon S3 Regions
 The possible Amazon Web Service regions for the client.
 - USStandard:   N. Virginia or Pacific Northwest
 - USWest1:      Oregon
 - USWest2:      N. California
 - EUWest1:      Ireland
 - EUCentral1:   Frankfurt
 - APSoutheast1: Singapore
 - APSoutheast2: Sydney
 - APNortheast1: Toyko
 - SAEast1:      Sao Paulo
 */
public enum AmazonS3Region: String {
    case USStandard = "s3.amazonaws.com",
    USWest1 = "s3-us-west-1.amazonaws.com",
    USWest2 = "s3-us-west-2.amazonaws.com",
    EUWest1 = "s3-eu-west-1.amazonaws.com",
    EUCentral1 = "s3-eu-central-1.amazonaws.com",
    APSoutheast1 = "s3-ap-southeast-1.amazonaws.com",
    APSoutheast2 = "s3-ap-southeast-2.amazonaws.com",
    APNortheast1 = "s3-ap-northeast-1.amazonaws.com",
    SAEast1 = "s3-sa-east-1.amazonaws.com"
}

/**
 MARK: AmazonS3RequestManager
 `AmazonS3RequestManager` is a subclass of `Manager` that encodes requests to the Amazon S3 service.
 */
public class AmazonS3RequestManager {
    
    /**
     MARK: Instance Properties
     */
    
    /**
     The Amazon S3 Bucket for the client
     */
    public var bucket: String?
    
    /**
     The Amazon S3 region for the client. `AmazonS3Region.USStandard` by default.
     
     :note: Must not be `nil`.
     
     :see: `AmazonS3Region` for defined regions.
     */
    public var region: AmazonS3Region = .USStandard
    
    /**
     The Amazon S3 Access Key ID used to generate authorization headers and pre-signed queries
     
     :dicussion: This can be found on the AWS control panel: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
     */
    public var accessKey: String?
    
    /**
     The Amazon S3 Secret used to generate authorization headers and pre-signed queries
     
     :dicussion: This can be found on the AWS control panel: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
     */
    public var secret: String?
    
    /**
     The AWS STS session token. `nil` by default.
     */
    public var sessionToken: String?
    
    /**
     Whether to connect over HTTPS. `true` by default.
     */
    public var useSSL: Bool = true
    
    /**
     The `Manager` instance to use for network requests.
     
     :note: This defaults to the shared instance of `Manager` used by top-level Alamofire requests.
     */
    public var requestManager: Alamofire.SessionManager = Alamofire.SessionManager.default
    
    /**
     A readonly endpoint URL created for the specified bucket, region, and SSL use preference. `AmazonS3RequestManager` uses this as the baseURL for all requests.
     */
    public var endpointURL: URL {
        var URLString = ""
        
        let scheme = self.useSSL ? "https" : "http"
        
        if bucket != nil {
            URLString = "\(scheme)://\(region.rawValue)/\(bucket!)"
            
        } else {
            URLString = "\(scheme)://\(region.rawValue)"
        }
        
        return URL(string: URLString)!
    }
    
    /**
     MARK: Initialization
     */
    
    /**
     Initalizes an `AmazonS3RequestManager` with the given Amazon S3 credentials.
     
     :param: bucket    The Amazon S3 bucket for the client
     :param: region    The Amazon S3 region for the client
     :param: accessKey The Amazon S3 access key ID for the client
     :param: secret    The Amazon S3 secret for the client
     
     :returns: An `AmazonS3RequestManager` with the given Amazon S3 credentials and a default configuration.
     */
    required public init(bucket: String?, region: AmazonS3Region, accessKey: String?, secret: String?) {
        self.bucket = bucket
        self.region = region
        self.accessKey = accessKey
        self.secret = secret
    }
    
    /**
     MARK: Requests
     */
    
    /**
     MARK: GET Object Requests
     */
    
    /**
     Gets and object from the Amazon S3 service and returns it as the response object without saving to file.
     
     :note: This method performs a standard GET request and does not allow use of progress blocks.
     
     :param: path The object path
     
     :returns: A GET request for the object
     */
    public func getObject(path: String) -> Request {
        let getRequest = amazonURLRequest(.get, path: path)
        
        return requestManager.request(getRequest)
    }
    
    /**
     Gets an object from the Amazon S3 service and saves it to file.
     
     :note: The user for the manager's Amazon S3 credentials must have read access to the object
     
     :dicussion: This method performs a download request that allows for a progress block to be implemented. For more information on using progress blocks, see `Alamofire`.
     
     :param: path           The object path
     :param: destinationURL The `NSURL` to save the object to
     
     :returns: A download request for the object
     */
    public func downloadObject(path: String, saveToURL destinationURL: URL) -> Request {
        let getRequest = amazonURLRequest(.get, path: path)
        
        return requestManager.download(getRequest, to: { (_, _) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (destinationURL, [])
        })
    }
    
    /**
     MARK: PUT Object Request
     */
    
    /**
     Uploads an object to the Amazon S3 service with a given local file URL.
     
     :note: The user for the manager's Amazon S3 credentials must have read access to the bucket
     
     :param: fileURL         The local `NSURL` of the file to upload
     :param: destinationPath The desrired destination path, including the file name and extension, in the Amazon S3 bucket
     
     :returns: An upload request for the object
     */
    public func putObject(fileURL: URL, destinationPath: String) -> UploadRequest {
        let putRequest = amazonURLRequest(.put, path: destinationPath)
        
        return requestManager.upload(fileURL, with: putRequest)
    }
    
    public func putObject(fileURL: URL, destinationPath: String, done: @escaping (Error?) -> Void) -> UploadRequest {
        let putRequest = amazonURLRequest(.put, path: destinationPath)
        
        let request = requestManager.upload(fileURL, with: putRequest)
        request.response(completionHandler: { res in
            done(res.error)
        })

        return request
    }
    
    /**
     MARK: DELETE Object Request
     */
    
    /**
     Deletes an object from the Amazon S3 service.
     
     :warning: Once an object has been deleted, there is no way to restore or undelete it.
     
     :param: path The object path
     
     :returns: The delete request
     */
    public func deleteObject(path: String) -> Request {
        let deleteRequest = amazonURLRequest(.delete, path: path)
        
        return requestManager.request(deleteRequest)
    }
    
    /**
     MARK: Amazon S3 Request Serialization
     */
    
    public func amazonURLRequest(_ method: Alamofire.HTTPMethod, path: String) -> URLRequest {
        
        let url = endpointURL.appendingPathComponent(path)
        
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        
        setContentType(URLRequest: &mutableURLRequest)
        test(URLRequest: &mutableURLRequest)
        let amazonRequest = requestBySettingAuthorizationHeaders(forRequest: mutableURLRequest)
        
        return amazonRequest.0
    }
    
    private func setContentType( URLRequest: inout URLRequest) {
        let contentTypeString = MIMEType(request: URLRequest) ?? "text/plain"
        
        URLRequest.setValue(contentTypeString, forHTTPHeaderField: "Content-Type")
    }
    
    func test( URLRequest: inout URLRequest) {
        URLRequest.setValue("public-read", forHTTPHeaderField: "x-amz-acl")
    }
    
    private func MIMEType(request: URLRequest) -> String? {
        if let fileExtension = request.url?.pathExtension {
            if !fileExtension.isEmpty {
                
                if let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil) {
                    let UTI = UTIRef.takeUnretainedValue()
                    UTIRef.release()
                    if let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) {
                        let MIMEType = MIMETypeRef.takeUnretainedValue()
                        MIMETypeRef.release()
                        
                        return MIMEType as String
                    }
                }
                
                
            }
        }
        return nil
    }
    
    private func requestBySettingAuthorizationHeaders(forRequest request: URLRequest) -> (URLRequest, Error?) {
        
        var request = request
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let error = validateCredentials()
        
        if error == nil {
            
            if sessionToken != nil {
                request.setValue(sessionToken!, forHTTPHeaderField: "x-amz-security-token")
            }
            
            let timestamp = currentTimeStamp()
            
            let signature = AmazonS3SignatureHelpers.awsSignature(for: request,
                                                                            timeStamp: timestamp,
                                                                            secret: secret!)
            
            request.setValue(timestamp, forHTTPHeaderField: "Date")
            request.setValue("AWS \(accessKey!):\(signature)", forHTTPHeaderField: "Authorization")
            
            return(request, error)
            
        } else {
            return (request, error)
            
        }
    }
    
    private func currentTimeStamp() -> String {
        return requestDateFormatter.string(from: Date())
    }
    
    private lazy var requestDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone!
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter
    }()
    
    /**
     MARK: Validation
     */
    
    private func validateCredentials() -> Error? {
        if accessKey == nil || accessKey!.isEmpty {
            return accessKeyMissingError
            
        }
        if secret == nil || secret!.isEmpty {
            return secretMissingError
            
        }
        
        return nil
    }
    
    /**
     MARK: Error Handling
     */
    
    private lazy var accessKeyMissingError: Error = NSError(
        domain: AmazonS3RequestManagerErrorDomain,
        code: AmazonS3RequestManagerErrorCodes.AccessKeyMissing.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Access Key Missing",
                   NSLocalizedFailureReasonErrorKey: "The 'accessKey' must be set in order to make requests with 'AmazonS3RequestManager'."]
    )
    
    private lazy var secretMissingError: Error = NSError(
        domain: AmazonS3RequestManagerErrorDomain,
        code: AmazonS3RequestManagerErrorCodes.SecretMissing.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Secret Missing",
                   NSLocalizedFailureReasonErrorKey: "The 'secret' must be set in order to make requests with 'AmazonS3RequestManager'."]
    )
    
}

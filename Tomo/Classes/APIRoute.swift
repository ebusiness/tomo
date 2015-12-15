//
//  APIRoute.swift
//  Tomo
//
//  Created by starboychina on 2015/12/14.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Alamofire
import SwiftyJSON
/**
An API Route
*/
protocol APIRoute: URLRequestConvertible {
    /// url path
    var path: String { get }
    /// Method
    var method: Alamofire.Method { get }
    /// Encoding
    var encoding: Alamofire.ParameterEncoding { get }
}

// MARK: - URLRequestConvertible
extension APIRoute {
    
    var URLRequest: NSMutableURLRequest {
        let requestUrl = TomoConfig.Api.Url.URLByAppendingPathComponent(self.path)
        
        // Create a request with `requestUrl`, returning cached data if available, with a 15 second timeout.
        let mutableURLRequest = NSMutableURLRequest(URL: requestUrl, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 15)
        mutableURLRequest.HTTPMethod = self.method.rawValue
        guard let parameters = self.parameters else { return mutableURLRequest }
        return encoding.encode(mutableURLRequest, parameters: parameters).0
    }
}

// MARK: - Default
extension APIRoute {
    var method: Alamofire.Method { return .GET }
    var encoding: Alamofire.ParameterEncoding { return .JSON }
}

// MARK: - extension
extension APIRoute {
    
    private var parameters: [String : AnyObject]? {
        guard let this = self as? NSObject else { return nil }
        var outCount:UInt32 = 0
        let peopers =  class_copyPropertyList(this.classForCoder, &outCount)
        
        let count:Int = Int(outCount)
        
        var parameters = [String: AnyObject]()
        
        for i in 0..<count {
            let key = String(UTF8String: property_getName(peopers[i]))!
            
            if "path" == key { continue }
            
            if let value = this.valueForKey(key) {
                parameters[key] = value
            }
            
        }
        print(parameters)
        if parameters.count > 0 {
            return parameters
        } else {
            return nil
        }
    }
    
    var request: Request {
        return Manager.instance.request(self).validate()
    }
    
    func response(completionHandler: Response<JSON, NSError> -> Void) -> Request {
        return request.responseSwiftyJSON(completionHandler: completionHandler)
    }
}

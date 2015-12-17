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
 HTTP method definitions.
 
 See https://tools.ietf.org/html/rfc7231#section-4.3
 */
public enum RouteMethod : String {
    case OPTIONS
    case GET
    case HEAD
    case POST
    case PUT
    case PATCH
    case DELETE
    case TRACE
    case CONNECT
}
/**
An API Route
*/
protocol APIRoute: URLRequestConvertible {
    /// url path
    var path: String { get }
    /// Method
    var method: RouteMethod { get }
    /// Encoding
    var encoding: Alamofire.ParameterEncoding { get }
}

// MARK: - URLRequestConvertible
extension APIRoute {
    
    var URLRequest: NSMutableURLRequest {
        let requestUrl = TomoConfig.Api.Url.URLByAppendingPathComponent(self.path)
        let mutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        mutableURLRequest.HTTPMethod = self.method.rawValue
        mutableURLRequest.timeoutInterval = 30
        #if DEBUG
            print("URL: \(requestUrl)")
            print("Method: \(self.method.rawValue)")
            print("Parameters: \(parameters)")
        #endif
        guard let parameters = self.parameters else { return mutableURLRequest }
        return encoding.encode(mutableURLRequest, parameters: parameters).0
    }
}

// MARK: - Default
extension APIRoute {
    var method: RouteMethod { return .GET }
    var encoding: Alamofire.ParameterEncoding { return method == .GET ? .URL : .JSON }
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
        if parameters.count > 0 {
            return parameters
        } else {
            return nil
        }
    }
    
    var request: Request {
        return Manager.instance.request(self).validate()
    }
    
    func response(queue: dispatch_queue_t? = nil, completionHandler: Response<JSON, NSError> -> Void) -> Request {
        return request.responseSwiftyJSON(completionHandler: completionHandler)
    }
}

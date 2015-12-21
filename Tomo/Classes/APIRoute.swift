//
//  APIRoute.swift
//  Tomo
//
//  Created by starboychina on 2015/12/14.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct Router {}
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
    /// Parameters
    var parameters: [String : AnyObject]? { get }
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
    var encoding: Alamofire.ParameterEncoding { return .URL }
    var parameters: [String : AnyObject]? { return nil }
}

// MARK: - extension
extension APIRoute {
    
    var request: Request {
        return Manager.instance.request(self).validate()
    }
    
    func response(queue: dispatch_queue_t? = nil, completionHandler: Response<JSON, NSError> -> Void) -> Request {
        return request.responseSwiftyJSON(queue, completionHandler: completionHandler)
    }
}
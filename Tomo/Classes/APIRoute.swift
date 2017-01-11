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
    var parameters: [String : Any]? { get }
}

// MARK: - URLRequestConvertible
extension APIRoute {
    
    public func asURLRequest() throws -> URLRequest {
        let requestUrl = TomoConfig.Api.Url.appendingPathComponent(self.path)
        var mutableURLRequest = URLRequest(url: requestUrl)
        mutableURLRequest.httpMethod = self.method.rawValue
        mutableURLRequest.timeoutInterval = 30
        #if DEBUG
            print("URL: \(requestUrl)")
            print("Method: \(self.method.rawValue)")
            print("Parameters: \(parameters)")
        #endif
        guard let parameters = self.parameters else { return mutableURLRequest }
        return try! encoding.encode(mutableURLRequest, with: parameters)
    }
}

// MARK: - Default
extension APIRoute {
    public var method: RouteMethod { return .GET }
    public var encoding: Alamofire.ParameterEncoding { return Alamofire.URLEncoding.default }
    public var parameters: [String : Any]? { return nil }
}

// MARK: - extension
extension APIRoute {
    
    var request: DataRequest {
        return Alamofire.SessionManager.default.request(self).validate()
    }
    
    @discardableResult
    func response(completionHandler: @escaping (DataResponse<JSON>) -> Void) -> Request {
        return request.responseSwiftyJSON(completionHandler: completionHandler)
    }
}

//
//  APIRoute.swift
//  Tomo
//
//  Created by starboychina on 2015/12/14.
//  Copyright © 2015 e-business. All rights reserved.
//

import Alamofire
import RxSwift
import SwiftyJSON

struct Router {}
/**
 HTTP method definitions.

 See https://tools.ietf.org/html/rfc7231#section-4.3
 */
public enum RouteMethod: String {
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
        do {
            return try encoding.encode(mutableURLRequest, with: parameters)
        } catch let err {
            throw err
        }
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
    @discardableResult
    func request() -> DataRequest {
        return Alamofire.SessionManager.default.request(self).validate()
    }

    @discardableResult
    func response(completionHandler: @escaping (DataResponse<JSON>) -> Void) -> Request {
        return request().responseSwiftyJSON(completionHandler: completionHandler)
    }
}

// MARK: - RxSwift
extension APIRoute {

    /// deferred request
    ///
    /// - Returns: <#return value description#>
    func rxRequest() -> Observable<JSON> {
        return Observable<JSON>.deferred {
            return self.createObservable()
        }
    }

    /// create an Observable of Alamofire request
    ///
    /// - Returns: <#return value description#>
    private func createObservable() -> Observable<JSON> {
        return Observable<JSON>.create { observer in
            let disposable = Disposables.create()
            self.request().responseSwiftyJSON {
                guard let value = $0.result.value else {
                    observer.onError($0.result.error!)
                    disposable.dispose()
                    return
                }
                observer.onNext(value)
                observer.onCompleted()
                disposable.dispose()
            }
            return disposable
        }
    }
}

extension ObservableType {
    /**
     Subscribes an element handler, an error handler to an observable sequence.
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    @discardableResult
    public func subscribe(onNext: ((Self.E) -> Void)? = nil, onError: ((Error) -> Void)? = nil) -> Disposable {
        #if DEBUG
            return self.subscribe(onNext: onNext, onError: onError, onCompleted: {
                print("onCompleted")
            }, onDisposed: {
                print("onCompleted")
            })
        #else
            return self.subscribe(onNext: onNext, onError: onError)
        #endif
    }
}

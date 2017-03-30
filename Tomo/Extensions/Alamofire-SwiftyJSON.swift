//
//  Alamofire-SwiftyJSON.swift
//  Tomo
//
//  Created by Hikaru on 2016/01/29.
//  Copyright © 2016 e-business. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension Alamofire.SessionManager {

    open static let `default`: SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            TomoConfig.Api.Domain: .disableEvaluation
        ]

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let manager = SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )

        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?

            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    let urlCredentialStorage = manager.session.configuration.urlCredentialStorage
                    credential = urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
        return manager
    }()
}

/// A set of HTTP response status code that do not contain response data.
private let emptyDataStatusCodes: Set<Int> = [204, 205]

// MARK: - Request for SwiftyJSON
extension DataRequest {
    /// Creates a response serializer that
    /// returns a SwiftyJSON object result type constructed from the response data using
    /// `JSONSerialization` with the specified reading options.
    ///
    /// - parameter options: The JSON serialization reading options. Defaults to `.allowFragments`.
    ///
    /// - returns: A JSON object response serializer.
    public static func serializeResponseSwiftyJSON(
        options: JSONSerialization.ReadingOptions = .allowFragments)
        -> DataResponseSerializer<JSON> {
            return DataResponseSerializer { _, response, data, error in
                return Request.serializeResponseSwiftyJSON(options: options,
                                                           response: response,
                                                           data: data,
                                                           error: error)
            }
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter options:
    ///     The JSON serialization reading options. Defaults to `.allowFragments`.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseSwiftyJSON(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (DataResponse<JSON>) -> Void)
        -> Self {
            return response(
                queue: queue,
                responseSerializer: DataRequest.serializeResponseSwiftyJSON(options: options),
                completionHandler: completionHandler
            )
    }
}

// MARK: - JSON
extension Request {
    /// Returns a JSON object contained in a result type constructed
    /// from the response data using `JSONSerialization`
    /// with the specified reading options.
    ///
    /// - parameter options:  The JSON serialization reading options. Defaults to `.allowFragments`.
    /// - parameter response: The response from the server.
    /// - parameter data:     The data returned from the server.
    /// - parameter error:    The error already encountered if it exists.
    ///
    /// - returns: The result data type.
    public static func serializeResponseSwiftyJSON(
        options: JSONSerialization.ReadingOptions,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?)
        -> Result<JSON> {
            guard error == nil else { return .failure(error!) }

            if let response = response, emptyDataStatusCodes.contains(response.statusCode) {
                return .success(JSON.null)
            }

            guard let validData = data, !validData.isEmpty else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
            }

            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: options)

                return .success(JSON(json))
            } catch {
                return .failure(AFError.responseSerializationFailed(
                    reason: .jsonSerializationFailed(error: error)))
            }
    }
}

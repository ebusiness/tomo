//
//  AlamofireController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Alamofire

class AlamofireController {
    
    private static let badRequestCode = 400 //Bad Request
    
    private static let window : UIWindow? = {
        
        return UIApplication.sharedApplication().keyWindow
        
        }()
    
    private static let alamofireInstance: Manager = {

        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "api.dev.genbatomo.com": .DisableEvaluation
        ]

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders

        return Alamofire.Manager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )

////        #if DEBUG
//            /// allow invalid SSL certificates
//        do {
//            let range = try kAPIBaseURLString.matches("([a-zA-Z\\d\\.\\-]+)")?[1].rangeAtIndex(0)// ?? 0...kAPIBaseURLString.length - 1
//            
//            /// "tomo.e-business.co.jp"
//            let hostName = kAPIBaseURLString[range!.location..<(range!.location + range!.length)]!
//            
//            let serverTrustPolicies: [String: ServerTrustPolicy] = [
//                hostName: .DisableEvaluation
//            ]
//            
//            Manager.sharedInstance.session.serverTrustPolicyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
//        } catch {
//            
//        }
////        #endif
//        
//        return Manager.sharedInstance

        }()
    
    
    class func request(method: Alamofire.Method, _ URLString: String, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL, hideHUD: Bool = false,success: ((AnyObject)->())? = nil, failure: ((Int)->())? = nil ) {
        
        if !hideHUD {
            Util.showHUD()
        }

        
        let request = alamofireInstance.request(method, kAPIBaseURLString + URLString, parameters: parameters, encoding: encoding).validate()
        
        if success == nil && failure == nil {
            
            Util.dismissHUD()
            return
        }
        
        if let success = success {
            request.responseJSON { res in
                Util.dismissHUD()
                if let result: AnyObject = res.result.value where res.result.error == nil {
                    success(result)
                } else {
                    self.errorHanding(res.response, error: res.result.error, failure: failure)
                }
            }
        } else {
            request.response { (_, res, _, err) -> Void in
                Util.dismissHUD()
                self.errorHanding(res, error: err, failure: failure)
            }
        }
    }
    
    // Mark - Error Handler
    // TODO
    private class func errorHanding(res: NSHTTPURLResponse?, error: NSError?, failure: ((Int)->())?) {
        
        #if DEBUG
            print(res?.URL)
            print(error)
        #endif
        let statusCode = res?.statusCode ?? badRequestCode
        
        if statusCode != 401 {
            failure?(statusCode)
            return
        }
        
        /// Unauthorized
        if let classForCoder: AnyClass = window?.rootViewController?.classForCoder where NSStringFromClass(classForCoder) != "tomo.RegViewController" {
            window!.rootViewController = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
        } else {
            failure?(statusCode)
        }
        
        
    }
    
}
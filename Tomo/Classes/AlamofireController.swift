//
//  AlamofireController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

class AlamofireController {
    
    private static let badRequestCode = 400 //Bad Request
    
    private static let window : UIWindow? = {
        
        return UIApplication.sharedApplication().keyWindow
        
        }()
    
    private static let alamofireInstance: Manager = {
//        #if DEBUG
            /// allow invalid SSL certificates
            
            let range = kAPIBaseURLString.matches("([a-zA-Z\\d\\.\\-]+)")?[1].rangeAtIndex(0)// ?? 0...kAPIBaseURLString.length - 1
            
            /// "tomo.e-business.co.jp"
            let hostName = kAPIBaseURLString[range!.location..(range!.location + range!.length)]!
            
            let serverTrustPolicies: [String: ServerTrustPolicy] = [
                hostName: .DisableEvaluation
            ]
            
            Manager.sharedInstance.session.serverTrustPolicyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
//        #endif
        
        return Manager.sharedInstance
        
        }()
    
    
    class func request(method: Method, _ URLString: String, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL, hideHUD: Bool = false,success: ((AnyObject)->())? = nil, failure: ((Int)->())? = nil ) {
        
        if !hideHUD {
            Util.showHUD()
        }

        
        let request = alamofireInstance.request(method, kAPIBaseURLString + URLString, parameters: parameters, encoding: encoding).validate()
        
        if success == nil && failure == nil {
            
            Util.dismissHUD()
            return
        }
        
        if let success = success {
            request.responseJSON { (_, res, result, err) -> Void in
                Util.dismissHUD()
                if let result: AnyObject = result where err == nil {
                    success(result)
                } else {
                    self.errorHanding(res, error: err, failure: failure)
                }
            }
        } else {
            request.response({ (_, res, _, err) -> Void in
                Util.dismissHUD()
                self.errorHanding(res, error: err, failure: failure)
            })
        }
    }
    
    // Mark - Error Handler
    // TODO
    private class func errorHanding(res: NSHTTPURLResponse?, error: NSError?, failure: ((Int)->())?) {
        
        #if DEBUG
            println(res?.URL)
            println(error)
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
//
//  AlamofireController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

class AlamofireController {
    
    class func request(method: Method, _ URLString: String, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL, hideHUD: Bool = false,success: ((AnyObject)->())? = nil, failure: ((NSError?)->())? = nil ) {
        
        if !hideHUD {
            Util.showHUD()
        }
        
        let request = Manager.sharedInstance.request(method, kAPIBaseURLString + URLString, parameters: parameters, encoding: encoding).validate()
        
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
                    self.errorHanding(res, error: err)
                    failure?(err)
                }
            }
        } else {
            request.response({ (_, res, _, err) -> Void in
                Util.dismissHUD()
                self.errorHanding(res, error: err)
                failure?(err)
            })
        }
    }
    
    // Mark - Error Handler
    // TODO
    private class func errorHanding(res: NSHTTPURLResponse?, error: NSError?) {
        
        #if DEBUG
            println(res?.URL)
            println(error)
        #endif
        
        if let window = UIApplication.sharedApplication().keyWindow, res = res
            where res.statusCode == 401 && NSStringFromClass(window.rootViewController!.classForCoder) != "tomo.RegViewController" {
                
                window.rootViewController = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
        }
    }
    
}
//
//  RestKitErrorHanding.swift
//  Tomo
//
//  Created by starboychina on 2015/07/31.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class RestKitErrorHanding: RKObjectRequestOperation{
    
    override func setCompletionBlockWithSuccess(success: ((RKObjectRequestOperation!, RKMappingResult!) -> Void)!, failure: ((RKObjectRequestOperation!, NSError!) -> Void)!) {
        super.setCompletionBlockWithSuccess({ (operation, mappingResult) -> Void in
            
            if let success = success {
                success(operation, mappingResult)
            }
        }, failure: { (operation, error) -> Void in
            
            Util.dismissHUD()
            if let res = operation.HTTPRequestOperation.response {
                
                let statusCode = res.statusCode
                
                if let window = UIApplication.sharedApplication().keyWindow
                    where statusCode == 401 && NSStringFromClass(window.rootViewController!.classForCoder) != "tomo.RegViewController" {
                        
                        window.rootViewController = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                }
            } else {
                // no response NSURLErrorDomain Code=-1001
            }
            
            
            if let failure = failure {
                failure(operation, error);
            }
        })
    }
    
}
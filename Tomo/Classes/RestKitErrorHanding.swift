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
            
            let statusCode = operation.HTTPRequestOperation.response.statusCode
            
            if let window = UIApplication.sharedApplication().keyWindow
                where statusCode == 401 && NSStringFromClass(window.rootViewController!.classForCoder) != "tomo.LoadingViewController" {
    
                    window.rootViewController = Util.createViewControllerWithIdentifier("LoadingViewController", storyboardName: "Main")
            }
            
            if let failure = failure {
                failure(operation, error);
            }
        })
    }
    
}
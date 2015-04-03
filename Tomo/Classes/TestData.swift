//
//  TestData.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class TestData: NSObject {
   
    class func getRandomAvatarPath(done: (path: String?) -> Void) {
        request(.GET, "http://uifaces.com/api/v1/random")
            .responseJSON { (_, _, JSON, _) in
                if let dic = JSON as? Dictionary<String, AnyObject> {
                    if let urls = dic["image_urls"] as? Dictionary<String, AnyObject> {
                        if let url = urls["normal"] as? String {
                            done(path: url)
                        }
                    }
                }
        }
    }
}

//
//  RemoteNotification.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class RemoteNotification {
    
    var taskUserInfo: [NSObject : AnyObject]?
    var constraints = [AnyObject]()
    
    class var sharedInstance : RemoteNotification {
        struct Static {
            static let instance : RemoteNotification = RemoteNotification()
        }
        return Static.instance
    }
    
    private init() {}
    
    func receiveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        gcd.async(.Default) {
            let json = JSON(userInfo)
            let type = json["type"].stringValue
            let id = json["id"].stringValue
//            handleOpenURL(NSURL(string:"tomo://\(type)/\(id)")!)
            
            if let rootvc = UIApplication.sharedApplication().keyWindow?.rootViewController as? TabBarController{
                
                if let event = ListenerEvent(rawValue: type) {
                    event.receive(userInfo)
                    gcd.sync(.Main) {
                        let notificationView = self.getNotificationView()
                        notificationView.notification = NotificationEntity(userInfo)
                        let topConstraint: AnyObject? = notificationView.superview!.constraints().find { $0.firstAttribute == .Top && $0.firstItem is NotificationView }
                        
                        if let topConstraint = topConstraint as? NSLayoutConstraint {
                            topConstraint.constant = 0
                            
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                notificationView.superview?.layoutIfNeeded()
                            })
                        }
                    }
                } else {
                    // other event
                }
                
            } else {
                self.taskUserInfo = userInfo
            }
        }
    }
    
    func runTask(){
        if let userInfo = self.taskUserInfo {
            self.taskUserInfo = nil
            receiveRemoteNotification(userInfo)
        }
    }
}

extension RemoteNotification{
    
    private func getNotificationView() -> NotificationView{
        let window = UIApplication.sharedApplication().keyWindow!
        if let lastView = window.subviews.last as? NotificationView {
            window.bringSubviewToFront(lastView)
            return lastView
        } else {
            let notificationView = Util.createViewWithNibName("NotificationView") as! NotificationView
            notificationView.setTranslatesAutoresizingMaskIntoConstraints(false)
            let views = ["notificationView":notificationView]
            window.addSubview(notificationView)
            window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[notificationView]|", options: nil, metrics: nil, views: views))
            window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(-64)-[notificationView(==64)]", options: nil, metrics: nil, views: views))
            window.layoutIfNeeded()
            notificationView.layoutIfNeeded()

            return notificationView
        }
    }
}

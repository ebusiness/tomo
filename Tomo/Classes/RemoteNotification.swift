//
//  RemoteNotification.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation
import SwiftyJSON

class RemoteNotification {
    // last notication
    var taskUserInfo: [AnyHashable: Any]?

    static let shared: RemoteNotification = RemoteNotification()

    private init() {}

    func receive(userInfo: [AnyHashable: Any]) {
        DispatchQueue.default.async {
            if UIApplication.shared.keyWindow?.rootViewController is TabBarController {

                let type = JSON(userInfo)["type"].stringValue

                if let event = ListenerEvent(rawValue: type) {
                    event.post(userInfo: userInfo)
                }
            } else {
                self.taskUserInfo = userInfo
            }
        }
    }

    func runTask() {
        guard let userInfo = self.taskUserInfo else { return }
        self.receive(userInfo: userInfo)
        self.taskUserInfo = nil
    }
}

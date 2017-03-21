//
//  UIViewController.swift
//  Tomo
//
//  Created by starboychina on 2017/02/16.
//  Copyright © 2017 e-business. All rights reserved.
//

import RxSwift

extension UINavigationController {

    func pop(to viewController: UIViewController, animated: Bool) {
        _ = self.popToViewController(viewController, animated: animated)
    }

    @discardableResult
    func pop(animated: Bool) {
        _ = self.popViewController(animated: animated)
    }
}

//
//  UIView.swift
//  Tomo
//
//  Created by starboychina on 2017/04/03.
//  Copyright © 2017  e-business. All rights reserved.
//

extension UIView {
    func addConstraints(format: String, views: [String: UIView]) {
        let cons = NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: views)
        self.addConstraints(cons)
    }
}


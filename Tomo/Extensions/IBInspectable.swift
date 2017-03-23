//
//  IBInspectable.swift
//  Tomo
//
//  Created by starboychina on 2017/03/21.
//  Copyright © 2017 e-business. All rights reserved.
//

import Foundation

@IBDesignable extension UIView {


    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
//            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor:color)
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var bottomBorder: CGFloat {
        set {
            if let layers = layer.sublayers {
                layers.forEach {
                    $0.removeFromSuperlayer()
                }
            }
            let border = CGRect(x: 0,
                                y: frame.size.height - newValue,
                                width: frame.size.width,
                                height: frame.size.height)

            self.addLayer(frame: border, width: newValue)
        }
        get {
            guard  let layers = layer.sublayers else {
                return 0
            }
            var width: CGFloat = 0
            layers.forEach {
                guard $0.frame.origin.x == 0 else { return }
                guard $0.frame.size.width == frame.size.width else { return }
                guard $0.frame.size.height == frame.size.height else { return }
                width = frame.size.height - $0.frame.origin.y
            }
            return width
        }
    }

    private func addLayer(frame: CGRect, width: CGFloat) {
        let border = CALayer()
        border.borderColor = layer.borderColor
        border.frame = frame
        border.borderWidth = width
        layer.addSublayer(border)
    }
}

@IBDesignable extension UITextField {

    /// Color of placeHolder
    @IBInspectable var placeHolderColor: UIColor? {
        set {
            guard let color = newValue else { return }
            let attributeString = NSAttributedString(string: placeholder!, attributes: [
                NSForegroundColorAttributeName: color.cgColor
                ])
            attributedPlaceholder = attributeString
        }
        get {
            guard  let attributeString = attributedPlaceholder else {
                return nil
            }
            let attributes = attributeString.attributes(at: 0, effectiveRange: nil)
            guard let key = attributes.keys.first else { return nil }

            guard let color = attributes[key] as? UIColor else { return nil }
            return color
        }
    }
}

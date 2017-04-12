//
//  PointAnnotationView.swift
//  Tomo
//
//  Created by 李超逸 on 2017/4/11.
//  Copyright © 2017年  e-business. All rights reserved.
//

import Foundation

class PointAnnotationView: MKAnnotationView {
    private var icon: UIImageView
    private var strokeLabel: UILabel
    private var fillLabel: UILabel

    private let strokeAttribute: [String: Any] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14.0),
                                                  NSForegroundColorAttributeName: #colorLiteral(red: 0.3647058824, green: 0.2509803922, blue: 0.2156862745, alpha: 1),
                                                  NSStrokeWidthAttributeName: 12.0,
                                                  NSStrokeColorAttributeName: UIColor.white]
    private let fillAttribute: [String: Any] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14.0),
                                                NSForegroundColorAttributeName: #colorLiteral(red: 0.3647058824, green: 0.2509803922, blue: 0.2156862745, alpha: 1)]

    required init?(coder aDecoder: NSCoder) {
        icon = aDecoder.decodeObject(of: UIImageView.self, forKey: "icon")!
        fillLabel = aDecoder.decodeObject(of: UILabel.self, forKey: "fillLabel")!
        strokeLabel = aDecoder.decodeObject(of: UILabel.self, forKey: "strokeLabel")!
        super.init(coder: aDecoder)
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {

        icon = UIImageView()
        fillLabel = UILabel()
        strokeLabel = UILabel()

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = false

        frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        addSubview(icon)

        // Add icon's autolayout constraints
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        addSubview(strokeLabel)
        addSubview(fillLabel)
        fillLabel.numberOfLines = 0
        strokeLabel.numberOfLines = 0
        fillLabel.adjustsFontSizeToFitWidth = true
        strokeLabel.adjustsFontSizeToFitWidth = true

        // Add label's autolayout constraints
        fillLabel.translatesAutoresizingMaskIntoConstraints = false
        fillLabel.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 4.0).isActive = true
        fillLabel.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        fillLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 120).isActive = true
        fillLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 60).isActive = true

        strokeLabel.translatesAutoresizingMaskIntoConstraints = false
        strokeLabel.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 4.0).isActive = true
        strokeLabel.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        strokeLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 120).isActive = true
        strokeLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 60).isActive = true

        rerender()
    }

    // Rerender using new data.
    // Call this method whenever the view is reused.
    func rerender() {
        guard let annotation = annotation as? ProjectAnnotation else {
            return
        }

        let strokeString = NSAttributedString(string: annotation.project.name,
                                              attributes: strokeAttribute)
        let fillString = NSAttributedString(string: annotation.project.name,
                                            attributes: fillAttribute)
        strokeLabel.attributedText = strokeString
        fillLabel.attributedText = fillString
        switch annotation.project.members.count {
        case 0, 1:
            icon.image = #imageLiteral(resourceName: "businessCenter300")
        case 2...3:
            icon.image = #imageLiteral(resourceName: "businessCenter400")
        case 4...7:
            icon.image = #imageLiteral(resourceName: "businessCenter500")
        case 8...15:
            icon.image = #imageLiteral(resourceName: "businessCenter600")
        case 16...31:
            icon.image = #imageLiteral(resourceName: "businessCenter700")
        case 32...63:
            icon.image = #imageLiteral(resourceName: "businessCenter800")
        default:
            icon.image = #imageLiteral(resourceName: "businessCenter900")
        }
    }
}

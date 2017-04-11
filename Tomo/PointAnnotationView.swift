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

    required init?(coder aDecoder: NSCoder) {
        icon = aDecoder.decodeObject(of: UIImageView.self, forKey: "icon")!
        super.init(coder: aDecoder)
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {

        icon = UIImageView()

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = false

        frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        addSubview(icon)

        rerender()
    }

    // Rerender using new data.
    // Call this method whenever the view is reused.
    func rerender() {
        guard let annotation = annotation as? ProjectAnnotation else {
            return
        }
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
        icon.sizeToFit()
    }
}

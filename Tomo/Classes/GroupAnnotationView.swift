//
//  GroupAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/09/29.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation

class GroupAnnotationView: AggregatableAnnotationView {

    var imageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Palette.Red.primaryColor.cgColor
        imageView.layer.cornerRadius = 5
        addSubview(imageView)

        numberBadge.frame = CGRect(x: 28, y: -8, width: 20, height: 20)
        numberBadge.layer.cornerRadius = numberBadge.frame.width / 2
    }

    override func setupDisplay() {

        super.setupDisplay()

        guard let annotation = self.annotation as? GroupAnnotation else { return }
        imageView.sd_setImage(with: URL(string: annotation.group.cover!), placeholderImage: defaultGroupImage)
    }

}

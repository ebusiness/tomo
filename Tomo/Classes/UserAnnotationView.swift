//
//  UserAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2016/01/07.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class UserAnnotationView: AggregatableAnnotationView {

    var imageView: UIImageView!
    var numberLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 60, height: 60)

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = imageView.frame.width / 2
        addSubview(imageView)

        numberLabel = UILabel(frame: CGRect(x: 0, y: 45, width: 60, height: 15))
        numberLabel.textColor = UIColor.white
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.font = UIFont.systemFont(ofSize: 10)

        numberBadge.frame = CGRect(x: 45, y: 0, width: 120, height: 20)
        numberBadge.layer.cornerRadius = numberBadge.frame.height / 2
    }

    override func setupDisplay() {

        if let annotation = self.annotation as? UserAnnotation {

            if let containedAnnotations = annotation.containedAnnotations {

                let count = containedAnnotations.count

                if count > 0 {
                    numberLabel.text = "\(count + 1)"
                    imageView.addSubview(numberLabel)
                } else {
                    numberLabel.removeFromSuperview()
                }

                numberBadge.text = "\(annotation.user.primaryStation!.name!)"
                numberBadge.sizeToFit()
                numberBadge.frame = CGRect(x: 45, y: 0, width: numberBadge.bounds.width + 10, height: numberBadge.bounds.height + 10)
                numberBadge.layer.cornerRadius = numberBadge.frame.height / 2
                addSubview(numberBadge)
            }
            
            imageView.sd_setImage(with: URL(string:  annotation.user.photo!), placeholderImage: DefaultAvatarImage, options: .retryFailed)

            if let friends = me.friends, friends.contains(where: { $0 == annotation.user.id }) {
                imageView.layer.borderColor = Palette.Pink.primaryColor.cgColor
                numberLabel.backgroundColor = Palette.Pink.primaryColor
                numberBadge.backgroundColor = Palette.Pink.primaryColor
            } else {
                imageView.layer.borderColor = Palette.LightBlue.primaryColor.cgColor
                numberLabel.backgroundColor = Palette.LightBlue.primaryColor
                numberBadge.backgroundColor = Palette.LightBlue.primaryColor
            }
        }
    }

}

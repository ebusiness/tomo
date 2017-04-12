//
//  ClusterAnnotationView.swift
//  Tomo
//
//  Created by 李超逸 on 2017/4/10.
//  Copyright © 2017年  e-business. All rights reserved.
//

import Foundation

class ClusterAnnotationView: MKAnnotationView {

    private var badgeView: BadgeView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = false

        frame = CGRect(x: 0, y: 0, width: 60, height: 60)

        guard let annotation = self.annotation as? AggregatableAnnotation else { return }
        badgeView = BadgeView(badge: annotation.containedAnnotations.count + 1,
                              frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        addSubview(self.badgeView)

        rerender()
    }

    // Rerender using new data.
    // Call this method whenever the view is reused.
    func rerender() {
        guard let annotation = annotation as? AggregatableAnnotation else {
            return
        }
        badgeView.badge = annotation.containedAnnotations.count + 1

        var exRate: CGFloat = 1
        switch annotation.containedAnnotations.count + 1 {
        case 10..<20:
            exRate = 1.2
        case 20..<30:
            exRate = 1.4
        case 30..<40:
            exRate = 1.6
        case 40..<Int.max:
            exRate = 1.8
        default:
            exRate = 1
        }

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: exRate, y: exRate)
        })
    }
}

fileprivate final class BadgeView: UIView {
    private let shadowView = UIView()
    private let backgroundView = UIView()
    private let badgeLabel = UILabel()

    private let padding: CGFloat = 10

    init(badge: Int, frame: CGRect) {
        self.badge = badge
        super.init(frame: frame)

        self.setShadowView()
        self.setBackGroundView()
        self.setBadgeLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        self.badge = aDecoder.decodeInteger(forKey: "badge")
        super.init(coder: aDecoder)
    }

    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(badge, forKey: "badge")
    }

    var badge: Int {
        didSet {
            self.badgeLabel.text = String(badge)
        }
    }

    private func setShadowView() {
        self.shadowView.clipsToBounds = true
        self.shadowView.layer.cornerRadius = self.frame.size.width / 2
        self.shadowView.layer.masksToBounds = true
        self.shadowView.backgroundColor = Palette.blue.lightPrimaryColor
        self.shadowView.alpha = 0.8
        self.addSubview(self.shadowView)

        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(format: "H:|[view]|", views: ["view": self.shadowView])
        self.addConstraints(format: "V:|[view]|", views: ["view": self.shadowView])
    }

    private func setBackGroundView() {
        self.backgroundView.clipsToBounds = true
        self.backgroundView.layer.cornerRadius = self.frame.size.width / 2 - padding
        self.backgroundView.layer.masksToBounds = true
        self.backgroundView.backgroundColor = Palette.blue.primaryColor
        self.backgroundView.layer.borderWidth = 1
        self.backgroundView.layer.borderColor = UIColor.white.cgColor
        self.backgroundView.alpha = 0.8
        self.addSubview(self.backgroundView)

        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(format: "H:|-\(padding)-[view]-\(padding)-|", views: ["view": self.backgroundView])
        self.addConstraints(format: "V:|-\(padding)-[view]-\(padding)-|", views: ["view": self.backgroundView])
    }

    private func setBadgeLabel() {
        self.badgeLabel.textColor = UIColor.white
        self.badgeLabel.textAlignment = .center
        self.badgeLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.badgeLabel.numberOfLines = 0
        self.addSubview(badgeLabel)

        self.badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(format: "H:|-\(padding)-[view]-\(padding)-|", views: ["view": self.badgeLabel])
        self.addConstraints(format: "V:|-\(padding)-[view]-\(padding)-|", views: ["view": self.badgeLabel])
    }
}

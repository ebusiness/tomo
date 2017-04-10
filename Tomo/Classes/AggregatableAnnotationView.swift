//
//  AggregatableAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/09/30.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation

class AggregatableAnnotationView: MKAnnotationView {
    private var titleView: TitleView!
    private var badgeView: BadgeView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        self.canShowCallout = false

        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)

        self.setTitleView()
        self.setBadgeView()

        self.setupDisplay()
    }

    private func setTitleView() {
        guard let annotation = self.annotation as? AggregatableAnnotation else { return }
        self.titleView = TitleView()
        self.titleView.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        self.addSubview(self.titleView)
        self.titleView.title = annotation.title
    }

    private func setBadgeView() {
        guard let annotation = self.annotation as? AggregatableAnnotation else { return }
        self.badgeView = BadgeView()
        self.badgeView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.addSubview(self.badgeView)
        self.badgeView.badge = annotation.containedAnnotations.count
    }

    func setupDisplay() {
        guard let annotation = self.annotation as? AggregatableAnnotation else { return }
        self.titleView.isHidden = !annotation.containedAnnotations.isEmpty
        self.badgeView.isHidden = annotation.containedAnnotations.isEmpty

        let annotationsCount = annotation.containedAnnotations.count

        if annotationsCount > 0 {
            self.badgeView.badge = annotationsCount
        }

        var exRate: CGFloat = 1
        switch annotationsCount {
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

fileprivate final class TitleView: UIView {
    private let backgroundView = UIView()
    private let titleLabel = UILabel()

    var title: String? {
        didSet {
            self.setBackGroundView()
            self.setTitleLabel()
            self.titleLabel.text = self.title
        }
    }

    private func setBackGroundView() {
        if self.backgroundView.superview != nil { return }
        self.backgroundView.clipsToBounds = true
        self.backgroundView.layer.cornerRadius = 5
        self.backgroundView.layer.masksToBounds = true
        self.backgroundView.backgroundColor = Palette.blue.primaryColor
        self.backgroundView.layer.borderWidth = 1
        self.backgroundView.layer.borderColor = UIColor.white.cgColor
        self.backgroundView.alpha = 0.8
        self.addSubview(self.backgroundView)

        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(format: "H:|[view]|", views: ["view": self.backgroundView])
        self.addConstraints(format: "V:|[view]|", views: ["view": self.backgroundView])
    }

    private func setTitleLabel() {
        if self.titleLabel.superview != nil { return }
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        self.titleLabel.numberOfLines = 0
        self.addSubview(titleLabel)

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(format: "H:|[view]|", views: ["view": self.titleLabel])
        self.addConstraints(format: "V:|[view]|", views: ["view": self.titleLabel])
    }

}

fileprivate final class BadgeView: UIView {
    private let shadowView = UIView()
    private let backgroundView = UIView()
    private let badgeLabel = UILabel()

    private let padding: CGFloat = 10

    var badge: Int? {
        didSet {
            self.setShadowView()
            self.setBackGroundView()
            self.setBadgeLabel()
            self.badgeLabel.text = String(self.badge! + 1)
        }
    }

    private func setShadowView() {
        if self.shadowView.superview != nil { return }
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
        if self.backgroundView.superview != nil { return }
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
        if self.badgeLabel.superview != nil { return }
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

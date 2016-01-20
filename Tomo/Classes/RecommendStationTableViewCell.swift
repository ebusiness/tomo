//
//  RecommendStationTableViewCell.swift
//  Tomo
//
//  Created by ebuser on 2015/09/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RecommendStationTableCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var groups: [GroupEntity]!
    weak var delegate: HomeViewController!
    
    /// cell container --- used for search
    weak var tableViewController: HomeViewController?
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    
    func setup() {
        collectionView.reloadData()
    }
}

extension RecommendStationTableCell {
    @IBAction func discoverMoreStation(sender: AnyObject) {
        tableViewController?.discoverMoreStation()
    }
}

extension RecommendStationTableCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StationCell", forIndexPath: indexPath) as! StationCollectionViewCell
        cell.group = groups[indexPath.item]
        cell.setupDisplay()
        return cell
    }
}

extension RecommendStationTableCell:UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let group = self.groups[indexPath.item]

        let groupVC = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        groupVC.group = group
        self.delegate?.navigationController?.pushViewController(groupVC, animated: true)

    }
}

extension RecommendStationTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let height = CGFloat(250.0)
        let width = height / 4 * 3
        
        return CGSizeMake(width, height)
    }
}

class StationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var watchButton: UIButton!

    var group: GroupEntity!

    private var isWatched = false

    func setupDisplay() {

        self.nameLabel.text = self.group.name

        backgroundImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)

        self.contentView.layer.cornerRadius = 5
        self.contentView.clipsToBounds = true

        watchButton.layer.borderColor = UIColor.whiteColor().CGColor
        watchButton.layer.borderWidth = 1
        watchButton.layer.cornerRadius = 2

        guard let myGroup = me.groups else {
            self.isWatched = false
            return
        }

        if myGroup.contains(self.group.id) {

            self.isWatched = true
            self.watchButton.backgroundColor = Palette.Red.primaryColor
            self.watchButton.setTitle("  退出  ", forState: .Normal)
            self.watchButton.sizeToFit()

        } else {

            self.isWatched = false
            self.watchButton.backgroundColor = Palette.Green.primaryColor
            self.watchButton.setTitle("  加入  ", forState: .Normal)
            self.watchButton.sizeToFit()
        }
    }

    @IBAction func watchButtonTapped(sender: AnyObject) {

        if self.isWatched {

            Router.Group.Leave(id: group.id).response {
                if $0.result.isFailure { return }

                let group = GroupEntity($0.result.value!)
                me.groups?.remove(group.id)
                self.isWatched = false

                UIView.animateWithDuration(0.3, animations: {
                    self.watchButton.backgroundColor = Palette.Green.primaryColor
                    self.watchButton.setTitle("  加入  ", forState: .Normal)
                    self.watchButton.sizeToFit()
                    self.setNeedsLayout()
                })
            }

        } else  {

            Router.Group.Join(id: group.id).response {
                if $0.result.isFailure { return }

                let group = GroupEntity($0.result.value!)
                me.addGroup(group.id)
                self.isWatched = true

                UIView.animateWithDuration(0.3, animations: {
                    self.watchButton.backgroundColor = Palette.Red.primaryColor
                    self.watchButton.setTitle("  退出  ", forState: .Normal)
                    self.watchButton.sizeToFit()
                    self.setNeedsLayout()
                })
            }
        }
        
    }
    
}
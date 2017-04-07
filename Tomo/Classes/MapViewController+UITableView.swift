//
//  MapViewController+UITableView
//  Tomo
//
//  Created by starboychina on 2017/03/29.
//  Copyright © 2015 e-business. All rights reserved.
//

// MARK: - UITableViewDataSource
extension MapViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.annotationsForTable?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let userAnnotation = self.annotationsForTable![indexPath.item] as? UserAnnotation {

            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell
            cell?.user = userAnnotation.user
            cell?.setupDisplay()
            return cell!

        } else if let groupAnnotation = self.annotationsForTable![indexPath.item] as? GroupAnnotation {

            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as? GroupCell
            cell?.group = groupAnnotation.group
            cell?.setupDisplay()
            return cell!

        } else if let annotation = self.annotationsForTable![indexPath.item] as? CompanyAnnotation {

            let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyCell", for: indexPath) as? CompanyCell
            cell?.company = annotation.entity
            return cell!
            
        } else {
            return UITableViewCell()
        }

    }

}

// MARK: - UITableViewDelegate
extension MapViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if let userAnnotation = self.annotationsForTable![indexPath.item] as? UserAnnotation {
            let pvc = Util.createViewController(storyboardName: "Profile", id: "UserPostsView") as? UserPostsViewController
            pvc?.user = userAnnotation.user
            self.navigationController?.pushViewController(pvc!, animated: true)
        }

        if let groupAnnotation = self.annotationsForTable![indexPath.item] as? GroupAnnotation {
            let pvc = Util.createViewController(storyboardName: "Group", id: "GroupDetailView") as? GroupDetailViewController
            pvc?.group = groupAnnotation.group
            self.navigationController?.pushViewController(pvc!, animated: true)
        }
    }
}

class UserCell: UITableViewCell {

    @IBOutlet weak fileprivate var avatarImageView: UIImageView!
    @IBOutlet weak fileprivate var userNameLabel: UILabel!
    @IBOutlet weak fileprivate var bioLabel: UILabel!
    @IBOutlet weak fileprivate var stationLabel: UILabel!

    var user: UserEntity!

    func setupDisplay() {

//        if let photo = user.photo {
//            avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: defaultAvatarImage)
//        }
//
//        userNameLabel.text = user.nickName
//        bioLabel.text = user.bio
//        if let groupName = user.primaryGroup?.name {
//            stationLabel.text = "\(groupName)"
//        }
    }

}

class GroupCell: UITableViewCell {

    @IBOutlet weak fileprivate var coverImageView: UIImageView!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var introLabel: UILabel!
    @IBOutlet weak fileprivate var memberLabel: UILabel!

    var group: GroupEntity!

    func setupDisplay() {

        if let cover = group.cover {
            coverImageView.sd_setImage(with: URL(string: cover), placeholderImage: defaultGroupImage)
        }

        nameLabel.text = group.name
        introLabel.text = group.introduction
        memberLabel.text = "\(group.members!.count)个成员"
    }
    
}

class CompanyCell: UITableViewCell {

    @IBOutlet weak fileprivate var nameLabel: UILabel!

    var company: CompanyEntity! {
        didSet {
            nameLabel.text = company.name
        }
    }
    
}


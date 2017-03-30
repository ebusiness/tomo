//
//  GroupPopoverViewController.swift
//  Tomo
//
//  Created by starboychina on 2017/03/30.
//  Copyright © 2017 e-business. All rights reserved.
//

// MARK: - GroupPopoverViewController
final class GroupPopoverViewController: UIViewController {

    var groupAnnotation: GroupAnnotation! {
        didSet {
            self.setupDisplay()
        }
    }

    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var introLabel: UILabel!
    @IBOutlet weak fileprivate var coverImageView: UIImageView!
    @IBOutlet weak fileprivate var joinButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDisplay()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func joinButtonTapped(_ sender: Any) {

        guard let delegate = UIApplication.shared.delegate else { return }
        guard let window = delegate.window else { return }
        guard let rootViewController = window?.rootViewController else { return }

        Router.Group.Join(id: groupAnnotation.group.id).response {

            guard $0.result.isSuccess else { return }
            me.primaryStation = self.groupAnnotation.group

            var param = Router.Setting.MeParameter()
            param.primaryStation = self.groupAnnotation.group.id

            Router.Setting.UpdateUserInfo(parameters: param).response {

                guard $0.result.isSuccess else { return }

                if
                    let rvc = self.presentationController?.delegate as? RecommendViewController,
                    let exitAction = rvc.exitAction {
                    me.primaryStation = self.groupAnnotation.group
                    self.dismiss(animated: true) { _ in
                        exitAction()
                    }
                    return
                }

                Util.changeRootViewController(from: rootViewController, to: TabBarController())
            }
        }
    }

    private func setupDisplay() {
        guard self.isViewLoaded else { return }

        guard let group = groupAnnotation.group else { return }
        self.nameLabel.text = group.name
        self.introLabel.text = group.introduction
        self.coverImageView.sd_setImage(with: URL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup, options: .retryFailed)

        guard let me = me else { return }

        if group.id == me.primaryStation?.id {
            self.joinButton.isHidden = true
        } else {
            self.joinButton.isHidden = false
            self.joinButton.setTitle("设置为当前现场", for: .normal)
        }
    }
}

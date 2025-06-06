import FBSDKLoginKit
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol FindFriendsFacebookConnectCellDelegate: AnyObject {
  func findFriendsFacebookConnectCellDidFacebookConnectUser()
  func findFriendsFacebookConnectCellDidDismissHeader()
  func findFriendsFacebookConnectCellShowErrorAlert(_ alert: AlertError)
}

internal final class FindFriendsFacebookConnectCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var closeButton: UIButton!
  @IBOutlet fileprivate var containerView: UIView!
  @IBOutlet fileprivate var facebookConnectButton: UIButton!
  @IBOutlet fileprivate var subtitleLabel: UILabel!
  @IBOutlet fileprivate var titleLabel: UILabel!

  internal weak var delegate: FindFriendsFacebookConnectCellDelegate?

  fileprivate let viewModel: FindFriendsFacebookConnectCellViewModelType =
    FindFriendsFacebookConnectCellViewModel()

  internal lazy var fbLoginManager: LoginManager = {
    let manager = LoginManager()
    manager.defaultAudience = .friends
    return manager
  }()

  internal func configureWith(value: FriendsSource) {
    self.viewModel.inputs.configureWith(source: value)
  }

  internal override func bindViewModel() {
    self.closeButton.rac.hidden = self.viewModel.outputs.hideCloseButton
    self.titleLabel.rac.text = self.viewModel.outputs.facebookConnectCellTitle
    self.subtitleLabel.rac.text = self.viewModel.outputs.facebookConnectCellSubtitle
    self.facebookConnectButton.rac.title = self.viewModel.outputs.facebookConnectButtonTitle

    self.viewModel.outputs.attemptFacebookLogin
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.attemptFacebookLogin()
      }

    self.viewModel.outputs.notifyDelegateToDismissHeader
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.findFriendsFacebookConnectCellDidDismissHeader()
      }

    self.viewModel.outputs.notifyDelegateUserFacebookConnected
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.findFriendsFacebookConnectCellDidFacebookConnectUser()
      }

    self.viewModel.outputs.postUserUpdatedNotification
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.showErrorAlert
      .observeForUI()
      .observeValues { [weak self] alert in
        self?.delegate?.findFriendsFacebookConnectCellShowErrorAlert(alert)
      }

    self.viewModel.outputs.updateUserInEnvironment
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.viewModel.inputs.userUpdated()
      }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> feedTableViewCellStyle

    _ = self.cardView
      |> cardStyle()

    _ = self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.containerView.backgroundColor = Colors.Background.Surface.primary.uiColor()

    _ = self.titleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
      |> UILabel.lens.contentCompressionResistancePriority(for: .vertical) .~ .required

    _ = self.subtitleLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 12)
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()

    _ = self.closeButton
      |> UIButton.lens.tintColor .~ LegacyColors.ksr_support_700.uiColor()
      |> UIButton.lens.targets .~ [(self, action: #selector(self.closeButtonTapped), .touchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(
        top: Styles.grid(1), left: Styles.grid(3),
        bottom: Styles.grid(3), right: Styles.grid(2)
      )

    _ = self.facebookConnectButton
      |> facebookButtonStyle
      |> UIButton.lens.targets .~ [
        (self, action: #selector(self.facebookConnectButtonTapped), .touchUpInside)
      ]
      |> UIButton.lens.contentCompressionResistancePriority(for: .vertical) .~ .required
  }

  // MARK: - Facebook Login

  fileprivate func attemptFacebookLogin() {
    self.fbLoginManager.logIn(
      permissions: ["public_profile", "email", "user_friends"], from: nil
    ) { result, error in
      if let error = error {
        self.viewModel.inputs.facebookLoginFail(error: error)
      } else if let result = result, !result.isCancelled {
        self.viewModel.inputs.facebookLoginSuccess(result: result)
      }
    }
  }

  @objc func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc func facebookConnectButtonTapped() {
    self.viewModel.inputs.facebookConnectButtonTapped()
  }
}

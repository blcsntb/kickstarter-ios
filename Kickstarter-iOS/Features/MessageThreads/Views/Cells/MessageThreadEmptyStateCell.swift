import KsApi
import Library
import Prelude
import UIKit

internal final class MessageThreadEmptyStateCell: UITableViewCell, ValueCell {
  @IBOutlet private var titleLabel: UILabel!

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 18.0)
      |> UILabel.lens.text %~ { _ in Strings.messages_empty_state_title() }
  }

  internal func configureWith(value _: Void) {}
}

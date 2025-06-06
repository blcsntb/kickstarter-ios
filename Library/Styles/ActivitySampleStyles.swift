import Prelude
import Prelude_UIKit
import UIKit

public let activitySampleBackingTitleLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.lineBreakMode .~ .byTruncatingTail

public let activitySampleCellStyle: (UITableViewCell) -> UITableViewCell = { cell in
  cell |> baseTableViewCellStyle()
    |> UITableViewCell.lens.backgroundColor .~ .clear
    |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, view in
      view.traitCollection.isRegularRegular
        ? .init(top: Styles.grid(4), left: Styles.grid(30), bottom: Styles.grid(3), right: Styles.grid(30))
        : .init(top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(3), right: Styles.grid(2))
    }
}

public let activitySampleFriendFollowLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.lineBreakMode .~ .byTruncatingTail
    <> UILabel.lens.font .~ .ksr_subhead()

public let activitySampleProjectSubtitleLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.lineBreakMode .~ .byTruncatingTail
    <> UILabel.lens.font .~ .ksr_subhead()

public let activitySampleProjectTitleLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.lineBreakMode .~ .byTruncatingTail
    <> UILabel.lens.font .~ UIFont.ksr_subhead().bolded

public let activitySampleSeeAllActivityButtonStyle = greyButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in
    Strings.discovery_activity_sample_button_see_all_activity()
  }

public let activitySampleStackViewStyle =
  UIStackView.lens.spacing .~ Styles.grid(3)
    <> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

public let activitySampleTitleLabelStyle =
  UILabel.lens.font .~ .ksr_footnote()
    <> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.numberOfLines .~ 1
    <> UILabel.lens.lineBreakMode .~ .byTruncatingTail
    <> UILabel.lens.text %~ { _ in Strings.discovery_activity_sample_title_Since_your_last_visit() }

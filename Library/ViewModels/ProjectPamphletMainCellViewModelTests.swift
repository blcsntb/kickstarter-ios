@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectPamphletMainCellViewModelTests: TestCase {
  private let vm: ProjectPamphletMainCellViewModelType = ProjectPamphletMainCellViewModel()

  private let backingLabelHidden = TestObserver<Bool, Never>()
  private let backersTitleLabelText = TestObserver<String, Never>()
  private let conversionLabelHidden = TestObserver<Bool, Never>()
  private let conversionLabelText = TestObserver<String, Never>()
  private let creatorImageUrl = TestObserver<String?, Never>()
  private let creatorLabelText = TestObserver<String, Never>()
  private let deadlineSubtitleLabelText = TestObserver<String, Never>()
  private let deadlineTitleLabelText = TestObserver<String, Never>()
  private let fundingProgressBarViewBackgroundColor = TestObserver<UIColor, Never>()
  private let isPrelaunchProject = TestObserver<Bool, Never>()
  private let notifyDelegateToGoToCreator = TestObserver<any ProjectPamphletMainCellConfiguration, Never>()
  private let opacityForViews = TestObserver<CGFloat, Never>()
  private let pledgedSubtitleLabelText = TestObserver<String, Never>()
  private let pledgedTitleLabelText = TestObserver<String, Never>()
  private let pledgedTitleLabelTextColor = TestObserver<UIColor, Never>()
  private let prelaunchProjectBackingText = TestObserver<String, Never>()
  private let progressPercentage = TestObserver<Float, Never>()
  private let projectBlurbLabelText = TestObserver<String, Never>()
  private let projectImageUrl = TestObserver<String?, Never>()
  private let projectNameLabelText = TestObserver<String, Never>()
  private let projectStateLabelText = TestObserver<String, Never>()
  private let projectStateLabelTextColor = TestObserver<UIColor, Never>()
  private let projectUnsuccessfulLabelTextColor = TestObserver<UIColor, Never>()
  private let stateLabelHidden = TestObserver<Bool, Never>()
  private let statsStackViewAccessibilityLabel = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.statsStackViewAccessibilityLabel
      .observe(self.statsStackViewAccessibilityLabel.observer)
    self.vm.outputs.backersTitleLabelText.observe(self.backersTitleLabelText.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.creatorImageUrl.map { $0?.absoluteString }.observe(self.creatorImageUrl.observer)
    self.vm.outputs.creatorLabelText.observe(self.creatorLabelText.observer)
    self.vm.outputs.deadlineSubtitleLabelText.observe(self.deadlineSubtitleLabelText.observer)
    self.vm.outputs.deadlineTitleLabelText.observe(self.deadlineTitleLabelText.observer)
    self.vm.outputs.fundingProgressBarViewBackgroundColor
      .observe(self.fundingProgressBarViewBackgroundColor.observer)
    self.vm.outputs.notifyDelegateToGoToCreator.observe(self.notifyDelegateToGoToCreator.observer)
    self.vm.outputs.opacityForViews.observe(self.opacityForViews.observer)
    self.vm.outputs.pledgedSubtitleLabelText.observe(self.pledgedSubtitleLabelText.observer)
    self.vm.outputs.pledgedTitleLabelText.observe(self.pledgedTitleLabelText.observer)
    self.vm.outputs.pledgedTitleLabelTextColor.observe(self.pledgedTitleLabelTextColor.observer)
    self.vm.outputs.progressPercentage.observe(self.progressPercentage.observer)
    self.vm.outputs.projectBlurbLabelText.observe(self.projectBlurbLabelText.observer)
    self.vm.outputs.projectImageUrl.map { $0?.absoluteString }.observe(self.projectImageUrl.observer)
    self.vm.outputs.projectNameLabelText.observe(self.projectNameLabelText.observer)
    self.vm.outputs.projectStateLabelText.observe(self.projectStateLabelText.observer)
    self.vm.outputs.projectStateLabelTextColor.observe(self.projectStateLabelTextColor.observer)
    self.vm.outputs.projectUnsuccessfulLabelTextColor.observe(self.projectUnsuccessfulLabelTextColor.observer)
    self.vm.outputs.stateLabelHidden.observe(self.stateLabelHidden.observer)
    self.vm.outputs.backingLabelHidden.observe(self.backingLabelHidden.observer)
    self.vm.outputs.isPrelaunchProject.observe(self.isPrelaunchProject.observer)
    self.vm.outputs.prelaunchProjectBackingText.observe(self.prelaunchProjectBackingText.observer)
  }

  func testStatsStackViewAccessibilityLabel() {
    let project = .template
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 10)
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.statsStackViewAccessibilityLabel.assertValues(
      ["$1,000 of $2,000 goal, 10 backers so far, 10 days to go to go"]
    )

    let nonUSProject = project
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 1.2
      |> Project.lens.stats.convertedPledgedAmount .~ 1_200
    self.vm.inputs.configureWith(value: (nonUSProject, nil))

    self.statsStackViewAccessibilityLabel.assertValues(
      [
        "$1,000 of $2,000 goal, 10 backers so far, 10 days to go to go",
        "$1,200 of $2,400 goal, 10 backers so far, 10 days to go to go"
      ]
    )

    let nonUSProjectCurrencyProject = project
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.es.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 1.2
      |> Project.lens.stats.convertedPledgedAmount .~ 1_200
    self.vm.inputs.configureWith(value: (nonUSProjectCurrencyProject, nil))

    self.statsStackViewAccessibilityLabel.assertValues(
      [
        "$1,000 of $2,000 goal, 10 backers so far, 10 days to go to go",
        "$1,200 of $2,400 goal, 10 backers so far, 10 days to go to go",
        "$1,200 of $2,400 goal, 10 backers so far, 10 days to go to go"
      ]
    )

    let nonUSUserCurrency = project
      |> Project.lens.stats.userCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 2.0

    self.vm.inputs.configureWith(value: (nonUSUserCurrency, nil))

    self.statsStackViewAccessibilityLabel.assertValues(
      [
        "$1,000 of $2,000 goal, 10 backers so far, 10 days to go to go",
        "$1,200 of $2,400 goal, 10 backers so far, 10 days to go to go",
        "$1,200 of $2,400 goal, 10 backers so far, 10 days to go to go",
        "£2,000 of £4,000 goal, 10 backers so far, 10 days to go to go"
      ]
    )
  }

  func testStatsStackViewAccessibilityLabel_defaultCurrency_nonUSUser() {
    let defaultUserCurrency = Project.template
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 10)
      |> Project.lens.stats.projectCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.staticUsdRate .~ 2.0

    withEnvironment(countryCode: "CA") {
      self.vm.inputs.configureWith(value: (defaultUserCurrency, nil))
      self.vm.inputs.awakeFromNib()

      self.statsStackViewAccessibilityLabel.assertValues(
        ["US$ 2,000 of US$ 4,000 goal, 10 backers so far, 10 days to go to go"]
      )
    }
  }

  func testBackingLabelHidden_NotABacker() {
    let project = .template |> Project.lens.personalization.isBacking .~ false
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.backingLabelHidden.assertValues([true])
  }

  func testBackingLabelHidden_NotABacker_VideoInteraction() {
    let project = .template |> Project.lens.personalization.isBacking .~ false
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.backingLabelHidden.assertValues([true])

    self.vm.inputs.videoDidStart()

    self.backingLabelHidden.assertValues([true])

    self.vm.inputs.videoDidFinish()

    self.backingLabelHidden.assertValues([true])
  }

  func testBackingLabelHidden_LoggedOut() {
    let project = .template |> Project.lens.personalization.isBacking .~ nil
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.backingLabelHidden.assertValues([true])
  }

  func testBackingLabelHidden_Backer() {
    let project = .template |> Project.lens.personalization.isBacking .~ true
      |> \.displayPrelaunch .~ false
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.backingLabelHidden.assertValues([false])
    self.isPrelaunchProject.assertValues([false])
    self.prelaunchProjectBackingText.assertValues(["You’re a backer!"])
  }

  func testBackingLabelHidden_PrelaunchProject() {
    let project = .template |> Project.lens.personalization.isBacking .~ false
      |> \.displayPrelaunch .~ true
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.backingLabelHidden.assertValues([false])
    self.isPrelaunchProject.assertValues([true])
    self.prelaunchProjectBackingText.assertValues(["Coming soon"])
  }

  func testBackingLabelHidden_Backer_VideoInteraction() {
    let project = .template |> Project.lens.personalization.isBacking .~ true
      |> \.displayPrelaunch .~ false
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.backingLabelHidden.assertValues([false])

    self.vm.inputs.videoDidStart()

    self.backingLabelHidden.assertValues([false, true])

    self.vm.inputs.videoDidFinish()

    self.backingLabelHidden.assertValues([false, true, false])
  }

  func testCreatorImageUrl() {
    let project = .template
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ "hello.jpg"
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()
    self.creatorImageUrl.assertValues(["hello.jpg"])
  }

  func testCreatorLabelText() {
    let project = Project.template |> Project.lens.creator.name .~ "Creator Blob"
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()
    self.creatorLabelText.assertValues(["by Creator Blob"])
  }

  func testProjectBlurbLabelText() {
    let project = Project.template |> Project.lens.blurb .~ "The elevator pitch"
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()
    self.projectBlurbLabelText.assertValues(["The elevator pitch"])
  }

  func testProjectImageUrl() {
    let project = .template
      |> Project.lens.photo.full .~ "project.jpg"
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()
    self.projectImageUrl.assertValues(["project.jpg"])
  }

  func testProjectNameLabelText() {
    let project = Project.template |> Project.lens.blurb .~ "The elevator pitch"
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()
    self.projectBlurbLabelText.assertValues(["The elevator pitch"])
  }

  func testBackersTitleLabel() {
    let project = .template |> Project.lens.stats.backersCount .~ 1_000
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.backersTitleLabelText.assertValues([Format.wholeNumber(project.stats.backersCount)])
  }

  // MARK: - Conversion Label

  func testConversionLabel_WhenConversionNotNeeded_US_Project_US_ProjectCurrency_US_User() {
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.conversionLabelText.assertValueCount(0)
      self.conversionLabelHidden.assertValues([true])
    }
  }

  func testConversionLabel_WhenConversionNeeded_US_Project_US_ProjectCurrency_NonUS_User() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.pledged .~ 1_000
      |> Project.lens.stats.goal .~ 2_000
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.ca.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 1.3

    withEnvironment(countryCode: "CA") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.conversionLabelText.assertValues(["Converted from US$ 1,000 pledged of US$ 2,000 goal."])
      self.conversionLabelHidden.assertValues([false])
    }
  }

  func testConversionLabel_WhenConversionNeeded_NonUS_Project_NonUS_ProjectCurrency_US_User() {
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.goal .~ 2
      |> Project.lens.stats.pledged .~ 1

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.conversionLabelText.assertValues(["Converted from £1 pledged of £2 goal."])
      self.conversionLabelHidden.assertValues([false])
    }
  }

  func testConversionLabel_WhenConversionNeeded_NonUS_Project_DifferentNonUS_ProjectCurrency_US_User() {
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.es.currencyCode
      |> Project.lens.stats.goal .~ 2
      |> Project.lens.stats.pledged .~ 1

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.conversionLabelText.assertValues(["Converted from €1 pledged of €2 goal."])
      self.conversionLabelHidden.assertValues([false])
    }
  }

  func testDeadlineLabels() {
    let project = .template
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 4)

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.deadlineTitleLabelText.assertValues(["4"])
    self.deadlineSubtitleLabelText.assertValues(["days to go"])
  }

  func testFundingProgressBarViewBackgroundColor_UnsuccessfulProject() {
    let project = .template
      |> Project.lens.state .~ .failed

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.fundingProgressBarViewBackgroundColor.assertValues([LegacyColors.ksr_support_400.uiColor()])
  }

  func testFundingProgressBarViewBackgroundColor_SuccessfulProject() {
    let project = .template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.fundingProgressBarViewBackgroundColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
  }

  func testPledgedTitleLabelTextColor_SucessfulProject() {
    let project = .template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.pledgedTitleLabelTextColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
  }

  func testPledgedTitleLabelTextColor_UnsuccessfulProject() {
    let project = .template
      |> Project.lens.state .~ .canceled

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.pledgedTitleLabelTextColor.assertValues([LegacyColors.ksr_support_400.uiColor()])
  }

  // MARK: - Pledged Label

  func testPledgedLabels_WhenConversionNotNeeded() {
    let project = .template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.pledged .~ 1_000
      |> Project.lens.stats.goal .~ 2_000

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(["$1,000"])
      self.pledgedSubtitleLabelText.assertValues(["pledged of $2,000"])
    }
  }

  func testPledgedLabels_WhenConversionNotNeeded_NonUS_Location() {
    let project = Project.template

    withEnvironment(countryCode: "CA") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(
        ["US$ 1,000"]
      )
      self.pledgedSubtitleLabelText.assertValues(
        ["pledged of US$ 2,000"]
      )
    }
  }

  func testPledgedLabels_WhenConversionNeeded() {
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 2.0

    withEnvironment(countryCode: "US") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(["$2,000"])
      self.pledgedSubtitleLabelText.assertValues(["pledged of $4,000"])
    }
  }

  func testPledgedLabels_ConversionNotNeeded_NonUSCountry() {
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.pledged .~ 1
      |> Project.lens.stats.goal .~ 2

    withEnvironment(countryCode: "GB") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(["£1"])
      self.pledgedSubtitleLabelText.assertValues(["pledged of £2"])
    }
  }

  func testPledgedLabels_ConversionNeeded_NonUSCountry_DifferentNonUS_ProjectCurrency() {
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.convertedPledgedAmount .~ 4
      |> Project.lens.stats.pledged .~ 1
      |> Project.lens.stats.goal .~ 20
      |> Project.lens.stats.userCurrencyRate .~ 2.0

    withEnvironment(countryCode: "GB") {
      self.vm.inputs.configureWith(value: (project, nil))
      self.vm.inputs.awakeFromNib()

      self.pledgedTitleLabelText.assertValues(["£4"])
      self.pledgedSubtitleLabelText.assertValues(["pledged of £40"])
    }
  }

  func testProgressPercentage_UnderFunded() {
    let project = .template
      |> Project.lens.stats.pledged .~ 100
      |> Project.lens.stats.goal .~ 200
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.progressPercentage.assertValues([0.5])
  }

  func testProgressPercentage_OverFunded() {
    let project = .template
      |> Project.lens.stats.pledged .~ 300
      |> Project.lens.stats.goal .~ 200
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.progressPercentage.assertValues([1.0])
  }

  func testProjectStateLabelTextColor_SuccessfulProject() {
    let project = .template
      |> Project.lens.state .~ .successful
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.projectStateLabelTextColor.assertValues([LegacyColors.ksr_create_700.uiColor()])
  }

  func testProjectStateLabelTextColor_UnsuccessfulProject() {
    let project = .template
      |> Project.lens.state .~ .failed
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.projectStateLabelTextColor.assertValues([LegacyColors.ksr_support_400.uiColor()])
  }

  func testProjectUnsuccessfulLabelTextColor_SuccessfulProjects() {
    let project = .template
      |> Project.lens.state .~ .failed
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.projectUnsuccessfulLabelTextColor.assertValues([LegacyColors.ksr_support_400.uiColor()])
  }

  func testProjectUnsuccessfulLabelTextColor_UnsuccessfulProjects() {
    let project = .template
      |> Project.lens.state .~ .failed
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.projectUnsuccessfulLabelTextColor.assertValues([LegacyColors.ksr_support_400.uiColor()])
  }

  func testStateLabelHidden_LiveProject() {
    let project = .template
      |> Project.lens.state .~ .live
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.stateLabelHidden.assertValues([true])
  }

  func testStateLabelHidden_NonLiveProject() {
    let project = .template
      |> Project.lens.state .~ .successful
    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    self.stateLabelHidden.assertValues([false])
  }

  func testViewTransition() {
    self.opacityForViews.assertValueCount(0)

    self.vm.inputs.awakeFromNib()

    self.opacityForViews.assertValues([0.0])

    self.vm.inputs.configureWith(value: (Project.template, nil))

    self.opacityForViews.assertValues([0.0, 1.0], "Fade in views after project comes in.")
  }

  func testNotifyDelegateToGoToCreator() {
    let project = Project.template

    XCTAssertTrue(self.notifyDelegateToGoToCreator.values.isEmpty)

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.awakeFromNib()

    XCTAssertTrue(self.notifyDelegateToGoToCreator.values.isEmpty)

    self.vm.inputs.creatorButtonTapped()

    XCTAssertEqual(self.notifyDelegateToGoToCreator.values.count, 1)
    XCTAssertEqual(
      self.notifyDelegateToGoToCreator.values.first?.projectPamphletMainCellProperties.param.id,
      project.id
    )

    XCTAssertEqual(["CTA Clicked"], self.segmentTrackingClient.events)
    XCTAssertEqual("creator_details", self.segmentTrackingClient.properties.last?["context_cta"] as? String)
  }
}

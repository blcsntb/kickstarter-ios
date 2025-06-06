@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeSummaryViewModelTests: TestCase {
  private let vm: PledgeSummaryViewModelType = PledgeSummaryViewModel()

  private let amountLabelAttributedText = TestObserver<NSAttributedString, Never>()
  private let amountLabelText = TestObserver<String, Never>()

  private let confirmationLabelAttributedText = TestObserver<NSAttributedString, Never>()
  private let confirmationLabelText = TestObserver<String, Never>()
  private let confirmationLabelHidden = TestObserver<Bool, Never>()
  private let notifyDelegateOpenHelpType = TestObserver<HelpType, Never>()
  private var pledgeOverTimeStackViewHidden = TestObserver<Bool, Never>()
  private var pledgeOverTimeChargesText = TestObserver<String, Never>()
  private let totalConversionLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateOpenHelpType.observe(self.notifyDelegateOpenHelpType.observer)
    self.vm.outputs.amountLabelAttributedText.observe(self.amountLabelAttributedText.observer)
    self.vm.outputs.amountLabelAttributedText.map { $0.string }
      .observe(self.amountLabelText.observer)
    self.vm.outputs.confirmationLabelAttributedText.observe(self.confirmationLabelAttributedText.observer)
    self.vm.outputs.confirmationLabelAttributedText.map { $0.string }
      .observe(self.confirmationLabelText.observer)
    self.vm.outputs.confirmationLabelHidden.observe(self.confirmationLabelHidden.observer)
    self.vm.outputs.pledgeOverTimeStackViewHidden.observe(self.pledgeOverTimeStackViewHidden.observer)
    self.vm.outputs.pledgeOverTimeChargesText.observe(self.pledgeOverTimeChargesText.observer)
    self.vm.outputs.totalConversionLabelText.observe(self.totalConversionLabelText.observer)
  }

  func testNotifyDelegateOpenHelpType() {
    let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    let allCases = HelpType.allCases.filter { $0 != .contact }

    let allHelpTypeUrls = allCases.map { $0.url(withBaseUrl: baseUrl) }.compact()

    allHelpTypeUrls.forEach { self.vm.inputs.tapped($0) }

    self.notifyDelegateOpenHelpType.assertValues(allCases)
  }

  func testAmountAttributedText_US_ProjectCurrency_RegularReward() {
    let project = Project.cosmicSurgery
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.country .~ Project.Country.us

    self.vm.inputs.configure(with: (project, total: 30, false, false))
    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues(["$30.00"], "Total is added to reward minimum")
  }

  func testAmountAttributedText_NonUS_ProjectCurrency_RegularReward() {
    let project = Project.cosmicSurgery
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us

    self.vm.inputs.configure(with: (project, total: 30, false, false))
    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues([" MX$ 30.00"], "Total is added to reward minimum")
  }

  func testAmountAttributedText_US_ProjectCurrency_NoReward() {
    let project = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.country .~ Project.Country.us
    self.vm.inputs.configure(with: (project, total: 10, false, true))

    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues(["$10.00"], "Total is used directly")
  }

  func testAmountAttributedText_NonUS_ProjectCurrency_NoReward() {
    let project = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us
    let pledgeSummaryViewData = PledgeSummaryViewData(project, total: 10, false, true)

    self.vm.inputs.configure(with: pledgeSummaryViewData)

    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues([" MX$ 10.00"], "Total is used directly")
  }

  func testTotalConversionText_NeedsConversion_NoReward() {
    let project = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 2.0

    self.vm.inputs.configure(with: (project, total: 10, false, true))
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertValues(["About £20.00"])
  }

  func testTotalConversionText_NeedsConversion_RegularReward() {
    let project = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.userCurrencyRate .~ 2.0

    self.vm.inputs.configure(with: (project, total: 20, false, false))
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertValues(["About £40.00"])
  }

  func testTotalConversionText_NoConversionNeeded() {
    let project = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.userCurrency .~ nil
      |> Project.lens.stats.userCurrencyRate .~ nil

    self.vm.inputs.configure(with: (project, total: 10, false, false))
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertDidNotEmitValue()
  }

  func testUpdateContext_ConfirmationLabel() {
    let dateComponents = DateComponents()
      |> \.month .~ 11
      |> \.day .~ 1
      |> \.year .~ 2_019
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en")) {
      let date = AppEnvironment.current.calendar.date(from: dateComponents)

      let project = Project.template
        |> Project.lens.dates.deadline .~ date!.timeIntervalSince1970
        |> Project.lens.stats.userCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.projectCurrency .~ Currency.USD.rawValue

      self.vm.inputs.configure(with: (project: project, total: 10, false, false))
      self.vm.inputs.configureWith(pledgeOverTimeData: nil)
      self.vm.inputs.viewDidLoad()

      self.confirmationLabelHidden.assertValues([false])
      self.confirmationLabelAttributedText.assertValueCount(1)
      self.confirmationLabelText.assertValues([
        "If the project reaches its funding goal, you will be charged $10 on November 1, 2019. You will receive a proof of pledge that will be redeemable if the project is funded and the creator is successful at completing the creative venture."
      ])
    }
  }

  func testUpdateContext_ConfirmationLabel_Hidden() {
    let dateComponents = DateComponents()
      |> \.month .~ 11
      |> \.day .~ 1
      |> \.year .~ 2_019
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en")) {
      let date = AppEnvironment.current.calendar.date(from: dateComponents)

      let project = Project.template
        |> Project.lens.dates.deadline .~ date!.timeIntervalSince1970
        |> Project.lens.stats.userCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.projectCurrency .~ Currency.USD.rawValue

      self.vm.inputs.configure(with: (project: project, total: 10, true, false))
      self.vm.inputs.configureWith(pledgeOverTimeData: nil)
      self.vm.inputs.viewDidLoad()

      self.confirmationLabelHidden.assertValues([true])
      self.confirmationLabelAttributedText.assertValueCount(1)
      self.confirmationLabelText.assertValues([
        "If the project reaches its funding goal, you will be charged $10 on November 1, 2019. You will receive a proof of pledge that will be redeemable if the project is funded and the creator is successful at completing the creative venture."
      ])
    }
  }

  func testUpdateContext_NonUS_ProjectCurrency_US_ProjectCountry_ConfirmationLabelShowsTotalAmount() {
    let dateComponents = DateComponents()
      |> \.month .~ 11
      |> \.day .~ 1
      |> \.year .~ 2_019
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en")) {
      let date = AppEnvironment.current.calendar.date(from: dateComponents)

      let project = Project.template
        |> Project.lens.dates.deadline .~ date!.timeIntervalSince1970
        |> Project.lens.stats.userCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.projectCurrency .~ Currency.HKD.rawValue
        |> Project.lens.country .~ .us

      self.vm.inputs.configure(with: (project: project, total: 10, false, false))
      self.vm.inputs.configureWith(pledgeOverTimeData: nil)
      self.vm.inputs.viewDidLoad()

      self.confirmationLabelHidden.assertValues([false])
      self.confirmationLabelAttributedText.assertValueCount(1)
      self.confirmationLabelText.assertValues([
        "If the project reaches its funding goal, you will be charged HK$ 10 on November 1, 2019. You will receive a proof of pledge that will be redeemable if the project is funded and the creator is successful at completing the creative venture."
      ])
    }
  }

  func testPledgeOverTime_PledgeInFull() {
    let dateComponents = DateComponents()
      |> \.month .~ 11
      |> \.day .~ 1
      |> \.year .~ 2_019
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en")) {
      let date = AppEnvironment.current.calendar.date(from: dateComponents)

      let project = Project.template
        |> Project.lens.dates.deadline .~ date!.timeIntervalSince1970
        |> Project.lens.stats.userCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.projectCurrency .~ Currency.USD.rawValue

      let plotData = PledgePaymentPlansAndSelectionData(
        selectedPlan: .pledgeInFull,
        increments: mockPaymentIncrements(),
        ineligible: false,
        project: project
      )

      self.vm.inputs.configure(with: (project: project, total: 10, false, false))
      self.vm.inputs.configureWith(pledgeOverTimeData: plotData)
      self.vm.inputs.viewDidLoad()

      self.confirmationLabelHidden.assertValues([false])
      self.confirmationLabelAttributedText.assertValueCount(1)
      self.pledgeOverTimeStackViewHidden.assertValue(true)
      self.pledgeOverTimeChargesText.assertDidEmitValue()
      self.confirmationLabelText.assertValues([
        "If the project reaches its funding goal, you will be charged $10 on November 1, 2019. You will receive a proof of pledge that will be redeemable if the project is funded and the creator is successful at completing the creative venture."
      ])
    }
  }

  func testPledgeOverTime_PledgeOverTime() {
    withEnvironment(locale: Locale(identifier: "en")) {
      let project = Project.template
        |> Project.lens.stats.userCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.projectCurrency .~ Currency.USD.rawValue

      let plotData = PledgePaymentPlansAndSelectionData(
        selectedPlan: .pledgeOverTime,
        increments: mockPaymentIncrements(),
        ineligible: false,
        project: project
      )

      self.vm.inputs.configure(with: (project: project, total: 10, false, false))
      self.vm.inputs.configureWith(pledgeOverTimeData: plotData)
      self.vm.inputs.viewDidLoad()

      self.confirmationLabelHidden.assertValues([false])
      self.confirmationLabelAttributedText.assertValueCount(1)
      self.pledgeOverTimeStackViewHidden.assertValue(false)
      self.pledgeOverTimeChargesText.assertValue("charged as four payments")
      self.confirmationLabelText.assertValues([
        "If the project reaches its funding goal, the first charge of $250.00 will be collected on March 28, 2019."
      ])
    }
  }
}

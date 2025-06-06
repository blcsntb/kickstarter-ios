import KsApi
import Prelude
import ReactiveSwift
import UIKit

public struct ManagePledgeSummaryViewData: Equatable {
  public let backerId: Int
  public let backerName: String
  public let backerSequence: Int
  public let backingState: Backing.Status
  public let bonusAmount: Double?
  public let currentUserIsCreatorOfProject: Bool
  public let isNoReward: Bool
  public let locationName: String?
  public let needsConversion: Bool
  public let omitUSCurrencyCode: Bool
  public let pledgeAmount: Double
  public let pledgedOn: TimeInterval
  public let currencyCode: String
  public let projectDeadline: TimeInterval
  public let projectState: Project.State
  public let rewardMinimum: Double
  public let rewardReceivedViewControllerViewIsHidden: Bool
  public let rewardReceivedWithData: ManageViewPledgeRewardReceivedViewData
  public let shippingAmount: Double?
  public let shippingAmountHidden: Bool
  public let rewardIsLocalPickup: Bool
  public let paymentIncrements: [PledgePaymentIncrement]?
  // Temporary property
  public let project: Project?
}

public protocol ManagePledgeSummaryViewModelInputs {
  func configureWith(_ data: ManagePledgeSummaryViewData)
  func viewDidLoad()
}

public protocol ManagePledgeSummaryViewModelOutputs {
  var backerImageURLAndPlaceholderImageName: Signal<(URL, String), Never> { get }
  var backerNameLabelHidden: Signal<Bool, Never> { get }
  var backerNameText: Signal<String, Never> { get }
  var backerNumberText: Signal<String, Never> { get }
  var backingDateText: Signal<String, Never> { get }
  var circleAvatarViewHidden: Signal<Bool, Never> { get }
  var configurePledgeAmountSummaryViewWithData: Signal<PledgeAmountSummaryViewData, Never> { get }
  var configurePledgeStatusLabelViewWithProject: Signal<PledgeStatusLabelViewData, Never> { get }
  var configureRewardReceivedWithData: Signal<ManageViewPledgeRewardReceivedViewData, Never> { get }
  var rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never> { get }
  var totalAmountText: Signal<NSAttributedString, Never> { get }
}

public protocol ManagePledgeSummaryViewModelType {
  var inputs: ManagePledgeSummaryViewModelInputs { get }
  var outputs: ManagePledgeSummaryViewModelOutputs { get }
}

public class ManagePledgeSummaryViewModel: ManagePledgeSummaryViewModelType,
  ManagePledgeSummaryViewModelInputs, ManagePledgeSummaryViewModelOutputs {
  public init() {
    let data = Signal.combineLatest(
      self.dataSignal,
      self.viewDidLoadSignal
    )
    .map(first)

    self.configurePledgeStatusLabelViewWithProject = data.map(pledgeStatusLabelViewData)

    self.configurePledgeAmountSummaryViewWithData = data.map(pledgeAmountSummaryViewData)

    let userAndIsBackingProject = data.map(\.backerId)
      .compactMap { backerId -> (User, Bool)? in
        guard let user = AppEnvironment.current.currentUser else {
          return nil
        }

        return (user, backerId == user.id)
      }

    self.backerNameLabelHidden = userAndIsBackingProject.map(second).negate()
    self.circleAvatarViewHidden = userAndIsBackingProject.map(second).negate()

    self.configureRewardReceivedWithData = data.map(\.rewardReceivedWithData)
    self.rewardReceivedViewControllerViewIsHidden = data.map(\.rewardReceivedViewControllerViewIsHidden)

    let userBackingProject = userAndIsBackingProject
      .filter(second >>> isTrue)
      .map(first)

    self.backerNameText = userBackingProject
      .map(\.name)

    self.backerImageURLAndPlaceholderImageName = userBackingProject
      .map(\.avatar.small)
      .map(URL.init)
      .skipNil()
      .map { ($0, "avatar--placeholder") }

    self.backerNumberText = data.map(\.backerSequence)
      .map { Strings.backer_modal_backer_number(backer_number: Format.wholeNumber($0)) }

    self.backingDateText = data.map(\.pledgedOn)
      .map(formattedPledgeDate)

    self.totalAmountText = data.map { ($0.currencyCode, $0.pledgeAmount, $0.omitUSCurrencyCode) }
      .map { currencyCode, pledgeAmount, omitUSCurrencyCode in
        attributedCurrency(
          with: currencyCode,
          amount: pledgeAmount,
          omitUSCurrencyCode: omitUSCurrencyCode
        )
      }
      .skipNil()
  }

  private let (dataSignal, dataObserver) = Signal<ManagePledgeSummaryViewData, Never>.pipe()
  public func configureWith(_ data: ManagePledgeSummaryViewData) {
    self.dataObserver.send(value: data)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let backerImageURLAndPlaceholderImageName: Signal<(URL, String), Never>
  public let backerNameLabelHidden: Signal<Bool, Never>
  public let backerNameText: Signal<String, Never>
  public let backerNumberText: Signal<String, Never>
  public let backingDateText: Signal<String, Never>
  public let circleAvatarViewHidden: Signal<Bool, Never>
  public let configurePledgeStatusLabelViewWithProject: Signal<PledgeStatusLabelViewData, Never>
  public let configurePledgeAmountSummaryViewWithData: Signal<PledgeAmountSummaryViewData, Never>
  public let configureRewardReceivedWithData: Signal<ManageViewPledgeRewardReceivedViewData, Never>
  public let rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never>
  public let totalAmountText: Signal<NSAttributedString, Never>

  public var inputs: ManagePledgeSummaryViewModelInputs { return self }
  public var outputs: ManagePledgeSummaryViewModelOutputs { return self }
}

private func formattedPledgeDate(_ timeInterval: TimeInterval) -> String {
  let formattedDate = Format.date(secondsInUTC: timeInterval, dateStyle: .long, timeStyle: .none)
  return Strings.As_of_pledge_date(pledge_date: formattedDate)
}

private func pledgeAmountSummaryViewData(
  with data: ManagePledgeSummaryViewData
) -> PledgeAmountSummaryViewData {
  return .init(
    bonusAmount: data.bonusAmount,
    bonusAmountHidden: false,
    isNoReward: data.isNoReward,
    locationName: data.locationName,
    omitUSCurrencyCode: data.omitUSCurrencyCode,
    currencyCode: data.currencyCode,
    pledgedOn: data.pledgedOn,
    rewardMinimum: data.rewardMinimum,
    shippingAmount: data.shippingAmount,
    shippingAmountHidden: data.shippingAmountHidden,
    rewardIsLocalPickup: data.rewardIsLocalPickup
  )
}

private func pledgeStatusLabelViewData(with data: ManagePledgeSummaryViewData) -> PledgeStatusLabelViewData {
  return PledgeStatusLabelViewData(
    currentUserIsCreatorOfProject: data.currentUserIsCreatorOfProject,
    needsConversion: data.needsConversion,
    pledgeAmount: data.pledgeAmount,
    currencyCode: data.currencyCode,
    projectDeadline: data.projectDeadline,
    projectState: data.projectState,
    backingState: data.backingState,
    paymentIncrements: data.paymentIncrements,
    project: data.project
  )
}

private func attributedCurrency(
  with currencyCode: String,
  amount: Double,
  omitUSCurrencyCode: Bool
) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: LegacyColors.ksr_support_700.uiColor()])
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      amount,
      currencyCode: currencyCode,
      omitCurrencyCode: omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  return attributedCurrency
}

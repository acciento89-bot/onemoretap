import StoreKit
public final class RequestParameters {public init() {}}
public final class ConsentInformation {
 public static let shared=ConsentInformation()
 public enum Requirement {case required,notRequired}
 public var privacyOptionsRequirementStatus:Requirement {ProviderProbe.calls.append("privacy.status");return .notRequired}
 public var canRequestAds:Bool {ProviderProbe.calls.append("consent.status");return true}
 public func requestConsentInfoUpdate(with:RequestParameters) async throws {ProviderProbe.calls.append("consent.update")}
}
public enum ConsentForm {
 public static func presentPrivacyOptionsForm(from:Any?) async throws {ProviderProbe.calls.append("privacy.present")}
 public static func loadAndPresentIfRequired(from:Any?) async throws {ProviderProbe.calls.append("consent.present")}
}

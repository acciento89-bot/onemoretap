import UIKit

@MainActor
enum FeedbackManager {
  static func good(enabled: Bool) {
    guard enabled else { return }
    UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.72)
  }

  static func perfect(enabled: Bool) {
    guard enabled else { return }
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1.0)
  }

  static func miss(enabled: Bool) {
    guard enabled else { return }
    UINotificationFeedbackGenerator().notificationOccurred(.error)
  }
}

import SwiftUI
import UIKit

enum GameThemeID: String, CaseIterable, Identifiable, Codable {
  case neon
  case fire
  case galaxy
  case retro

  var id: String { rawValue }

  var title: String {
    switch self {
    case .neon: "NEON"
    case .fire: "FIRE"
    case .galaxy: "GALAXY"
    case .retro: "RETRO"
    }
  }

  var subtitle: String {
    switch self {
    case .neon: "Original cyan energy"
    case .fire: "Hot orange and red"
    case .galaxy: "Deep violet starlight"
    case .retro: "Arcade green and amber"
    }
  }

  var productID: String? {
    switch self {
    case .neon: nil
    case .fire: MonetizationProducts.themeFire
    case .galaxy: MonetizationProducts.themeGalaxy
    case .retro: MonetizationProducts.themeRetro
    }
  }

  var primary: Color {
    switch self {
    case .neon: .cyan
    case .fire: Color(red: 1.0, green: 0.35, blue: 0.12)
    case .galaxy: Color(red: 0.66, green: 0.38, blue: 1.0)
    case .retro: Color(red: 0.32, green: 1.0, blue: 0.55)
    }
  }

  var secondary: Color {
    switch self {
    case .neon: Color(red: 0.62, green: 0.38, blue: 1.0)
    case .fire: Color(red: 1.0, green: 0.12, blue: 0.18)
    case .galaxy: Color(red: 0.18, green: 0.68, blue: 1.0)
    case .retro: Color(red: 1.0, green: 0.68, blue: 0.16)
    }
  }

  var backgroundTop: Color {
    switch self {
    case .neon: Color(red: 0.018, green: 0.024, blue: 0.052)
    case .fire: Color(red: 0.065, green: 0.018, blue: 0.018)
    case .galaxy: Color(red: 0.025, green: 0.018, blue: 0.072)
    case .retro: Color(red: 0.018, green: 0.045, blue: 0.036)
    }
  }

  var backgroundBottom: Color {
    switch self {
    case .neon: Color(red: 0.055, green: 0.022, blue: 0.085)
    case .fire: Color(red: 0.095, green: 0.028, blue: 0.012)
    case .galaxy: Color(red: 0.055, green: 0.022, blue: 0.11)
    case .retro: Color(red: 0.065, green: 0.045, blue: 0.012)
    }
  }

  var uiPrimary: UIColor { UIColor(primary) }
  var uiSecondary: UIColor { UIColor(secondary) }
}

enum MonetizationProducts {
  static let removeAds = "com.kamilunavo.onemoretap.removeads"
  static let themeFire = "com.kamilunavo.onemoretap.theme.fire"
  static let themeGalaxy = "com.kamilunavo.onemoretap.theme.galaxy"
  static let themeRetro = "com.kamilunavo.onemoretap.theme.retro"
  static let allThemes = "com.kamilunavo.onemoretap.theme.all"

  static let all: Set<String> = [removeAds, themeFire, themeGalaxy, themeRetro, allThemes]
}

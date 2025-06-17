import SwiftUI
import Foundation // Import Foundation to use NSLocalizedString

enum AppRoute: Hashable, Identifiable {
    var id: Self { self }
    case home
    case search
    case list
    case user
    case settings
}

extension AppRoute {
    var titleKey: String {
        switch self {
        case .home: return "AppRoute.title.home"
        case .search: return "AppRoute.title.search"
        case .list: return "AppRoute.title.list"
        case .user: return "AppRoute.title.user"
        case .settings: return "AppRoute.title.settings"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .list: return "list.bullet"
        case .user: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

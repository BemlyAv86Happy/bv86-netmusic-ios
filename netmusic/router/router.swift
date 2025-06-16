// router/router.swift

import SwiftUI // Don't forget to import SwiftUI

enum AppRoute: Hashable, Identifiable {
    var id: Self { self }
    case home
    case search
    case list
    // case historyAndFavorite // No longer in tab bar, or used in HomeView
    case user
    // case settings // No longer in tab bar
}

extension AppRoute {
    var title: String {
        switch self {
        case .home: return "首页"
        case .search: return "搜索"
        case .list: return "歌单"
        // case .historyAndFavorite: return "收藏历史"
        case .user: return "用户"
        // case .settings: return "设置"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .list: return "list.bullet"
        // case .historyAndFavorite: return "star.fill"
        case .user: return "person.fill"
        // case .settings: return "gearshape.fill"
        }
    }
}

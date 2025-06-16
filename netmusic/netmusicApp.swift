// netmusicApp.swift
import SwiftUI

@main
struct NetmusicApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                // Home Tab
                NavigationView { // Use NavigationView for iOS 15
                    HomeView() // HomeView will contain the ListView and its own layout
                }
                .tabItem {
                    Label(AppRoute.home.title, systemImage: AppRoute.home.iconName)
                }
                .tag(AppRoute.home)

                // Search Tab
                NavigationView {
                    SearchView() // Directly embed SearchView for this tab
                }
                .tabItem {
                    Label(AppRoute.search.title, systemImage: AppRoute.search.iconName)
                }
                .tag(AppRoute.search)

                // List Tab (This is now a top-level tab, not just content inside Home)
                NavigationView {
                    ListView() // Directly embed ListView for this tab
                }
                .tabItem {
                    Label(AppRoute.list.title, systemImage: AppRoute.list.iconName)
                }
                .tag(AppRoute.list)

                // User Tab
                NavigationView {
                    UserView() // Directly embed UserView for this tab
                }
                .tabItem {
                    Label(AppRoute.user.title, systemImage: AppRoute.user.iconName)
                }
                .tag(AppRoute.user)

                // HistoryAndFavorite and Settings are no longer top-level tabs.
                // If you want to navigate to them, it would be via a NavigationLink
                // from within one of the tab's root views (e.g., from UserView).
            }
        }
    }
}

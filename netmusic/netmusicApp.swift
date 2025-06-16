// netmusicApp.swift
import SwiftUI

@main
struct NetmusicApp: App {
    // Only declare navigationPath for iOS 16+, as it's not used in iOS 15
    #if os(iOS) && swift(>=5.7) // Check for iOS and Swift 5.7+ (iOS 16 requires Swift 5.7)
    @State private var navigationPath = NavigationPath() // This is the single, mutable path for iOS 16+
    #endif

    var body: some Scene {
        WindowGroup {
            TabView {
                // Conditional compilation for iOS 16+ (NavigationStack) vs. iOS 15- (NavigationView)
                #if os(iOS) && swift(>=5.7) // For iOS 16 and later (using NavigationStack)
                NavigationStack(path: $navigationPath) {
                    HomeView(path: $navigationPath)
                        .navigationDestination(for: AppRoute.self) { route in
                            ViewForRoute(route: route, path: $navigationPath)
                        }
                }
                .tabItem {
                    Label(AppRoute.home.title, systemImage: AppRoute.home.iconName)
                }
                .tag(AppRoute.home)

                NavigationStack(path: $navigationPath) {
                    SearchView()
                        .navigationDestination(for: AppRoute.self) { route in
                            ViewForRoute(route: route, path: $navigationPath)
                        }
                }
                .tabItem {
                    Label(AppRoute.search.title, systemImage: AppRoute.search.iconName)
                }
                .tag(AppRoute.search)

                NavigationStack(path: $navigationPath) {
                    ListView()
                        .navigationDestination(for: AppRoute.self) { route in
                            ViewForRoute(route: route, path: $navigationPath)
                        }
                }
                .tabItem {
                    Label(AppRoute.list.title, systemImage: AppRoute.list.iconName)
                }
                .tag(AppRoute.list)

                NavigationStack(path: $navigationPath) {
                    UserView()
                        .navigationDestination(for: AppRoute.self) { route in
                            ViewForRoute(route: route, path: $navigationPath)
                        }
                }
                .tabItem {
                    Label(AppRoute.user.title, systemImage: AppRoute.user.iconName)
                }
                .tag(AppRoute.user)

                #else // For iOS 15 and earlier (using NavigationView)
                // Home Tab for iOS 15
                NavigationView { // Use NavigationView
                    // HomeView for iOS 15 doesn't take `path` binding in its init
                    // because NavigationStack/Path isn't available.
                    // Instead, HomeView's internal buttons will use basic NavigationLink.
                    HomeViewIos15() // Use a separate HomeView variant for iOS 15 if needed
                }
                .tabItem {
                    Label(AppRoute.home.title, systemImage: AppRoute.home.iconName)
                }
                .tag(AppRoute.home)

                // Search Tab for iOS 15
                NavigationView {
                    SearchView() // Assuming SearchView doesn't rely on NavigationPath
                }
                .tabItem {
                    Label(AppRoute.search.title, systemImage: AppRoute.search.iconName)
                }
                .tag(AppRoute.search)

                // List Tab for iOS 15
                NavigationView {
                    ListView() // Assuming ListView doesn't rely on NavigationPath
                }
                .tabItem {
                    Label(AppRoute.list.title, systemImage: AppRoute.list.iconName)
                }
                .tag(AppRoute.list)

                // User Tab for iOS 15
                NavigationView {
                    UserView() // Assuming UserView doesn't rely on NavigationPath
                }
                .tabItem {
                    Label(AppRoute.user.title, systemImage: AppRoute.user.iconName)
                }
                .tag(AppRoute.user)

                #endif
            }
        }
    }
}

// ViewForRoute is primarily for iOS 16+ NavigationStack.
// For iOS 15 NavigationView, you'll typically use NavigationLink(destination: ...) directly.
// If you need ViewForRoute to render different content for iOS 15, you'd add conditional logic inside it too.
struct ViewForRoute: View {
    let route: AppRoute
    // Path is only relevant for iOS 16+
    #if os(iOS) && swift(>=5.7)
    @Binding var path: NavigationPath
    #endif

    var body: some View {
        switch route {
        case .home:
            // This case is unlikely to be hit via navigationDestination from Home tab's root
            #if os(iOS) && swift(>=5.7)
            HomeView(path: $path)
            #else
            HomeViewIos15() // Fallback for iOS 15
            #endif
        case .search:
            SearchView()
        case .list:
            ListView()
        case .historyAndFavorite:
            HistoryAndFavoriteView()
        case .user:
            UserView()
        case .settings:
            SettingsView()
        }
    }
}

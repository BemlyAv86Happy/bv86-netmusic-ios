// netmusicApp.swift
import SwiftUI

@main
struct NetmusicApp: App {
    @State private var navigationPath = NavigationPath() // This is the single, mutable path

    var body: some Scene {
        WindowGroup {
            TabView {
                // Home Tab: Pass the actual mutable path
                NavigationStack(path: $navigationPath) { //
                    HomeView(path: $navigationPath) // Pass the @State binding here
                        .navigationDestination(for: AppRoute.self) { route in //
                            ViewForRoute(route: route, path: $navigationPath) // Pass path to ViewForRoute as well
                        }
                }
                .tabItem { //
                    Label(AppRoute.home.title, systemImage: AppRoute.home.iconName) //
                }
                .tag(AppRoute.home) //

                // Other Tabs (also pass the path if they will push views on the *same* stack)
                // If each tab needs its own independent navigation history, each NavigationStack
                // would have its own @State NavigationPath. For now, we'll assume a shared path.
                NavigationStack(path: $navigationPath) { //
                    SearchView()
                        .navigationDestination(for: AppRoute.self) { route in //
                            ViewForRoute(route: route, path: $navigationPath) //
                        }
                }
                .tabItem { //
                    Label(AppRoute.search.title, systemImage: AppRoute.search.iconName) //
                }
                .tag(AppRoute.search) //

                NavigationStack(path: $navigationPath) { //
                    ListView()
                        .navigationDestination(for: AppRoute.self) { route in //
                            ViewForRoute(route: route, path: $navigationPath) //
                        }
                }
                .tabItem { //
                    Label(AppRoute.list.title, systemImage: AppRoute.list.iconName) //
                }
                .tag(AppRoute.list) //

                // History/Favorite Tab
                NavigationStack(path: $navigationPath) { //
                    HistoryAndFavoriteView()
                        .navigationDestination(for: AppRoute.self) { route in //
                            ViewForRoute(route: route, path: $navigationPath) //
                        }
                }
                .tabItem { //
                    Label(AppRoute.historyAndFavorite.title, systemImage: AppRoute.historyAndFavorite.iconName) //
                }
                .tag(AppRoute.historyAndFavorite) //

                // User Tab
                NavigationStack(path: $navigationPath) { //
                    UserView()
                        .navigationDestination(for: AppRoute.self) { route in //
                            ViewForRoute(route: route, path: $navigationPath) //
                        }
                }
                .tabItem { //
                    Label(AppRoute.user.title, systemImage: AppRoute.user.iconName) //
                }
                .tag(AppRoute.user) //
            }
        }
    }
}

// ViewForRoute also needs access to the path if it creates views that themselves navigate
struct ViewForRoute: View {
    let route: AppRoute
    @Binding var path: NavigationPath // Now receives the mutable path

    var body: some View {
        switch route {
        case .home:
            // If HomeView is the *root* of a NavigationStack, you pass the path here.
            // However, HomeView is already the root of its tab's NavigationStack,
            // so this case would typically not be reached via `navigationDestination`.
            // If it were, it would likely mean popping to root or similar.
            HomeView(path: $path) // Pass the actual path
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
        // case .songDetail(let id):
        //     SongDetailView(songId: id)
        }
    }
}

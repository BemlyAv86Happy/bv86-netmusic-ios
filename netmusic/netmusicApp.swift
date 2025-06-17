// netmusicApp.swift
import SwiftUI

// ThemeManager 保持不变，如果它在你的项目中是单独的文件，则无需在此处重复定义
class ThemeManager: ObservableObject {
    @Published var currentColorScheme: ColorScheme? = .light {
        didSet {
            // 在这里可以添加逻辑来持久化用户选择的主题，例如保存到 UserDefaults
            // UserDefaults.standard.set(currentColorScheme?.rawValue, forKey: "appTheme")
        }
    }

    init() {
        // 在初始化时，可以从 UserDefaults 加载之前保存的主题偏好
        // if let savedThemeRawValue = UserDefaults.standard.string(forKey: "appTheme"),
        //    let savedTheme = ColorScheme(rawValue: savedThemeRawValue) {
        //     self.currentColorScheme = savedTheme
        // }
    }
}


@main
struct NetmusicApp: App {
    // 使用 @StateObject 来创建 ThemeManager 的实例。
    @StateObject var themeManager = ThemeManager()
    // 使用 @StateObject 来创建 LocalizationManager 的实例。
    @StateObject var localizationManager = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                // Home Tab
                NavigationView { // Use NavigationView for iOS 15
                    HomeView()
                }
                .tabItem {
                    // 修正：使用 AppRoute.home.titleKey 和 localizationManager.bundle
                    Label {
                        Text(LocalizedStringKey(AppRoute.home.titleKey), bundle: localizationManager.bundle)
                    } icon: {
                        Image(systemName: AppRoute.home.iconName)
                    }
                }
                .tag(AppRoute.home)

                // Search Tab
                NavigationView {
                    SearchView()
                }
                .tabItem {
                    // 修正：使用 AppRoute.search.titleKey 和 localizationManager.bundle
                    Label {
                        Text(LocalizedStringKey(AppRoute.search.titleKey), bundle: localizationManager.bundle)
                    } icon: {
                        Image(systemName: AppRoute.search.iconName)
                    }
                }
                .tag(AppRoute.search)

                // User Tab
                NavigationView {
                    UserView()
                }
                .tabItem {
                    // 修正：使用 AppRoute.user.titleKey 和 localizationManager.bundle
                    Label {
                        Text(LocalizedStringKey(AppRoute.user.titleKey), bundle: localizationManager.bundle)
                    } icon: {
                        Image(systemName: AppRoute.user.iconName)
                    }
                }
                .tag(AppRoute.user)

                // Set Tab
                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    // 修正：使用 AppRoute.settings.titleKey 和 localizationManager.bundle
                    Label {
                        Text(LocalizedStringKey(AppRoute.settings.titleKey), bundle: localizationManager.bundle)
                    } icon: {
                        Image(systemName: AppRoute.settings.iconName)
                    }
                }
                .tag(AppRoute.settings)
            }
            // 将 themeManager 作为环境对象注入到 TabView 及其所有子视图中。
            .environmentObject(themeManager)
            // 将 localizationManager 作为环境对象注入到 TabView 及其所有子视图中。
            .environmentObject(localizationManager)
            // 在最外层的视图（这里是 TabView）上应用 preferredColorScheme。
            .preferredColorScheme(themeManager.currentColorScheme)
            // 同时在最外层视图应用 locale 环境，这样所有 Text 视图在初始化时都会使用这个 locale
            // 但对于 LocalizedStringKey，我们需要直接传入 bundle
            .environment(\.locale, Locale(identifier: localizationManager.selectedLanguageCode))
            // 注意：直接设置 .environment(\.locale) 主要影响日期、数字格式，对 Text(LocalizedStringKey) 的影响有限
            // 更可靠的做法是直接在 Text 初始化时传入 bundle
        }
    }
}

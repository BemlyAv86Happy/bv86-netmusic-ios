// Models/SettingsStore.swift
import Foundation
import SwiftUI

// 用于管理所有设置的 ObservableObject
class SettingsStore: ObservableObject {
    // 基础设置
    @AppStorage("isDarkTheme") @Published var isDarkTheme: Bool = false {
        didSet {
            applyTheme(isDarkTheme)
        }
    }
    @AppStorage("selectedLanguage") @Published var selectedLanguage: String = "zh" // Default to Chinese
    @AppStorage("noAnimate") @Published var noAnimate: Bool = false
    @AppStorage("animationSpeed") @Published var animationSpeed: Double = 1.0

    // 播放设置
    @AppStorage("musicQuality") @Published var musicQuality: String = "standard"
    @AppStorage("playbackRate") @Published var playbackRate: Double = 1.0
    @AppStorage("autoPlay") @Published var autoPlay: Bool = false
    @AppStorage("cacheLimitMB") @Published var cacheLimitMB: Int = 500 // Default 500MB
    @AppStorage("loopOneSong") @Published var loopOneSong: Bool = false
    @AppStorage("showLyrics") @Published var showLyrics: Bool = true
    @AppStorage("lyricsDisplayMode") @Published var lyricsDisplayMode: String = "overlay" // "overlay" or "desktop"
    @AppStorage("lyricsFontSize") @Published var lyricsFontSize: Double = 16.0
    @AppStorage("lyricsOpacity") @Published var lyricsOpacity: Double = 1.0
    @AppStorage("lyricsBackgroundColor") @Published var lyricsBackgroundColor: String = "#00000080" // Hex string with alpha

    // 应用设置 (Electron Only 的在 SwiftUI 中通常需要适配或移除)
    @AppStorage("autoCheckUpdates") @Published var autoCheckUpdates: Bool = true
    @AppStorage("homepageRecommend") @Published var homepageRecommend: Bool = true
    @AppStorage("enableNotifications") @Published var enableNotifications: Bool = true

    // 网络设置 (Electron Only 的在 SwiftUI 中通常需要适配或移除)
    @AppStorage("proxyMode") @Published var proxyMode: String = "none" // "none", "system", "custom"
    @AppStorage("customProxyServer") @Published var customProxyServer: String = ""
    @AppStorage("checkUpdateProxy") @Published var checkUpdateProxy: Bool = false
    @AppStorage("cookieRefreshInterval") @Published var cookieRefreshInterval: Int = 12 // hours

    // 关于 (简化)
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"

    init() {
        // 从 UserDefaults 加载初始值，@AppStorage 自动处理了
        applyTheme(isDarkTheme) // 确保应用启动时主题正确
    }

    private func applyTheme(_ isDark: Bool) {
        // 这将在运行时设置整个应用的外观
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
        }
    }

    // 清除缓存 (示例方法，需要实际实现)
    func clearCache() {
        print("Clearing application cache...")
        // 实际的缓存清除逻辑
    }

    // 清除歌曲文件 (示例方法，需要实际实现)
    func clearSongFiles() {
        print("Clearing song files...")
        // 实际的歌曲文件清除逻辑
    }

    // 开发者工具 (示例方法，在 iOS 上可能对应不同的调试工具)
    func openDeveloperTools() {
        print("Opening developer tools...")
        // 例如：在模拟器上可以打开 Xcode 的 Debug View Hierarchy
    }
}

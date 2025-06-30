import SwiftUI

// SettingsView 是应用程序的主要设置界面。
// 它将包含所有不同的设置分类，每个分类由一个 SettingsSection 视图表示。
struct SettingsView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager

    // 状态变量
    @State private var triggerThemeAnimation: Bool = false
    @State private var selectedTheme: ColorScheme = .light
    @State private var circleScale: CGFloat = 0.01
    @State private var animationSpeed: AnimationSpeed = .normal

    // 计算屏幕尺寸
    private var screenSize: CGSize {
        UIScreen.main.bounds.size
    }

    // 计算覆盖屏幕所需的缩放值
    private var maxCircleScale: CGFloat {
        max(screenSize.width, screenSize.height) * 2.0
    }

    var localizedNavigationTitle: Text {
        Text(LocalizedStringKey(AppRoute.settings.titleKey), bundle: localizationManager.bundle)
    }

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    // MARK: - 基础设置 (Basic Settings)
                    SettingsSection(titleKey: "settings.sections.basic") {
                        BasicSettingsView(
                                triggerThemeAnimation: $triggerThemeAnimation,
                                selectedTheme: $selectedTheme,
                                animationSpeed: $animationSpeed
                        )
                    }

                    // MARK: - 播放设置 (Playback Settings)
                    SettingsSection(titleKey: "settings.sections.playback") {
                        PlaybackSettingsView(
                        )
                    }

                    // MARK: - 应用设置 (Application Settings) - Electron Only
                    SettingsSection(titleKey: "settings.sections.application") {
                        SettingItemView(
                                titleKey: "settings.application.update",
                                descriptionKey: "settings.application.updateDesc",
                                isScrambling: false
                        ) {
                            Text("更新设置占位")
                        }
                        SettingItemView(
                                titleKey: "settings.application.homepageRecommend",
                                descriptionKey: "settings.application.homepageRecommendDesc",
                                isScrambling: false
                        ) {
                            Toggle(isOn: .constant(true)) {
                                Text("主页推荐占位")
                            }
                        }
                        SettingItemView(
                                titleKey: "settings.application.notifications",
                                descriptionKey: "settings.application.notificationsDesc",
                                isScrambling: false
                        ) {
                            Toggle(isOn: .constant(true)) {
                                Text("通知占位")
                            }
                        }
                    }

                    // MARK: - 网络设置 (Network Settings) - Electron Only
                    SettingsSection(titleKey: "settings.sections.network") {
                        SettingItemView(
                                titleKey: "settings.network.proxy",
                                descriptionKey: "settings.network.proxyDesc",
                                isScrambling: false
                        ) {
                            Text("代理设置占位")
                        }
                        SettingItemView(
                                titleKey: "settings.network.customProxyServer",
                                descriptionKey: "settings.network.customProxyServerDesc",
                                isScrambling: false
                        ) {
                            Text("自定义代理服务器占位")
                        }
                        SettingItemView(
                                titleKey: "settings.network.checkUpdateProxy",
                                descriptionKey: "settings.network.checkUpdateProxyDesc",
                                isScrambling: false
                        ) {
                            Toggle(isOn: .constant(false)) {
                                Text("检查更新代理占位")
                            }
                        }
                        SettingItemView(
                                titleKey: "settings.network.cookieRefreshInterval",
                                descriptionKey: "settings.network.cookieRefreshIntervalDesc",
                                isScrambling: false
                        ) {
                            Text("Cookie 刷新间隔占位")
                        }
                    }

                    // MARK: - 系统管理 (System Management) - Electron Only
                    SettingsSection(titleKey: "settings.sections.systemManagement") {
                        SettingItemView(
                                titleKey: "settings.systemManagement.clearCache",
                                descriptionKey: "settings.systemManagement.clearCacheDesc",
                                isScrambling: false
                        ) {
                            Button("清除缓存") {
                                /* Action to clear cache */
                            }
                        }
                        SettingItemView(
                                titleKey: "settings.systemManagement.clearSongFiles",
                                descriptionKey: "settings.systemManagement.clearSongFilesDesc",
                                isScrambling: false
                        ) {
                            Button("清除歌曲文件") {
                                /* Action to clear song files */
                            }
                        }
                        SettingItemView(
                                titleKey: "settings.systemManagement.developerTools",
                                descriptionKey: "settings.systemManagement.developerToolsDesc",
                                isScrambling: false
                        ) {
                            Button("开发者工具") {
                                /* Action to open developer tools */
                            }
                        }
                    }

                    // MARK: - 关于 (About)
                    SettingsSection(titleKey: "settings.sections.about") {
                        SettingItemView(
                                titleKey: "settings.about.versionInformation",
                                descriptionKey: "settings.about.versionInformationDesc",
                                isScrambling: false
                        ) {
                            Text("版本信息: 0.0.1")
                        }
                        SettingItemView(
                                titleKey: "settings.about.authorInformation",
                                descriptionKey: "settings.about.authorInformationDesc",
                                isScrambling: false
                        ) {
                            Text("作者: Your Name")
                        }
                    }
                }
                        .navigationTitle(localizedNavigationTitle)
                        .overlay(
                                Group {
                                    if triggerThemeAnimation {
                                        Circle()
                                                .fill(selectedTheme == .light ? Color.white : Color.black)
                                                .frame(width: screenSize.width * circleScale,
                                                        height: screenSize.width * circleScale)
                                                .position(x: screenSize.width / 2,
                                                        y: screenSize.height / 2)
                                                .ignoresSafeArea()
                                                .onAppear {
                                                    // 开始动画
                                                    withAnimation(.easeOut(duration: animationSpeed.duration)) {
                                                        circleScale = maxCircleScale / screenSize.width
                                                    }
                                                    // 动画结束后重置状态并应用主题
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.duration) {
                                                        // 应用主题切换
                                                        themeManager.currentColorScheme = selectedTheme
                                                        // 动画结束后重置状态
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.duration) {
                                                            triggerThemeAnimation = false
                                                            circleScale = 0.01
                                                        }
                                                    }
                                                }
                                    }
                                }
                        )
                }
        }
    }
}


// 预览 SettingsView
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LocalizationManager())
            .environmentObject(ThemeManager())
    }
}

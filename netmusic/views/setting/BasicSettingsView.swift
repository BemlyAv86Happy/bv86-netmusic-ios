import SwiftUI

struct BasicSettingsView: View {
    // 使用 @EnvironmentObject 来访问全局主题管理器
    @EnvironmentObject var themeManager: ThemeManager
    // 使用 @EnvironmentObject 来访问全局语言管理器
    @EnvironmentObject var localizationManager: LocalizationManager

    // 控制动画速度选择器是否显示的 State 变量
    @State private var showAnimationSpeedPicker: Bool = false
    // 动画效果的状态变量，默认为 "normal"
    @State private var animationSpeed: String = "normal" // "slow", "normal", "fast"

    var body: some View {
        Group {
            // MARK: - 主题模式 (Theme Mode)
            SettingItemView(titleKey: "settings.basic.themeMode", descriptionKey: "settings.basic.themeModeDesc") {
                // 使用 Picker 直接绑定到 themeManager.currentColorScheme
                Picker("", selection: Binding<ColorScheme>(
                    get: { themeManager.currentColorScheme ?? .light }, // 如果为 nil，默认为 .light
                    set: { newScheme in
                        themeManager.currentColorScheme = newScheme // 更新 ThemeManager 中的主题
                    }
                )) {
                    Label("亮色", systemImage: "sun.max.fill") // 亮色图标
                        .tag(ColorScheme.light)
                    Label("暗色", systemImage: "moon.fill") // 暗色图标
                        .tag(ColorScheme.dark)
                }
                .pickerStyle(.segmented) // 分段选择器样式
                .fixedSize() // 防止 picker 宽度过大
                .padding(.trailing, -8) // 微调间距
            }

            // MARK: - 语言 (Language)
            SettingItemView(titleKey: "settings.basic.language", descriptionKey: "settings.basic.languageDesc") {
                // 使用 Picker 直接绑定到 localizationManager.selectedLanguageCode
                Picker("", selection: $localizationManager.selectedLanguageCode) {
                    Text("中文 (简体)").tag("zh-Hans") // 标签使用硬编码，因为这是 Picker 本身的选择项
                    Text("English").tag("en")
                    // 可以添加更多语言选项
                }
                .fixedSize() // 防止 picker 宽度过大
            }

            // MARK: - 动画效果 (Animation Effect)
            VStack(alignment: .leading) { // 使用 VStack 来容纳 Toggle 和可能展开的 Picker
                SettingItemView(titleKey: "settings.basic.animation", descriptionKey: "settings.basic.animationDesc") {
                    Toggle(isOn: $showAnimationSpeedPicker) {
//                        Text(showAnimationSpeedPicker ? "启用动画" : "禁用动画") // 根据状态显示不同文本
                    }
                }

                // 根据 showAnimationSpeedPicker 的状态条件性地显示 Picker
                if showAnimationSpeedPicker {
                    Picker("", selection: $animationSpeed) {
                        Text(LocalizedStringKey("settings.basic.animationSpeed.slow"), bundle: localizationManager.bundle).tag("slow")
                        Text(LocalizedStringKey("settings.basic.animationSpeed.normal"), bundle: localizationManager.bundle).tag("normal")
                        Text(LocalizedStringKey("settings.basic.animationSpeed.fast"), bundle: localizationManager.bundle).tag("fast")
                    }
                    .pickerStyle(.segmented)
                    .padding(.leading, 15) // 与 SettingItemView 对齐，或者根据需要调整
                    .padding(.trailing, 10)
                    .transition(.opacity.combined(with: .slide)) // 添加过渡动画
                }
            }
            .animation(.easeInOut, value: showAnimationSpeedPicker) // 整个 VStack 的动画，当 showAnimationSpeedPicker 改变时触发
        }
    }
}

// 预览 BasicSettingsView
struct BasicSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            BasicSettingsView()
                .environmentObject(ThemeManager()) // 预览时也要注入 ThemeManager
                .environmentObject(LocalizationManager()) // 预览时也要注入 LocalizationManager
        }
    }
}


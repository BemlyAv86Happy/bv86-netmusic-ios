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
    // 用于触发动画的状态变量    
    @State private var triggerAnimation: Bool = false // 用于触发动画
    // 主题选择的状态变量，默认为亮色主题
    @State private var selectedTheme: ColorScheme = .light // 默认主题为亮色
    
    // 匹配属性，根据动画速度返回对应的动画持续时间
    private var animationDuration: Double {
        switch animationSpeed {
        case "slow": return 1.0 // 慢速动画
        case "normal": return 0.6 // 一般动画
        case "fast": return 0.1 // 快速动画
        default: return 0.6 // 默认动画速度
        }
    }
    
    var body: some View {
        Group {
            // MARK: - 主题模式 (Theme Mode)
            SettingItemView(titleKey: "settings.basic.themeMode", descriptionKey: "settings.basic.themeModeDesc") {
                ZStack{
                    // 圆圈动画
                    if showAnimationSpeedPicker {
                        Circle()
                            .fill(selectedTheme == .light ? Color.white : Color.black)
                            .opacity(triggerAnimation ? 0 : 1) // 根据 triggerAnimation 控制透明度
                            .scaleEffect(triggerAnimation ? 10 : 0.01) // 根据 triggerAnimation 控制缩放
                            .animation(.easeInOut(duration: animationDuration), value: triggerAnimation) // 使用动画持续时间
                    }
                }

                // 使用 Picker 直接绑定到 themeManager.currentColorScheme
                Picker("", selection: Binding<ColorScheme>(
                        get: { themeManager.currentColorScheme ?? .light },
                        set: { newScheme in
                            if newScheme != themeManager.currentColorScheme {
                                // 更新 selectedTheme 和触发动画
                                selectedTheme = newScheme
                                // 如果 showAnimationSpeedPicker 为 true，则触发动画
                                if showAnimationSpeedPicker {
                                    withAnimation {
                                        triggerAnimation = true
                                    }
                                    // 完成后重置动画
                                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                                        triggerAnimation = false
                                        themeManager.currentColorScheme = newScheme
                                    }
                                } else {
                                    themeManager.currentColorScheme = newScheme
                                }
                            }
                        }
                    )) {
                        Label("亮色", systemImage: "sun.max.fill").tag(ColorScheme.light)
                        Label("暗色", systemImage: "moon.fill").tag(ColorScheme.dark)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                    .padding(.trailing, -8)
                }
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


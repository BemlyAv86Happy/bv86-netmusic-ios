import SwiftUI

// 定义 AnimationSpeed 枚举
enum AnimationSpeed: String, CaseIterable {
    case slow = "slow"
    case normal = "normal"
    case fast = "fast"

    // 计算动画持续时间
    var duration: Double {
        switch self {
        case .slow: return 1.0
        case .normal: return 0.6
        case .fast: return 0.3
        }
    }

    // 获取本地化键，用于 Picker 显示
    var localizedKey: String {
        "settings.basic.animationSpeed.\(rawValue)"
    }
}

struct BasicSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var showAnimationSpeedPicker: Bool = false
    @Binding var triggerThemeAnimation: Bool // 调整顺序：先放这个
    @Binding var selectedTheme: ColorScheme  // 然后这个
    @Binding var animationSpeed: AnimationSpeed // 最后这个

    @State private var triggerLanguageAnimation: Bool = false
    @State private var targetLanguageCode: String = "zh-Hans"

    var body: some View {
        Group {
            // MARK: - 主题模式 (Theme Mode)
            SettingItemView(
                    titleKey: "settings.basic.themeMode",
                    descriptionKey: "settings.basic.themeModeDesc",
                    isScrambling: triggerLanguageAnimation && showAnimationSpeedPicker
            ) {
                Picker("", selection: Binding<ColorScheme>(
                    get: { themeManager.currentColorScheme ?? .light },
                    set: { newScheme in
                        if newScheme != themeManager.currentColorScheme {
                            selectedTheme = newScheme
                            if showAnimationSpeedPicker {
                                // withAnimation {
                                    triggerThemeAnimation = true
                                // }
                                // DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.duration) {
                                //    triggerThemeAnimation = false
                                //    themeManager.currentColorScheme = newScheme
                                // }
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

            // MARK: - 语言 (Language)
            SettingItemView(titleKey: "settings.basic.language", descriptionKey: "settings.basic.languageDesc", isScrambling: triggerLanguageAnimation && showAnimationSpeedPicker) {
                Picker("", selection: Binding<String>(
                    get: { localizationManager.selectedLanguageCode },
                    set: { newLanguageCode in
                        if newLanguageCode != localizationManager.selectedLanguageCode {
                            targetLanguageCode = newLanguageCode
                            if showAnimationSpeedPicker {
                                withAnimation {
                                    triggerLanguageAnimation = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.duration) {
                                    triggerLanguageAnimation = false
                                    localizationManager.selectedLanguageCode = newLanguageCode
                                }
                            } else {
                                localizationManager.selectedLanguageCode = newLanguageCode
                            }
                        }
                    }
                )) {
                    Text("中文 (简体)").tag("zh-Hans")
                    Text("English").tag("en")
                }
                .fixedSize()
                .opacity(triggerLanguageAnimation && showAnimationSpeedPicker ? 0 : 1)
            }

            // MARK: - 动画效果 (Animation Effect)
            VStack(alignment: .leading) {
                SettingItemView(titleKey: "settings.basic.animation", descriptionKey: "settings.basic.animationDesc", isScrambling: triggerLanguageAnimation && showAnimationSpeedPicker) {
                    Toggle(isOn: $showAnimationSpeedPicker) {}
                }

                if showAnimationSpeedPicker {
                    Picker("", selection: $animationSpeed) {
                        ForEach(AnimationSpeed.allCases, id: \.self) { speed in
                            Text(LocalizedStringKey(speed.localizedKey), bundle: localizationManager.bundle)
                                .tag(speed)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.leading, 15)
                    .padding(.trailing, 10)
                    .transition(.opacity.combined(with: .slide))
                }
            }
            .animation(.easeInOut, value: showAnimationSpeedPicker)
        }
    }
}

// 预览
struct BasicSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            BasicSettingsView(
                triggerThemeAnimation: .constant(false),
                selectedTheme: .constant(.light),
                animationSpeed: .constant(.normal)
            )
            .environmentObject(ThemeManager())
            .environmentObject(LocalizationManager())
        }
    }
}
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
    @State private var animationSpeed: AnimationSpeed = .normal
    @State private var triggerAnimation: Bool = false
    @State private var selectedTheme: ColorScheme = .light

    var body: some View {
        Group {
            // MARK: - 主题模式 (Theme Mode)
            SettingItemView(titleKey: "settings.basic.themeMode", descriptionKey: "settings.basic.themeModeDesc") {
                ZStack {
                    // Animation Circle
                    if showAnimationSpeedPicker {
                        Circle()
                            .fill(selectedTheme == .light ? Color.white : Color.black)
                            .opacity(triggerAnimation ? 0 : 1)
                            .scaleEffect(triggerAnimation ? 10 : 0.01)
                            .animation(.easeOut(duration: animationSpeed.duration), value: triggerAnimation)
                    }

                    // Theme Mode Picker
                    Picker("", selection: Binding<ColorScheme>(
                        get: { themeManager.currentColorScheme ?? .light },
                        set: { newScheme in
                            if newScheme != themeManager.currentColorScheme {
                                selectedTheme = newScheme
                                if showAnimationSpeedPicker {
                                    withAnimation {
                                        triggerAnimation = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.duration) {
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
                Picker("", selection: $localizationManager.selectedLanguageCode) {
                    Text("中文 (简体)").tag("zh-Hans")
                    Text("English").tag("en")
                }
                .fixedSize()
            }

            // MARK: - 动画效果 (Animation Effect)
            VStack(alignment: .leading) {
                SettingItemView(titleKey: "settings.basic.animation", descriptionKey: "settings.basic.animationDesc") {
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

// 预览保持不变
struct BasicSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            BasicSettingsView()
                .environmentObject(ThemeManager())
                .environmentObject(LocalizationManager())
        }
    }
}
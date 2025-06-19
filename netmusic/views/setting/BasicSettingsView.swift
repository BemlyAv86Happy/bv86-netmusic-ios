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
    @State private var triggerThemeAnimation: Bool = false
    @State private var selectedTheme: ColorScheme = .light
    // New states for language animation
    @State private var triggerLanguageAnimation: Bool = false
    @State private var targetLanguageCode: String = "zh-Hans"
    @State private var scrambledText: String = ""

    // Function to generate scrambled text
    private func generateScrambledText() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<10).map { _ in characters.randomElement()! })
    }

    // Update scrambled text during animation
    private func startScrambleAnimation() {
        guard showAnimationSpeedPicker else { return }
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            scrambledText = generateScrambledText()
            if !triggerLanguageAnimation {
                timer.invalidate()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    var body: some View {
        Group {
            // MARK: - 主题模式 (Theme Mode)
            SettingItemView(titleKey: "settings.basic.themeMode", descriptionKey: "settings.basic.themeModeDesc") {
                ZStack {
                    // Animation Circle
                    if showAnimationSpeedPicker {
                        Circle()
                            .fill(selectedTheme == .light ? Color.white : Color.black)
                            .opacity(triggerThemeAnimation ? 0 : 1)
                            .scaleEffect(triggerThemeAnimation ? 10 : 0.01)
                            .animation(.easeOut(duration: animationSpeed.duration), value: triggerThemeAnimation)
                    }

                    // Theme Mode Picker
                    Picker("", selection: Binding<ColorScheme>(
                        get: { themeManager.currentColorScheme ?? .light },
                        set: { newScheme in
                            if newScheme != themeManager.currentColorScheme {
                                selectedTheme = newScheme
                                if showAnimationSpeedPicker {
                                    withAnimation {
                                        triggerThemeAnimation = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.duration) {
                                        triggerThemeAnimation = false
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
                ZStack {
                    // Language Picker
                    Picker("", selection: Binding<String>(
                        get: { localizationManager.selectedLanguageCode },
                        set: { newLanguageCode in
                            if newLanguageCode != localizationManager.selectedLanguageCode {
                                targetLanguageCode = newLanguageCode
                                if showAnimationSpeedPicker {
                                    withAnimation {
                                        triggerLanguageAnimation = true
                                        scrambledText = generateScrambledText()
                                        startScrambleAnimation()
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
                    .opacity(triggerLanguageAnimation ? 0 : 1) // Hide picker during animation

                    // Scramble Animation Overlay
                    if triggerLanguageAnimation && showAnimationSpeedPicker {
                        Text(scrambledText)
                            .font(.body)
                            .foregroundColor(.gray)
                            .fixedSize()
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.1), value: scrambledText)
                    }
                }
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
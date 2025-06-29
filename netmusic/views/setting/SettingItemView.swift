import SwiftUI

// SettingItemView 是一个通用的视图，用于显示单个设置项。
// 它包含一个标题、一个描述（可选），以及一个用于放置具体控制的视图。
struct SettingItemView<Content: View>: View {

    @EnvironmentObject var localizationManager: LocalizationManager // 注入语言管理器
    let titleKey: String // I18n 标题的键
    let descriptionKey: String? // I18n 描述的键 (可选)
    let isScrambling: Bool // 新增：控制是否显示打乱文本
    @ViewBuilder let content: Content // 用于放置实际控制（如Toggle, Picker等）的闭包

    // 生成打乱文本
    private func generateScrambledText(length: Int) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // 标题：根据 isScrambling 显示打乱文本或正常文本
                ZStack {
                    Text(LocalizedStringKey(titleKey), bundle: localizationManager.bundle)
                        .font(.headline)
                        .opacity(isScrambling ? 0 : 1)
                    if isScrambling {
                        Text(generateScrambledText(length: 10))
                            .font(.headline)
                            .foregroundColor(.gray)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.1), value: isScrambling)
                    }
                }

                // 描述：根据 isScrambling 显示打乱文本或正常文本
                if let descriptionKey = descriptionKey {
                    ZStack {
                        Text(LocalizedStringKey(descriptionKey), bundle: localizationManager.bundle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .opacity(isScrambling ? 0 : 1)
                        if isScrambling {
                            Text(generateScrambledText(length: 20))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.1), value: isScrambling)
                        }
                    }
                }
            }
            Spacer() // 将内容推到右侧
            content // 显示具体的设置控制
        }
        .padding(.vertical, 8) // 垂直方向的内边距
        .onChange(of: isScrambling) { newValue in
            if newValue {
                weak var weakTimer: Timer?
                let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak weakTimer] _ in
                    if !isScrambling {
                        weakTimer?.invalidate()
                    }
                }
                weakTimer = timer
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
}

// 预览 SettingItemView
struct SettingItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            // 示例：带描述的设置项
            SettingItemView(
                    titleKey: "settings.basic.themeMode",
                    descriptionKey: "settings.basic.themeModeDesc",
                    isScrambling: false
            ) {
                Text("主题模式选择器占位")
            }
            // 示例：不带描述的设置项
            SettingItemView(
                    titleKey: "settings.basic.language",
                    descriptionKey: nil,
                    isScrambling: false
            ) {
                Text("语言选择器占位")
            }
            // 示例：显示打乱效果
            SettingItemView(
                    titleKey: "settings.basic.themeMode",
                    descriptionKey: "settings.basic.themeModeDesc",
                    isScrambling: true
            ) {
                Text("主题模式选择器占位")
            }
        }
        .environmentObject(LocalizationManager())
    }
}
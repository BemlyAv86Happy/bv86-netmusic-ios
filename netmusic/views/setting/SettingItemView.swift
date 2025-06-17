import SwiftUI

// SettingItemView 是一个通用的视图，用于显示单个设置项。
// 它包含一个标题、一个描述（可选），以及一个用于放置具体控制的视图。
struct SettingItemView<Content: View>: View {
    @EnvironmentObject var localizationManager: LocalizationManager // 注入语言管理器

    let titleKey: String // I18n 标题的键
    let descriptionKey: String? // I18n 描述的键 (可选)
    @ViewBuilder let content: Content // 用于放置实际控制（如Toggle, Picker等）的闭包

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // 使用 LocalizedStringKey 并传入 bundle 参数来支持动态 i18n
                Text(LocalizedStringKey(titleKey), bundle: localizationManager.bundle)
                    .font(.headline) // 标题字体样式

                // 如果有描述，则显示描述
                if let descriptionKey = descriptionKey {
                    Text(LocalizedStringKey(descriptionKey), bundle: localizationManager.bundle)
                        .font(.subheadline) // 描述字体样式
                        .foregroundColor(.gray) // 描述文本颜色
                }
            }
            Spacer() // 将内容推到右侧
            content // 显示具体的设置控制
        }
        .padding(.vertical, 8) // 垂直方向的内边距
    }
}

// 预览 SettingItemView
struct SettingItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            // 示例：带描述的设置项
            SettingItemView(titleKey: "settings.basic.themeMode", descriptionKey: "settings.basic.themeModeDesc") {
                Text("主题模式选择器占位") // Placeholder for a theme mode picker
            }
            // 示例：不带描述的设置项
            SettingItemView(titleKey: "settings.basic.language", descriptionKey: nil) {
                Text("语言选择器占位") // Placeholder for a language picker
            }
        }
        .environmentObject(LocalizationManager()) // 预览时也要注入 LocalizationManager
    }
}

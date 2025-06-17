import SwiftUI

// SettingsSection 是一个通用的视图，用于组织和显示设置的各个分类。
// 它包含一个本地化的标题和一个用于放置该分类下所有设置项的闭包。
struct SettingsSection<Content: View>: View {
    @EnvironmentObject var localizationManager: LocalizationManager // 注入语言管理器

    let titleKey: String // I18n 标题的键
    @ViewBuilder let content: Content // 用于放置该分类下所有设置项的闭包

    var body: some View {
        Section(header: Text(LocalizedStringKey(titleKey), bundle: localizationManager.bundle) // 使用 LocalizedStringKey 并传入 bundle 参数
                                .font(.title3) // 标题字体样式
                                .bold() // 标题加粗
                                .padding(.bottom, 5) // 底部内边距
        ) {
            content // 显示该分类下的所有设置项
        }
    }
}

// 预览 SettingsSection
struct SettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SettingsSection(titleKey: "settings.sections.basic") {
                SettingItemView(titleKey: "settings.basic.themeMode", descriptionKey: "settings.basic.themeModeDesc") {
                    Text("Theme Mode Selector")
                }
                SettingItemView(titleKey: "settings.basic.language", descriptionKey: "settings.basic.languageDesc") {
                    Text("Language Selector")
                }
            }
        }
        .environmentObject(LocalizationManager()) // 预览时也要注入 LocalizationManager
    }
}

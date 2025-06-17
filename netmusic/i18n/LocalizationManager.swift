import Foundation
import SwiftUI

// LocaleKey 存储用户选择的语言，以便持久化
let LocaleKey = "current_locale_key"

// LocalizationManager 是一个 ObservableObject，用于管理应用程序的当前语言环境。
// 任何视图只要访问这个环境对象，就可以响应语言的变化。
class LocalizationManager: ObservableObject {
    // @Published 属性，当 selectedLanguageCode 改变时，会通知订阅者进行更新。
    // 默认从 UserDefaults 加载，如果没有则使用简体中文。
    @Published var selectedLanguageCode: String {
        didSet {
            // 在 didSet 中，所有存储属性都已初始化，所以可以安全访问 bundle
            UserDefaults.standard.set(selectedLanguageCode, forKey: LocaleKey) // 持久化用户的选择
            bundle = Bundle.main.getLocalizedBundle(languageCode: selectedLanguageCode) // 更新 bundle
        }
    }

    // 当前语言对应的 Bundle，用于 LocalizedStringKey
    @Published var bundle: Bundle

    init() {
        // 修正：首先获取初始的语言代码，确保它不触发 didSet
        let initialLanguageCode = UserDefaults.standard.string(forKey: LocaleKey) ?? "zh-Hans"

        // 其次，使用这个初始语言代码来初始化 bundle
        self.bundle = Bundle.main.getLocalizedBundle(languageCode: initialLanguageCode)

        // 最后，再给 selectedLanguageCode 赋值。
        // 这次赋值会触发 didSet，但此时 bundle 已经初始化了。
        self.selectedLanguageCode = initialLanguageCode
    }

    // 设置语言，并更新 UI
    func setLanguage(code: String) {
        self.selectedLanguageCode = code
        // 这里可以添加额外逻辑，比如发送通知或更新应用根视图的 locale 环境
        // 对于 iOS 13+，preferredColorScheme 类似，Text 应该使用 bundle 参数
    }
}

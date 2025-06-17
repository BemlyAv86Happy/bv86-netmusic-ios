import Foundation

extension Bundle {
    // 自定义 Bundle，用于加载指定语言的本地化字符串。
    // 这允许我们在运行时切换应用程序的语言，而无需重启。
    static var localizedBundle: Bundle!

    // 根据传入的语言代码获取对应的本地化 Bundle。
    // 如果找不到特定语言的 Bundle，则回退到主 Bundle。
    func getLocalizedBundle(languageCode: String) -> Bundle {
        // 检查主 Bundle 中是否有指定语言的 .lproj 目录
        if let path = self.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        // 如果找不到特定语言的 Bundle，则返回主 Bundle
        return self
    }
}

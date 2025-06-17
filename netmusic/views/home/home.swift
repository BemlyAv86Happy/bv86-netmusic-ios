import SwiftUI

struct HomeView: View {
    // 注入 localizationManager
    @EnvironmentObject var localizationManager: LocalizationManager

    // 计算属性，返回动态本地化的 Text 视图作为导航标题
    var localizedNavigationTitle: Text {
        Text(LocalizedStringKey(AppRoute.home.titleKey), bundle: localizationManager.bundle)
    }

    var body: some View {
        GeometryReader { geometry in
            ListView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // 修正：将 Text 视图作为参数直接传递给 navigationTitle
        .navigationTitle(localizedNavigationTitle)
    }
}

// MARK: - Preview Provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                // 预览时也要注入 localizationManager
                .environmentObject(LocalizationManager())
        }
    }
}

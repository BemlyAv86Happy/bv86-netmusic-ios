//
//  user.swift
//  netmusic
//
//  Created by 0xav10086 on 2025/6/16.
//

import SwiftUI

struct UserView: View {
    @StateObject var authManager = AuthenticationManager(loginService: MockLoginService())

    // 控制显示哪个登录视图的状态变量
    @State private var showQRLogin: Bool = true // 默认为二维码登录

    var body: some View {
        NavigationView { // 确保最外层有且只有一个 NavigationView
            Group {
                if authManager.isLoggedIn {
                    userMainView() // 假设你有一个主界面视图
                } else {
                    // 根据 showQRLogin 的状态切换视图
                    if showQRLogin {
                        userQRShowView(showQRLogin: $showQRLogin) // 传入 Binding
                    } else {
                        userCellPhoneShowView(showQRLogin: $showQRLogin) // 传入 Binding
                    }
                }
            }
            .environmentObject(authManager) // 注入认证管理器
            // .navigationBarHidden(true) // 如果你希望整个登录流程都没有导航栏，可以在这里隐藏
            // 否则，让子视图通过 .navigationTitle 和 .toolbar 来配置导航栏
//            .navigationTitle("登录") // Primary title for the entire login flow
            .navigationBarTitleDisplayMode(.inline) // Optional: Adjust title display
        }
        .navigationViewStyle(.stack) // 确保在 iPad 等设备上也正常显示
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View  {
        UserView()
    }
}
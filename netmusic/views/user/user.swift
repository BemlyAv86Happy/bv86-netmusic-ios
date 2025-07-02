//
//  user.swift
//  netmusic
//
//  Created by 0xav10086 on 2025/6/16.
//

import SwiftUI

struct UserView: View {
    // 使用 @StateObject 创建并持有 AuthenticationManager 实例
    // @StateObject 确保该对象在 UserView 的整个生命周期中只被创建一次
    @StateObject var authManager = AuthenticationManager()

    var body: some View {
        NavigationView { // 确保子视图可以利用导航功能
            Group { // 使用 Group 根据条件切换视图
                if authManager.isLoggedIn {
                    // 用户已登录，渲染主界面
                    userMainView()
                } else {
                    // 用户尚未登录，显示二维码登录界面
                    UserQRShowView()
                }
            }
            // 将 authManager 注入到子视图的环境中，以便它们可以通过 @EnvironmentObject 访问
            .environmentObject(authManager)
        }
    }
}

struct User_Previews: PreviewProvider {
    static var previews: some View  {
        UserView()
    }
}
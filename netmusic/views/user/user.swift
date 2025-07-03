//
//  user.swift
//  netmusic
//
//  Created by 0xav10086 on 2025/6/16.
//

import SwiftUI

struct UserView: View {
    // 使用 @StateObject 创建并持有 AuthenticationManager 实例
    // 默认使用 MockLoginService 进行开发和测试
    @StateObject var authManager = AuthenticationManager(loginService: MockLoginService())

    // 如果要切换到真实的后端服务，可以将注释掉的 RealLoginService() 替换
    // @StateObject var authManager = AuthenticationManager(loginService: RealLoginService())

    var body: some View {
        NavigationView {
            Group {
                if authManager.isLoggedIn {
                    userMainView() // 你的用户主视图
                } else {
                    userQRShowView() // 你的二维码登录视图
                }
            }
            .environmentObject(authManager)
        }
    }
}

struct User_Previews: PreviewProvider {
    static var previews: some View  {
        UserView()
    }
}
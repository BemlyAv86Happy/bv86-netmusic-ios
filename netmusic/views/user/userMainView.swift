//
// Created by bemly on 2025/7/2.
//

import SwiftUI

struct userMainView: View {
//    var body: some View {
//        Text("userMainView!")
//    }
    @EnvironmentObject var authManager: AuthenticationManager // 注入认证管理器

    var body: some View {
        VStack {
            HStack {
                // 左上角跳过登录按钮
                Button("退出登录") {
                    authManager.logout()
                }
                        .padding()
                Spacer() // 将按钮推到左边
            }

            Spacer() // 将内容垂直居中
        }
    }
}

struct userMainView_Previews: PreviewProvider {
    static var previews: some View  {
        userMainView()
    }
}
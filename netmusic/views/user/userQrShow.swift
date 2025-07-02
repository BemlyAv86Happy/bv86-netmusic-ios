//
// Created by 0xav10086 on 2025/7/2.
//

import Foundation
import SwiftUI

struct UserQRShowView: View {
    @EnvironmentObject var authManager: AuthenticationManager // 注入认证管理器

    var body: some View {
        VStack {
            HStack {
                // 左上角跳过登录按钮
                Button("跳过登录") {
                    authManager.skipLogin()
                }
                .padding()
                Spacer() // 将按钮推到左边
            }

            Spacer() // 将内容垂直居中

            if let qrImage = authManager.qrCodeImage {
                qrImage
                    .resizable()
                    .interpolation(.none) // 保持像素清晰，避免模糊
                    .scaledToFit()
                    .frame(width: 250, height: 250) // 适当大小
                    .padding()
            } else {
                Text("正在加载二维码...")
                    .font(.headline)
                    .padding()
                // 可以显示一个加载指示器
                ProgressView()
            }

            if let error = authManager.errorLoginMessage {
                Text("错误: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("重试/重新生成二维码") {
                    authManager.resetQRCodeAndError()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            Spacer()
        }
        .onAppear {
            // 页面出现时，如果未登录且没有二维码，则获取二维码
            if !authManager.isLoggedIn && authManager.qrCodeImage == nil {
                authManager.fetchAndDisplayQRCode()
            }
        }
        .navigationTitle("扫码登录")
        .navigationBarHidden(true) // 隐藏默认导航栏，因为我们有自定义按钮
    }
}

struct UserQRShowView_Previews: PreviewProvider {
    static var previews: some View {
        UserQRShowView()
            .environmentObject(AuthenticationManager()) // 预览时提供一个实例
    }
}
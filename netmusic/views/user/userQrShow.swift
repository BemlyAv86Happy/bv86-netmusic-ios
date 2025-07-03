// userQrShow.swift
// 位于 netmusic/views/user/

import Foundation
import SwiftUI

struct userQRShowView: View {
    @EnvironmentObject var authManager: AuthenticationManager // 注入认证管理器

    var body: some View {
        VStack {
            // Spacer() // 移除这个 Spacer，让内容从顶部开始

            if let qrImage = authManager.qrCodeImage {
                qrImage
                    .resizable()
                    .interpolation(.none) // 保持像素清晰，避免模糊
                    .scaledToFit()
                    .frame(width: 250, height: 250) // 适当大小
                    .padding(.top, 50) // 增加顶部填充，避免与导航栏重叠
            } else {
                Text("正在加载二维码...")
                    .font(.headline)
                    .padding(.top, 50) // 增加顶部填充
                ProgressView()
            }

            if let error = authManager.errorLoginMessage {
                Text("错误: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 20) // 增加顶部填充

                Button("重试/重新生成二维码") {
                    authManager.resetQRCodeAndError()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20) // 增加顶部填充
            }

            Spacer() // 将下面的按钮推到底部

            // 新增：切换到手机号登录的按钮
            NavigationLink {
                UserCellPhoneShowView() // 导航到手机号登录视图
            } label: {
                Text("切换到手机号登录")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20) // 底部填充
            }
        }
        .onAppear {
            // 页面出现时，如果未登录且没有二维码，则获取二维码
            if !authManager.isLoggedIn && authManager.qrCodeImage == nil {
                authManager.fetchAndDisplayQRCode()
            }
        }
        .navigationTitle("扫码登录") // 设置导航栏标题
        // 移除 .navigationBarHidden(true)，让父 NavigationView 管理显示
        .toolbar { // 使用 toolbar 来放置导航栏按钮
            ToolbarItem(placement: .navigationBarLeading) { // 放置在左上角
                Button("跳过登录") {
                    authManager.skipLogin()
                }
            }
        }
    }
}

struct userQRShowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // 预览时需要 NavigationView
            userQRShowView()
                .environmentObject(AuthenticationManager()) // 预览时提供一个实例
        }
    }
}
// userQrShow.swift
// 位于 netmusic/views/user/

import Foundation
import SwiftUI

struct userQRShowView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var showQRLogin: Bool
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        VStack {
            // 内容标题上移
            Text("user.login.scanCode") // 作为内容标题
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10) // 调整与二维码的间距

            if let qrImage = authManager.qrCodeImage {
                qrImage
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("user.login.loadQRCode")
                        .font(.headline)
                ProgressView()
            }

            // 按钮调整为上下排列，并统一风格
            VStack(spacing: 15) { // 垂直排列，增加间距
                Button {
                    authManager.resetQRCodeAndError()
                } label: {
                    Text("user.login.anewQRCode")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal) // 保持水平内边距
                }

                Button {
                    authManager.clearErrorMessage() // 切换前清除错误信息
                    showQRLogin = false // 切换到手机号登录视图
                } label: {
                    Text("user.login.returnPhone")
                            .font(.headline) // 统一字体大小
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray) // 保持灰色背景
                            .cornerRadius(10)
                            .padding(.horizontal)
                }
            }
                    .padding(.top, 10) // 调整按钮组与二维码的间距

            Spacer() // 将内容向上推

            // 错误信息弹窗保持不变
        }
        .padding(.top, -80)
//        .navigationTitle("登录") // 导航栏标题，保持一级标题
//        .navigationBarTitleDisplayMode(.inline) // 确保标题显示在中间
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("user.login.skipLogin") {
                    authManager.skipLogin()
                }
            }
        }
        .onAppear {
            if !authManager.isLoggedIn && authManager.qrCodeImage == nil {
                authManager.fetchAndDisplayQRCode()
            }
        }
        .alert(item: $authManager.errorLoginMessage) { error in
            Alert(
                title: Text("user.login.error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("user.login.tryAgain")) {
                    authManager.clearErrorMessage()
                }
            )
        }
    }
}

struct userQRShowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            userQRShowView(showQRLogin: .constant(true))
                .environmentObject(AuthenticationManager())
        }
    }
}
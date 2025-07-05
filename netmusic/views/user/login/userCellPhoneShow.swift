// userCellPhoneShow.swift
// 位于 netmusic/views/user/

import SwiftUI

struct userCellPhoneShowView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var showQRLogin: Bool

    @State private var phoneNumber: String = ""
    @State private var passwordOrVerificationCode: String = "" // 字段名称修改
    @State private var isSendingCode: Bool = false // 控制获取验证码按钮状态
    @State private var countdown: Int = 60 // 验证码倒计时

    var body: some View {
        VStack {
            // 内容标题上移
            Text("user.login.Cellphone") // 作为内容标题
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30) // 调整与输入框的间距

            VStack(spacing: 20) {
                TextField("user.login.phoneNumber", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                HStack { // 使用 HStack 放置密码/验证码输入框和按钮
                    SecureField("user.login.passwordOrVerificationCode", text: $passwordOrVerificationCode) // 文本修改
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Button {
                        // 模拟获取验证码逻辑
                        Task {
                            isSendingCode = true
                            print("发送验证码到: \(phoneNumber)")
                            // 实际这里会调用 authManager.sendVerificationCode(phoneNumber)
                            try await Task.sleep(nanoseconds: 2_000_000_000) // 模拟网络请求

                            // 开始倒计时
                            for i in (0..<60).reversed() {
                                countdown = i
                                try await Task.sleep(nanoseconds: 1_000_000_000) // 每秒更新
                            }
                            isSendingCode = false
                            countdown = 60 // 重置倒计时
                        }
                    } label: {
                        Text(isSendingCode ? "\(countdown)s" : "user.login.getVerificationCode")
                            .font(.caption) // 字体小一点
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(isSendingCode ? Color.gray : Color.green) // 根据状态改变颜色
                            .cornerRadius(8)
                    }
                    .disabled(isSendingCode || phoneNumber.isEmpty) // 发送中或手机号为空时禁用
                }
                .padding(.horizontal) // 保持水平内边距
            }
            .padding(.bottom, 30) // 调整输入框组与按钮的间距

            // 登录和返回按钮上移，并统一风格
            VStack(spacing: 15) { // 垂直排列，增加间距
                Button {
                    Task {
                        // 这里根据实际情况判断是密码登录还是验证码登录
                        // 假设如果输入了密码，就用密码登录；如果输入了验证码，就用验证码登录
                        // 为了简化，这里仍然调用 loginByCellphone
                        await authManager.loginByCellphone(phone: phoneNumber, password: passwordOrVerificationCode)
                    }
                } label: {
                    Text("user.login.login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Button {
                    authManager.clearErrorMessage() // 切换前清除错误信息
                    showQRLogin = true // 切换回二维码登录视图
                } label: {
                    Text("user.login.switchScan")
                        .font(.headline) // 统一字体大小
                        .foregroundColor(.white) // 统一白色字体
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray) // 统一灰色背景
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            Spacer() // 将内容向上推

            // 错误信息弹窗保持不变
        }
//        .navigationTitle("登录") // 导航栏标题，保持一级标题
//        .navigationBarTitleDisplayMode(.inline) // 确保标题显示在中间
        .onAppear {
            authManager.clearErrorMessage() // 进入视图时清除错误信息
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("user.login.skipLogin") {
                    authManager.skipLogin()
                }
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

struct userCellPhoneShowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            userCellPhoneShowView(showQRLogin: .constant(false))
                .environmentObject(AuthenticationManager())
        }
    }
}
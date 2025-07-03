//
// Created by 0xav10086 on 2025/7/4.
//

// userCellPhoneShow.swift
// 位于 netmusic/views/user/

import SwiftUI

struct UserCellPhoneShowView: View {
    @EnvironmentObject var authManager: AuthenticationManager // 注入认证管理器
    @Environment(\.dismiss) var dismiss // 用于返回上一视图

    @State private var phoneNumber: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack {
            Spacer() // 将内容垂直居中

            Text("手机号登录")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)

            VStack(spacing: 20) {
                TextField("手机号", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                SecureField("密码", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                if let error = authManager.errorLoginMessage {
                    Text("错误: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task {
                        await authManager.loginByCellphone(phone: phoneNumber, password: password)
                        // 如果登录成功，AuthenticationManager 会设置 isLoggedIn 为 true
                        // UserView 会自动切换到 UserMainView
                    }
                } label: {
                    Text("登录")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            Spacer()

            Button {
                dismiss() // 返回上一个视图 (二维码登录)
            } label: {
                Text("返回扫码登录")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
            }
        }
        .navigationTitle("手机号登录") // 设置导航栏标题
        // 这里不需要 navigationBarHidden，让父 NavigationView 管理
    }
}

struct UserCellPhoneShowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // 预览时需要 NavigationView
            UserCellPhoneShowView()
                .environmentObject(AuthenticationManager())
        }
    }
}
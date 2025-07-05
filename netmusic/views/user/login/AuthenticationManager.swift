//
// Created by 0xav10086 on 2025/7/3.
//

// AuthenticationManager.swift
// 位于 netmusic/views/user/

import Foundation
import SwiftUI
import Combine
import CoreImage // 导入 CoreImage 框架

class AuthenticationManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoggedIn: Bool = false
    @Published var qrCodeImage: Image?
    @Published var errorLoginMessage: AppError?
    @Published var userName: String? // Keep userName for simple display
    @Published var currentUserInfo: UserInfoData? // New property to hold full user data

    // 依赖注入的属性
    private let loginService: LoginAPIService // 这是一个协议类型

    // MARK: - Constants
    let defaultQrCodeURL: String = "https://music.163.com/"

    // MARK: - Private Properties
    private var pollingTask: Task<Void, Never>?
    private var currentQrKey: String? // 当前二维码的唯一标识，用于轮询

    // 初始化器接受一个 LoginAPIService 协议的实现
    // 在开发和测试阶段，默认使用 MockLoginService
    // 在实际生产环境中，这里应该传入 RealLoginService
    init(loginService: LoginAPIService = MockLoginService()) { // 默认使用 MockLoginService
        self.loginService = loginService
        // Removed problematic line: self.userName = MockUserService.getUserDetail(userName)
        // User details should be fetched *after* successful login, not in init.
    }

    // MARK: - Public Methods
    func clearErrorMessage() {
            DispatchQueue.main.async {
                self.errorLoginMessage = nil
            }
    }

    // 获取并显示二维码
    func fetchAndDisplayQRCode() {
        guard !isLoggedIn else { return }

        pollingTask?.cancel()
        qrCodeImage = nil
        errorLoginMessage = nil

        Task {
            do {
                // 1. 获取 QR Key
                let qrKey = try await loginService.getQrKey()
                self.currentQrKey = qrKey // 保存 key 用于轮询

                // 2. 使用 Key 创建二维码
                let response = try await loginService.createQr(key: qrKey)

                let qrImgBase64 = response.body.data.qrimg
                if let qrImage = qrImgBase64.fromBase64ToImage() {
                    DispatchQueue.main.async {
                        self.qrCodeImage = qrImage
                        self.startPollingLoginStatus() // 获取二维码成功后开始轮询
                    }
                } else {
                    throw AppError.decodingError("无法从 Base64 解码二维码图片。")
                }
            } catch {
                DispatchQueue.main.async {
                    self.qrCodeImage = self.defaultQrCodeURL.fromURLToQRCodeImage()
                    if let appError = error as? AppError {
                        self.errorLoginMessage = appError
                    } else {
                        self.errorLoginMessage = AppError.networkError(error.localizedDescription)
                    }
                }
            }
        }
    }

    // 轮询登录状态
    private func startPollingLoginStatus() {
        guard let qrKey = currentQrKey else {
            DispatchQueue.main.async {
                self.errorLoginMessage = AppError.customError("二维码密钥丢失，无法轮询。")
            }
            return
        }

        pollingTask = Task {
            while !Task.isCancelled && !self.isLoggedIn {
                do {
                    // 调用注入的 loginService 的 checkQr 方法
                    let response = try await loginService.checkQr(key: qrKey)

                    if response.body.code == 803 { // 登录成功
                        DispatchQueue.main.async {
                            self.isLoggedIn = true
                            self.userName = response.body.data?.userName
                            self.errorLoginMessage = nil
                            self.pollingTask?.cancel()
                            print("登录成功！用户：\(self.userName ?? "")")
                        }
                    } else if response.body.code == 800 { // 二维码过期
                        DispatchQueue.main.async {
                            self.errorLoginMessage = AppError.backendError(response.body.message ?? "二维码已过期，请重新生成。")
                            self.resetQRCodeAndError() // 过期则重置二维码
                        }
                        self.pollingTask?.cancel() // 停止轮询
                    } else { // 等待扫描或确认中 (或其他非成功非过期状态)
                        DispatchQueue.main.async {
                            self.errorLoginMessage = AppError.backendError(response.body.message ?? "二维码等待扫描或确认中...")
                            // 继续轮询
                        }
                        try await Task.sleep(nanoseconds: 3_000_000_000) // 每3秒轮询一次
                    }
                } catch {
                    DispatchQueue.main.async {
                        if let appError = error as? AppError {
                            self.errorLoginMessage = appError
                        } else {
                            self.errorLoginMessage = AppError.networkError(error.localizedDescription)
                        }
                        self.resetQRCodeAndError() // 网络错误或其他严重错误，重置二维码
                    }
                    self.pollingTask?.cancel()
                }
            }
        }
    }

    // 重置二维码和错误信息
    func resetQRCodeAndError() {
        pollingTask?.cancel() // Cancel any ongoing polling
        currentQrKey = nil
        qrCodeImage = nil
        errorLoginMessage = nil
        fetchAndDisplayQRCode() // Re-fetch QR code
    }

    // 跳过登录（仅用于开发测试）
    func skipLogin() {
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.qrCodeImage = nil
            self.errorLoginMessage = nil
            self.userName = "访客用户" // Simulate a guest user
            // Set some mock user info for skip login if userMainView needs it
            self.currentUserInfo = UserInfoData(
                userName: "蜂群789号",
                avatarUrl: nil,
                backgroundUrl: nil,
                followers: 0,
                follows: 0,
                signature: "您已跳过登录。",
                level: 0            )
            print("已跳过登录。")
        }
    }

    // 手机号登录
    func loginByCellphone(phone: String, password: String) {
        Task {
            do {
                let response = try await loginService.loginByCellphone(phone: phone, password: password)
                if response.code == 200 { // 假设成功码是200
                    await MainActor.run {
                        self.isLoggedIn = true
                        self.userName = "手机用户: \(phone)" // Placeholder, get actual name from response if available
                        self.currentUserInfo = response.body.data // Populate user info from phone login response
                        self.errorLoginMessage = nil
                        print("手机号登录成功！")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorLoginMessage = AppError.backendError(response.body.message ?? "手机号或密码错误。")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    if let appError = error as? AppError {
                        self.errorLoginMessage = appError
                    } else {
                        self.errorLoginMessage = AppError.networkError(error.localizedDescription)
                    }
                }
            }
        }
    }

    // 用户登出
    func logout() {
        pollingTask?.cancel() // Cancel any ongoing polling task
        Task { // 登出也应该异步，因为可能调用 API
            do {
                let success = try await loginService.logout()
                if success {
                    await MainActor.run {
                        self.isLoggedIn = false
                        self.qrCodeImage = nil
                        self.errorLoginMessage = nil
                        self.userName = nil // Clear user name on logout
                        self.currentUserInfo = nil // Clear full user info on logout
                        print("用户已登出。")
                        self.fetchAndDisplayQRCode() // Optionally fetch new QR code after logout
                    }
                } else {
                     await MainActor.run {
                        self.errorLoginMessage = AppError.customError("登出失败。")
                     }
                }
            } catch {
                 await MainActor.run {
                    self.errorLoginMessage = AppError.networkError(error.localizedDescription)
                 }
            }
        }
    }
}
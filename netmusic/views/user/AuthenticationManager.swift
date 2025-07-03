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
    @Published var userName: String?
    @Published var userInfo: String?

    // 依赖注入的属性
    private let loginService: LoginAPIService // 这是一个协议类型

    // MARK: - Constants
    let defaultUserName: String = "蜂群987号"
    let defaultQrCodeURL: String = "https://music.163.com/"

    // MARK: - Private Properties
    private var pollingTask: Task<Void, Never>?
    private var currentQrKey: String? // 当前二维码的唯一标识，用于轮询

    // 初始化器接受一个 LoginAPIService 协议的实现
    // 在开发和测试阶段，默认使用 MockLoginService
    // 在实际生产环境中，这里应该传入 RealLoginService
    init(loginService: LoginAPIService = MockLoginService()) { // 默认使用 MockLoginService
        self.loginService = loginService
        self.userName = defaultUserName
    }

    // MARK: - Public Methods

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

    // 开始轮询登录状态
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
                            self.userName = response.body.data?.userName ?? self.defaultUserName
                            self.userInfo = response.body.data?.userInfo
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

    // 重置二维码和错误信息，重新开始流程
    func resetQRCodeAndError() {
        pollingTask?.cancel()
        qrCodeImage = nil
        errorLoginMessage = nil
        fetchAndDisplayQRCode()
    }

    // 跳过二维码登录，直接显示主界面
    func skipLogin() {
        pollingTask?.cancel()
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.userName = self.defaultUserName
            self.userInfo = "游客模式"
            self.qrCodeImage = nil
            self.errorLoginMessage = nil
            print("已跳过二维码登录，进入游客模式。")
        }
    }

    func loginByCellphone(phone: String, password: String) async {
        DispatchQueue.main.async {
            self.errorLoginMessage = nil // 清除之前的错误信息
        }
        do {
            let response = try await loginService.loginByCellphone(phone: phone, password: password)

            if response.body.code == 200 { // 假设 200 表示登录成功
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.userName = response.body.data?.userName ?? self.defaultUserName
                    self.userInfo = response.body.data?.userInfo
                    self.errorLoginMessage = nil
                    print("手机号登录成功！用户：\(self.userName ?? "")")
                }
            } else {
                // 登录失败，显示后端返回的错误信息
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

    // 用户登出
    func logout() {
        Task { // 登出也应该异步，因为可能调用 API
            do {
                let success = try await loginService.logout()
                if success {
                    DispatchQueue.main.async {
                        self.isLoggedIn = false
                        self.qrCodeImage = nil
                        self.errorLoginMessage = nil
                        self.userName = self.defaultUserName
                        self.userInfo = nil
                        print("用户已登出。")
                        self.fetchAndDisplayQRCode()
                    }
                } else {
                     DispatchQueue.main.async {
                        self.errorLoginMessage = AppError.customError("登出失败。")
                     }
                }
            } catch {
                 DispatchQueue.main.async {
                    self.errorLoginMessage = AppError.networkError(error.localizedDescription)
                 }
            }
        }
    }
}
//
// Created by 0xav10086 on 2025/7/3.
//

// loginAPI.swift
// 位于 mockAPI/user/

import Foundation

// MARK: - Login API Protocol
protocol LoginAPIService {
    func getQrKey() async throws -> String // 模拟获取 unikey
    func createQr(key: String) async throws -> GenerateQRCodeLoginInfoResponse
    func checkQr(key: String) async throws -> PollingQrCodeLoginResponse
    func loginByCellphone(phone: String, password: String) async throws -> PollingQrCodeLoginResponse
    func logout() async throws -> Bool
}

// MARK: - Mock Login API Service
struct MockLoginService: LoginAPIService {
    func getQrKey() async throws -> String {
        print("--- Mock: getQrKey ---")
        try await Task.sleep(nanoseconds: 500_000_000)
        return "mock_unikey_\(UUID().uuidString.prefix(8))"
    }

    func createQr(key: String) async throws -> GenerateQRCodeLoginInfoResponse {
        print("--- Mock: createQr with key: \(key) ---")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let response: GenerateQRCodeLoginInfoResponse = .init(
            code: 200,
            status: 200,
            body: .init(
                code: 200,
                data: .init(
                    qrurl: "https://example.com/mock_qr?key=\(key)",
                    qrimg: "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEAAQMAAACTJ" // 模拟 Base64 图片数据
                )
            )
        )
        return response
    }

    func checkQr(key: String) async throws -> PollingQrCodeLoginResponse {
        print("--- Mock: checkQr with key: \(key) ---")
        try await Task.sleep(nanoseconds: 1_500_000_000) // 模拟轮询延迟

        if Int.random(in: 0...10) > 7 { // 约 30% 几率模拟成功
            return .init(
                code: 200,
                status: 200,
                body: .init(
                    code: 803, // 模拟成功登录的 code
                    message: "登录成功！",
                    data: nil
                )
            )
        } else if Int.random(in: 0...10) > 5 { // 约 20% 几率模拟二维码过期
            return .init(
                code: 200,
                status: 200,
                body: .init(
                    code: 800, // 模拟二维码过期的 code
                    message: "二维码已过期，请重新生成。",
                    data: nil
                )
            )
        } else { // 模拟等待扫描
            return .init(
                code: 200,
                status: 200,
                body: .init(
                    code: 801, // 模拟等待扫描的 code (或其他非成功非过期 code)
                    message: "二维码等待扫描或确认中...",
                    data: nil
                )
            )
        }
    }

    func loginByCellphone(phone: String, password: String) async throws -> PollingQrCodeLoginResponse {
        print("--- Mock: loginByCellphone with phone: \(phone) ---")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if phone == "12345678900" && password == "password" {
            return .init(
                code: 200,
                status: 200,
                body: .init(
                    code: 200, // 模拟成功
                    message: "手机号登录成功！",
                    data: nil
                )
            )
        } else {
            return .init(
                code: 200,
                status: 200,
                body: .init(
                    code: 400, // 模拟失败
                    message: "手机号或密码错误。",
                    data: nil
                )
            )
        }
    }

    func logout() async throws -> Bool {
        print("--- Mock: logout ---")
        try await Task.sleep(nanoseconds: 300_000_000)
        return true // 模拟登出成功
    }
}

// MARK: - Real Login API Service (占位符，待实际实现)
// struct RealLoginService: LoginAPIService {
//     func getQrKey() async throws -> String {
//         // 真实网络请求，例如使用 URLSession 或 Alamofire
//     }
//     func createQr(key: String) async throws -> GenerateQRCodeLoginInfoResponse { /* ... */ }
//     func checkQr(key: String) async throws -> PollingQrCodeLoginResponse { /* ... */ }
//     func loginByCellphone(phone: String, password: String) async throws -> PollingQrCodeLoginResponse { /* ... */ }
//     func logout() async throws -> Bool { /* ... */ }
// }

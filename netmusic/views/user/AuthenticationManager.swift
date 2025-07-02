//
// Created by 0xav10086 on 2025/7/2.
//
// 定义一些数据结构来解析后端响应，并定义一个自定义的错误类型

import Foundation
import SwiftUI // For Image
import Combine // 用于取消任务
import CoreImage // 导入 CoreImage 框架来使用 CIFilter

// MARK: - API Response Models

struct GenerateQRCodeLoginInfoResponse: Decodable {
    let code: Int
    let status: Int
    let body: GenerateQRCodeLoginInfoBody
}

struct GenerateQRCodeLoginInfoBody: Decodable {
    let code: Int
    let data: QRCodeData
}

struct QRCodeData: Decodable {
    let qrurl: String // 二维码的URL
    let qrimg: String // Base64 编码的二维码图片数据
}

struct PollingQrCodeLoginResponse: Decodable {
    let code: Int
    let status: Int
    let body: PollingQrCodeLoginBody
}

struct PollingQrCodeLoginBody: Decodable {
    let code: Int
    let message: String? // 登录失败时的错误信息
    let data: UserInfoData? // 登录成功时的用户信息
}

struct UserInfoData: Decodable {
    let userName: String // 用户的名字
    let userInfo: String // 用户的其他信息
    // 根据你实际的用户信息结构添加更多字段
}

// MARK: - Custom Error Type

enum AppError: Error, Identifiable {
    case networkError(String)
    case decodingError(String)
    case backendError(String) // 后端返回的业务逻辑错误
    case customError(String)

    var id: String {
        switch self {
        case .networkError(let message): return "Network Error: \(message)"
        case .decodingError(let message): return "Decoding Error: \(message)"
        case .backendError(let message): return "Backend Error: \(message)"
        case .customError(let message): return "Error: \(message)"
        }
    }

    var localizedDescription: String {
        switch self {
        case .networkError(let message): return "网络错误: \(message)"
        case .decodingError(let message): return "数据解析错误: \(message)"
        case .backendError(let message): return "登录失败: \(message)"
        case .customError(let message): return message
        }
    }
}

// MARK: - String Extensions for QR Code

extension String {
    // 将 Base64 字符串转换为 SwiftUI Image
    func fromBase64ToImage() -> Image? {
        guard let data = Data(base64Encoded: self) else {
            print("Error: Could not decode base64 string.")
            return nil
        }
        guard let uiImage = UIImage(data: data) else {
            print("Error: Could not create UIImage from data.")
            return nil
        }
        return Image(uiImage: uiImage)
    }

    // 将 URL 转换为 SwiftUI Image (通过 Core Image 生成二维码)
    func fromURLToQRCodeImage() -> Image? {
        let context = CIContext()
        // 修正: 使用 CIFilter(name: "CIQRCodeGenerator") 来初始化二维码生成器
        let filter = CIFilter(name: "CIQRCodeGenerator")

        let data = self.data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage") // 使用可选链，因为 filter 现在是可选的

        if let outputImage = filter?.outputImage { // 使用可选链
            // 放大二维码，避免太小，同时保持清晰度
            let scaleX = 10.0
            let scaleY = 10.0
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return Image(uiImage: UIImage(cgImage: cgImage))
            }
        }
        return nil
    }
}

// 以下类将负责管理所有登录相关的状态和逻辑
class AuthenticationManager: ObservableObject {
    // MARK: - Published Properties (全局变量)
    @Published var isLoggedIn: Bool = false
    @Published var qrCodeImage: Image?
    @Published var errorLoginMessage: AppError?
    @Published var userName: String?
    @Published var userInfo: String? // 用于存储用户的其他信息

    // MARK: - Constants
    let defaultUserName: String = "蜂群987号"
    let defaultQrCodeURL: String = "https://music.163.com/"

    // MARK: - Private Properties
    private var pollingTask: Task<Void, Never>? // 用于控制轮询任务
    private var currentQrKey: String? // 当前二维码的唯一标识，用于轮询

    init() {
        // 初始化时设置默认用户名
        self.userName = defaultUserName
    }

    // MARK: - Backend Simulation (替换为实际的后端调用)

    // 模拟后端的 generateQRCodeLoginInfo 函数
    func generateQRCodeLoginInfo(query: [String: Any]) async throws -> GenerateQRCodeLoginInfoResponse {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 500_000_000)

        // 模拟成功响应
        let successResponse: [String: Any] = [
            "code": 200,
            "status": 200,
            "body": [
                "code": 200,
                "data": [
                    "qrurl": "https://example.com/qr/login?key=qr_key_\(UUID().uuidString.prefix(8))", // 每次生成新的key
                    "qrimg": "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEAAQMAAACTJ" // 模拟 Base64 图片数据
                    // 实际的 Base64 字符串会非常长
                ]
            ]
        ]
        // 模拟网络请求和JSON解析
        let jsonData = try JSONSerialization.data(withJSONObject: successResponse)
        let decodedResponse = try JSONDecoder().decode(GenerateQRCodeLoginInfoResponse.self, from: jsonData)

        // 修正: qrurl 是非可选的 String，不需要 if let
        let urlString = decodedResponse.body.data.qrurl
        if let url = URL(string: urlString),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            self.currentQrKey = queryItems.first(where: { $0.name == "key" })?.value
        }


        // 模拟失败响应 (取消注释测试失败情况)
        // throw AppError.networkError("模拟网络请求失败")

        return decodedResponse
    }

    // 模拟后端的 pollingQrCodeLogin 函数
    func pollingQrCodeLogin(qrKey: String) async throws -> PollingQrCodeLoginResponse {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // 模拟登录成功响应
        // 在实际应用中，后端会根据 qrKey 检查登录状态
        // 这里我们模拟在几次轮询后成功登录
        if Int.random(in: 0...10) > 7 { // 约 30% 几率模拟成功
            let successResponse: [String: Any] = [ // 明确类型
                "code": 200,
                "status": 200,
                "body": [
                    "code": 200,
                    "data": [
                        "userName": "实际用户名", // 实际用户的名字
                        "userInfo": "VIP用户，等级10" // 实际用户的其他信息
                    ]
                ]
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: successResponse)
            return try JSONDecoder().decode(PollingQrCodeLoginResponse.self, from: jsonData)
        } else {
            // 模拟登录等待中或失败
            let failureResponse: [String: Any] = [ // 明确类型
                "code": 200, // 注意，这里 code 200 表示请求成功，但业务状态可能不成功
                "status": 200,
                "body": [
                    "code": 401, // 401 表示未授权或登录失败
                    "message": "二维码等待扫描或已过期，请重新生成。"
                ]
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: failureResponse)
            return try JSONDecoder().decode(PollingQrCodeLoginResponse.self, from: jsonData)
        }
    }

    // MARK: - Public Methods

    // 获取并显示二维码
    func fetchAndDisplayQRCode() {
        // 如果已经登录，则不需要获取二维码
        guard !isLoggedIn else { return }

        // 取消之前的轮询任务，防止多余请求
        pollingTask?.cancel()
        qrCodeImage = nil // 清空当前二维码
        errorLoginMessage = nil // 清空错误信息

        Task {
            do {
                let response = try await generateQRCodeLoginInfo(query: ["type": "login"])

                // 修正: qrimg 是非可选的 String，不需要 if let
                let qrImgBase64 = response.body.data.qrimg
                if let qrImage = qrImgBase64.fromBase64ToImage() {
                    DispatchQueue.main.async {
                        self.qrCodeImage = qrImage
                        self.startPollingLoginStatus() // 获取二维码成功后开始轮询
                    }
                } else {
                    throw AppError.decodingError("无法从 Base64 解码二维码图片。") // 更具体的错误信息
                }
            } catch {
                DispatchQueue.main.async {
                    self.qrCodeImage = self.defaultQrCodeURL.fromURLToQRCodeImage() // 显示默认二维码
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
                    let response = try await pollingQrCodeLogin(qrKey: qrKey)

                    if response.body.code == 200 { // 登录成功
                        DispatchQueue.main.async {
                            self.isLoggedIn = true
                            self.userName = response.body.data?.userName ?? self.defaultUserName
                            self.userInfo = response.body.data?.userInfo // 更新用户信息
                            self.errorLoginMessage = nil
                            self.pollingTask?.cancel() // 登录成功后停止轮询
                            print("登录成功！用户：\(self.userName ?? "")")
                        }
                    } else if response.body.code == 401 { // 等待扫描或过期
                        DispatchQueue.main.async {
                            self.errorLoginMessage = AppError.backendError(response.body.message ?? "二维码等待扫描或已过期。")
                            // 继续轮询，直到登录成功或出现其他错误
                        }
                        // 短暂等待后继续轮询
                        try await Task.sleep(nanoseconds: 3_000_000_000) // 每3秒轮询一次
                    } else { // 其他后端业务错误
                        DispatchQueue.main.async {
                            self.errorLoginMessage = AppError.backendError(response.body.message ?? "登录发生未知错误。")
                            self.resetQRCodeAndError() // 登录失败，重置二维码
                        }
                        self.pollingTask?.cancel() // 停止轮询
                    }
                } catch {
                    DispatchQueue.main.async {
                        if let appError = error as? AppError {
                            self.errorLoginMessage = appError
                        } else {
                            self.errorLoginMessage = AppError.networkError(error.localizedDescription)
                        }
                        self.resetQRCodeAndError() // 网络错误，重置二维码
                    }
                    self.pollingTask?.cancel() // 停止轮询
                }
            }
        }
    }

    // 重置二维码和错误信息，重新开始流程
    func resetQRCodeAndError() {
        pollingTask?.cancel()
        qrCodeImage = nil
        errorLoginMessage = nil
        // userName 不重置，保持默认或已登录的值
        // userInfo 不重置
        fetchAndDisplayQRCode() // 重新获取二维码
    }

    // 跳过二维码登录，直接显示主界面
    func skipLogin() {
        pollingTask?.cancel() // 取消任何正在进行的轮询
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.userName = self.defaultUserName // 设置为默认用户名
            self.userInfo = "游客模式" // 可以设置一些默认信息
            self.qrCodeImage = nil
            self.errorLoginMessage = nil
            print("已跳过二维码登录，进入游客模式。")
        }
    }

    // 用户登出
    func logout() {
        pollingTask?.cancel()
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.qrCodeImage = nil
            self.errorLoginMessage = nil
            self.userName = self.defaultUserName
            self.userInfo = nil
            print("用户已登出。")
            self.fetchAndDisplayQRCode() // 登出后重新显示二维码
        }
    }
}
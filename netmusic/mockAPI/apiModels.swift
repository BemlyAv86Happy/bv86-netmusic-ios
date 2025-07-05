//
// Created by 0xav10086 on 2025/7/3.
//

// apiModels.swift
// 位于 mockAPI/user/

import Foundation
import SwiftUI // For Image
import CoreImage // For CIFilter.qrCodeGenerator()

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

// UserInfoData now includes all user-related details
struct UserInfoData: Identifiable, Codable {
    let id = UUID() // For Identifiable conformance, not from API
    var userName: String // 用户的名字
    var avatarUrl: URL?
    var backgroundUrl: URL?
    var followers: Int // Followers
    var follows: Int // Following
    var signature: String?
    var level: Int // 用户等级

    // Added to align with previous UserProfile and UserDetail properties
    // If these are not strictly part of 'UserInfoData' in your backend,
    // you might need to reconsider your model structure or add them
    // as optional properties if they can sometimes be missing.
    // For now, I'm adding them back to keep the `isArtist` logic compatible
    // with the original design that you had from `UserProfile`.
    // If you explicitly do NOT want these, you would remove them.

    // Add a convenience computed property for nickname if userName is the source
    var nickname: String {
        return userName
    }
}


// PlaylistItem remains the same
struct PlaylistItem: Identifiable, Codable {
    let id: Int // Assuming ID from API
    var name: String
    var coverImgUrl: URL?
    var playCount: Int
    var trackCount: Int
}

// MARK: - String Extensions for QR Code
enum AppError: LocalizedError, Identifiable {
    case networkError(String)
    case decodingError(String)
    case backendError(String)
    case customError(String)

    var id: String {
        self.localizedDescription
    }

    var errorDescription: String? {
        switch self {
        case .networkError(let message): return "网络错误: \(message)"
        case .decodingError(let message): return "数据解析错误: \(message)"
        case .backendError(let message): return "登录失败: \(message)"
        case .customError(let message): return message
        }
    }
}

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
        let filter = CIFilter(name: "CIQRCodeGenerator") // 修正：使用 CIFilter(name:)

        let data = self.data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")

        if let outputImage = filter?.outputImage {
            let scaleX = 10.0
            let scaleY = 10.0
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return Image(cgImage, scale: 1.0, label: Text("QR Code"))
            }
        }
        return nil
    }
}
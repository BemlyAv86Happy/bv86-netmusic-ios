//
// Created by bemly on 2025/6/17.
//

import Foundation

class NELoginQrCreate {
}

import Foundation
import UIKit // 如果是 iOS/tvOS/watchOS 项目，用于 UIImage
// import Cocoa // 如果是 macOS 项目，用于 NSImage

// 定义可能发生的错误
enum QRCodeGeneratorError: Error, LocalizedError {
    case missingParameter(String) // 缺少必需参数
    case urlGenerationFailed // URL 生成失败
    case qrCodeGenerationFailed // 二维码生成失败
    case imageConversionFailed // 图片转换失败

    var errorDescription: String? {
        switch self {
        case .missingParameter(let param):
            return "缺少必需参数: \(param)"
        case .urlGenerationFailed:
            return "登录 URL 生成失败。"
        case .qrCodeGenerationFailed:
            return "二维码图片生成失败。"
        case .imageConversionFailed:
            return "图片数据转换失败。"
        }
    }
}

// 异步函数，用于模拟原始的 module.exports
// query 参数应包含 "key" (字符串) 和可选的 "qrimg" (布尔值)
func generateQRCodeLoginInfo(query: [String: Any]) async throws -> [String: Any] {

    // 确保 `key` 参数存在
    guard let key = query["key"] as? String else {
        throw QRCodeGeneratorError.missingParameter("key")
    }

    // 根据 key 构建登录 URL
    guard let url = URL(string: "https://music.163.com/login?codekey=\(key)") else {
        throw QRCodeGeneratorError.urlGenerationFailed
    }
    let qrURLString = url.absoluteString // 获取 URL 的字符串形式

    var qrImageBase64: String = ""
    // 检查是否需要生成二维码图片数据 (qrimg 参数为 true)
    if (query["qrimg"] as? Bool) == true {
        // 使用 CoreImage 生成二维码
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            throw QRCodeGeneratorError.qrCodeGenerationFailed
        }

        // 设置输入消息 (URL)
        qrFilter.setValue(qrURLString.data(using: .utf8), forKey: "inputMessage")
        // 设置纠错级别 (L, M, Q, H - L 最低，H 最高)
        qrFilter.setValue("M", forKey: "inputCorrectionLevel") // 这里选择中等纠错级别

        // 获取二维码图像
        guard let ciImage = qrFilter.outputImage else {
            throw QRCodeGeneratorError.qrCodeGenerationFailed
        }

        // 进一步处理 CIImage，使其像素化且清晰
        let scaleX = 200 / ciImage.extent.size.width // 放大倍数，例如放大到 200x200 像素
        let scaleY = 200 / ciImage.extent.size.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // 将 CIImage 转换为 UIImage (或 NSImage)
        #if canImport(UIKit) // 针对 iOS/tvOS/watchOS
        let uiImage = UIImage(ciImage: transformedImage)
        guard let imageData = uiImage.pngData() else { // 转换为 PNG 数据
            throw QRCodeGeneratorError.imageConversionFailed
        }
        #elseif canImport(AppKit) // 针对 macOS
        let rep = NSCIImageRep(ciImage: transformedImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        guard let imageData = nsImage.tiffRepresentation?.bitmap?.png else { // 转换为 PNG 数据 (macOS 路径)
            throw QRCodeGeneratorError.imageConversionFailed
        }
        #else
        // 其他平台不支持图片转换
        throw QRCodeGeneratorError.imageConversionFailed
        #endif

        // 将图片数据转换为 base64 字符串，并构建 Data URL 格式
        qrImageBase64 = "data:image/png;base64,\(imageData.base64EncodedString())"
    }

    // 返回结果
    return [
        "code": 200,
        "status": 200,
        "body": [
            "code": 200,
            "data": [
                "qrurl": qrURLString,
                "qrimg": qrImageBase64
            ]
        ]
    ]
}

// --- 如何调用这个函数 (在异步上下文中调用示例) ---
/*
// 在一个异步上下文（例如 View Controller 的 viewDidLoad 或一个异步方法中）
Task {
    do {
        // 示例 1: 只获取 URL，不生成图片数据
        let query1: [String: Any] = [
            "key": "your_qrcode_key_here_1", // 替换为实际的二维码 key
            "qrimg": false
        ]
        let result1 = try await generateQRCodeLoginInfo(query: query1)
        print("仅 URL 结果:", result1)

        // 示例 2: 获取 URL 和图片数据
        let query2: [String: Any] = [
            "key": "your_qrcode_key_here_2", // 替换为实际的二维码 key
            "qrimg": true
        ]
        let result2 = try await generateQRCodeLoginInfo(query: query2)
        print("带图片数据结果:", result2)

        // 你可以从 result2["body"]["data"]["qrimg"] 获取 base64 字符串
        // 然后将其转换回图片显示在 UI 上
        if let body = result2["body"] as? [String: Any],
           let data = body["data"] as? [String: Any],
           let qrimgBase64 = data["qrimg"] as? String,
           let base64String = qrimgBase64.replacingOccurrences(of: "data:image/png;base64,", with: ""),
           let imageData = Data(base64Encoded: base64String),
           let qrCodeImage = UIImage(data: imageData) { // 或 NSImage(data:)

            print("二维码图片已成功生成并转换为 UIImage！")
            // 你现在可以使用 qrCodeImage 在你的 UI 上显示它
        }

    } catch {
        print("生成二维码信息时发生错误: \(error.localizedDescription)")
    }
}
*/
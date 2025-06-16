//
// Created by bemly on 2025/6/17.
//

import Foundation

class NELoginQrChk {
}

// --- 重要：WEAPI 加密占位符 ---
// 你必须在这里实现实际的 'weapi' 加密逻辑。
// 这是一个占位函数，你实际的实现将非常复杂。
// 如果你跳过这一步，请求在服务器端很可能会失败。
func encryptWeapiData(data: [String: Any]) throws -> Data {
    // 再次强调，这里是你实现网易云音乐 'weapi' 加密逻辑的地方。
    // 这通常涉及使用固定的密钥和填充进行特定的 AES 加密，
    // 然后对结果进行格式化（例如，Base64 编码）。
    // 如果没有实际的算法，这个函数将无法完成。

    // 仅用于演示，这里只是将数据转换为 JSON Data（这不是真正的 WEAPI 加密）。
    // 在实际场景中，这里应该是加密后的数据。
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        // 在真正的 weapi 实现中，你会在这里加密 jsonData。
        // 目前，我们只是返回它。这很可能导致对实际 API 的调用失败。
        return jsonData
    } catch {
        throw QRCodeLoginError.encryptionFailed(error)
    }
}
// ------------------------------------------------

// 定义一个异步函数来模拟原始的 module.exports
func qrCodeClientLogin(query: [String: Any], request: @escaping (URLRequest, @escaping (Result<Data, Error>) -> Void) -> Void) async throws -> [String: Any] {

    // 假设 query 中包含：
    // - "key": String (二维码登录的唯一键，通常是 /login/qrcode/key 接口获取的)
    // - "cookie": [String: String]? (可选，Cookie 字典)
    // - "proxy": String? (可选，代理地址 - 本示例不实现代理设置)
    // - "realIP": String? (可选，真实 IP - 本示例不实现设置)

    // 确保 `key` 参数存在
    guard let key = query["key"] as? String else {
        throw QRCodeLoginError.missingParameter("key")
    }

    // 构建 POST 请求体数据
    let postData: [String: Any] = [
        "key": key,
        "type": 1 // 原始代码中固定为 1
    ]

    // 获取 Cookie
    let requestCookies: [String: String] = (query["cookie"] as? [String: String]) ?? [:]

    // --- 重要：WEAPI 加密步骤 ---
    // 在这里使用 'weapi' 算法加密整个 postData 字典。
    // URLRequest 的 `httpBody` 将是加密后的结果。
    let encryptedData = try encryptWeapiData(data: postData)

    // 构建 URLRequest
    guard let url = URL(string: "https://music.163.com/weapi/login/qrcode/client/login") else {
        throw QRCodeLoginError.invalidURL
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = encryptedData // 将加密后的数据作为请求体
    // Content-Type 可能仍然需要 "application/x-www-form-urlencoded"
    // 或者如果加密输出是 JSON，则可能是 "application/json"。请查阅 API 文档。
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    // 设置 Cookie Header
    let cookieString = requestCookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
    if !cookieString.isEmpty {
        urlRequest.setValue(cookieString, forHTTPHeaderField: "Cookie")
    }

    // --- 模拟原始的 `request` 函数调用 ---
    // 使用 withCheckedThrowingContinuation 将基于 completionHandler 的 URLSession 转换为 async/await
    return try await withCheckedThrowingContinuation { continuation in
        request(urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    // 解析 JSON 响应
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        throw QRCodeLoginError.invalidResponse("无法将响应解析为 JSON")
                    }

                    // 原始代码在 code == 200 时处理，其他情况直接返回 body
                    // 并从 result.cookie 中获取并拼接 cookie 字符串
                    // 在真实的 URLSession 设置中，你需要从 HTTPURLResponse 的 'Set-Cookie' 头部解析
                    var finalBody = json
                    // Cookie 处理占位符，需要你根据实际的网络请求库/方法来获取并处理 Cookie。

                    continuation.resume(returning: [
                        "status": 200,
                        "body": finalBody,
                        // "cookie": "...", // 拼接后的 cookie 字符串占位符
                    ])

                } catch {
                    // 捕获 JSON 解析错误
                    continuation.resume(throwing: QRCodeLoginError.jsonParsingFailed(error))
                }
            case .failure(let error):
                // 捕获网络请求失败
                // 原始代码的 catch 块非常宽泛，总是返回 status 200 和空 body，并尝试返回 result.cookie
                // 这里我们返回更具体的错误，但如果需要模拟原行为，可以修改
                continuation.resume(throwing: error)
            }
        }
    }
}

// --- 自定义错误定义 ---
enum QRCodeLoginError: Error, LocalizedError {
    case missingParameter(String) // 缺少必需参数
    case invalidURL // 无效的 URL
    case networkError(Error) // 网络请求失败
    case invalidResponse(String) // 无效的服务器响应
    case jsonParsingFailed(Error) // JSON 解析失败
    case encryptionFailed(Error) // 数据加密失败

    var errorDescription: String? {
        switch self {
        case .missingParameter(let param):
            return "缺少必需参数: \(param)"
        case .invalidURL:
            return "无效的 URL"
        case .networkError(let error):
            return "网络请求失败: \(error.localizedDescription)"
        case .invalidResponse(let message):
            return "无效的服务器响应: \(message)"
        case .jsonParsingFailed(let error):
            return "JSON 解析失败: \(error.localizedDescription)"
        case .encryptionFailed(let error):
            return "数据加密失败: \(error.localizedDescription)"
        }
    }
}

// --- 模拟一个简单的 Swift 请求函数 (替代原始代码中的 `request`) ---
func performRequest(urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(QRCodeLoginError.networkError(error)))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(QRCodeLoginError.invalidResponse("非 HTTP 响应")))
                    return
                }
                // 网易云 API 即使在逻辑错误时也常返回 200，实际错误码在 body.code 中
                // 所以这里不对 HTTP 状态码进行严格的 2xx 检查作为主要错误判断。

                guard let data = data else {
                    completion(.failure(QRCodeLoginError.invalidResponse("没有接收到数据")))
                    return
                }
                completion(.success(data))
            }.resume()
}

// --- 如何调用这个函数 (在异步上下文中调用示例) ---
/*
// 在一个异步上下文（例如 View Controller 的 viewDidLoad 或一个异步方法中）
Task {
    do {
        // 假设你已经通过 /login/qrcode/key 接口获取到了二维码的 key
        let query: [String: Any] = [
            "key": "your_qrcode_key_here", // 请替换为实际获取到的二维码 key
            "cookie": ["NMTID": "some_id"] // 示例 Cookie
        ]

        // 调用 qrCodeClientLogin 函数，并传入 performRequest 闭包
        let result = try await qrCodeClientLogin(query: query, request: performRequest)

        print("二维码登录验证结果:", result)
        if let body = result["body"] as? [String: Any], let code = body["code"] as? Int {
            if code == 200 {
                print("二维码登录验证成功！")
                // 这里通常会返回登录用户的详细信息和新的 Session Cookie
            } else {
                print("二维码登录验证失败，错误码：\(code)")
                // 常见错误码可能包括 800 (二维码已失效), 801 (等待扫码), 802 (待确认)
            }
        }

    } catch {
        print("二维码登录验证过程中发生错误: \(error.localizedDescription)")
    }
}
*/
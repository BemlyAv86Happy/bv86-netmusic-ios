//
// Created by bemly on 2025/6/17.
//

import Foundation
import CryptoKit // 用于 MD5 哈希（iOS 13+ / macOS 10.15+）

public class NELoginPhone {
    public init() {}


    // --- 重要：WEAPI 加密占位符 ---
    // 你必须在这里实现实际的 'weapi' 加密逻辑。
    // 这是一个占位函数。你实际的实现将非常复杂。
    // 如果你跳过这一步，请求在服务器端很可能会失败。
    func encryptWeapiData(data: [String: Any]) throws -> Data {
        // 这里是你实现网易云音乐 'weapi' 加密逻辑的地方。
        // 它通常涉及使用固定的密钥和填充进行特定的 AES 加密，
        // 然后对结果进行格式化（例如，Base64 编码）。
        // 如果没有实际的算法，这个函数无法完成。

        // 仅用于演示，这里只是将数据转换为 JSON Data（这不是真正的 WEAPI 加密）
        // 在实际场景中，这里应该是加密后的数据。
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            // 在真正的 weapi 实现中，你会在这里加密 jsonData。
            // 目前，我们只是返回它。这很可能导致对实际 API 的调用失败。
            return jsonData
        } catch {
            throw PhoneLoginError.encryptionFailed(error)
        }
    }
    // ------------------------------------------------


// 定义一个异步函数来模拟原始的 module.exports
    func phoneLogin(query: [String: Any], request: @escaping (URLRequest, @escaping (Result<Data, Error>) -> Void) -> Void) async throws -> [String: Any] {

        // 假设 query 中包含：
        // - "phone": String (手机号)
        // - "countrycode": String? (可选，国家区号，默认 '86')
        // - "captcha": String? (可选，短信验证码)
        // - "password": String? (可选，原始密码)
        // - "md5_password": String? (可选，已MD5加密的密码)
        // - "cookie": [String: String]? (可选，Cookie字典)
        // - "proxy": String? (可选，代理地址 - 本示例不实现代理设置)
        // - "realIP": String? (可选，真实IP - 本示例不实现设置)

        // 确保手机号存在
        guard let phone = query["phone"] as? String else {
            throw PhoneLoginError.missingParameter("phone")
        }

        // 设置请求的 Cookie
        var requestCookies: [String: String] = (query["cookie"] as? [String: String]) ?? [:]
        requestCookies["os"] = "ios"
        requestCookies["appver"] = "8.7.01"

        // 获取国家区号，默认为 "86"
        let countryCode = (query["countrycode"] as? String) ?? "86"
        // 获取验证码
        let captcha = query["captcha"] as? String

        // 构建 POST 请求体数据
        var postData: [String: Any] = [
            "phone": phone,
            "countrycode": countryCode,
            "rememberLogin": "true"
        ]

        // 根据是验证码登录还是密码登录来添加对应的参数
        if let captchaValue = captcha {
            // 如果提供了验证码，则为验证码登录
            postData["captcha"] = captchaValue
        } else {
            // 如果没有提供验证码，则为密码登录
            guard let password = query["password"] as? String else {
                throw PhoneLoginError.missingParameter("缺少密码或验证码进行登录")
            }
            let md5Password: String
            if let existingMd5Password = query["md5_password"] as? String {
                md5Password = existingMd5Password
            } else {
                // 使用 CryptoKit 进行 MD5 加密
                let passwordData = Data(password.utf8)
                md5Password = Insecure.MD5.hash(data: passwordData).map { String(format: "%02hhx", $0) }.joined()
            }
            postData["password"] = md5Password // 用于密码登录
        }

        // --- 重要：WEAPI 加密步骤 ---
        // 在这里使用 'weapi' 算法加密整个 postData 字典。
        // URLRequest 的 `httpBody` 将是加密后的结果。
        let encryptedData = try encryptWeapiData(data: postData)

        // 构建 URLRequest
        guard let url = URL(string: "https://music.163.com/weapi/login/cellphone") else {
            throw PhoneLoginError.invalidURL
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

        // 设置 User-Agent (模拟原始代码中的 ua: 'pc')
        urlRequest.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36", forHTTPHeaderField: "User-Agent")

        // --- 模拟原始的 `request` 函数调用 ---
        // 使用 withCheckedThrowingContinuation 将基于 completionHandler 的 URLSession 转换为 async/await
        return try await withCheckedThrowingContinuation { continuation in
            request(urlRequest) { result in
                switch result {
                case .success(let data):
                    do {
                        // 解析 JSON 响应
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            throw PhoneLoginError.invalidResponse("无法将响应解析为 JSON")
                        }

                        if let code = json["code"] as? Int {
                            if code == 200 {
                                // 原始代码会从 result.cookie 中获取并拼接 cookie 字符串
                                // 在真实的 URLSession 设置中，你需要从 HTTPURLResponse 的 'Set-Cookie' 头部解析
                                var finalBody = json
                                // Cookie 处理占位符，类似于邮箱登录。
                                // 如果需要，这里需要你根据实际的网络请求库/方法来获取并处理 Cookie。

                                continuation.resume(returning: [
                                    "status": 200,
                                    "body": finalBody,
                                    // "cookie": "...", // 拼接后的 cookie 字符串占位符
                                ])
                                return
                            }
                        }
                        // 对于任何其他状态码或一般性失败，直接返回 body
                        continuation.resume(returning: ["status": 200, "body": json])

                    } catch {
                        continuation.resume(throwing: PhoneLoginError.jsonParsingFailed(error))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }


// --- 自定义错误定义 ---
    enum PhoneLoginError: Error, LocalizedError {
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
// 在实际应用中，你会使用 URLSession.shared.data(for: urlRequest) 或类似的异步 API
    func performRequest(urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        completion(.failure(PhoneLoginError.networkError(error)))
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.failure(PhoneLoginError.invalidResponse("非 HTTP 响应")))
                        return
                    }
                    // 网易云 API 即使在逻辑错误时也常返回 200，实际错误码在 body.code 中
                    // 因此，这里不对 HTTP 状态码进行严格的 2xx 检查作为主要错误判断。

                    guard let data = data else {
                        completion(.failure(PhoneLoginError.invalidResponse("没有接收到数据")))
                        return
                    }
                    completion(.success(data))
                }.resume()
    }

}


// --- 如何调用这个函数 (在异步上下文中调用示例) ---
/*
// 在一个异步上下文（例如 View Controller 的 viewDidLoad 或一个异步方法中）
Task {
    do {
        let query: [String: Any] = [
            "phone": "13800138000",
            "countrycode": "86", // 可选，默认为 "86"
            "password": "yourpassword", // 请使用密码 或 验证码，两者选其一
            // "captcha": "123456", // 请使用验证码 或 密码，两者选其一
            "cookie": ["NMTID": "some_id"] // 示例 Cookie
        ]

        // 调用 phoneLogin 函数，并传入 performRequest 闭包
        let result = try await phoneLogin(query: query, request: performRequest)

        print("登录结果:", result)
        if let body = result["body"] as? [String: Any], let code = body["code"] as? Int {
            if code == 200 {
                print("手机号登录成功！")
            } else {
                print("手机号登录失败，错误码：\(code)")
            }
        }

    } catch {
        print("手机号登录过程中发生错误: \(error.localizedDescription)")
    }
}
*/

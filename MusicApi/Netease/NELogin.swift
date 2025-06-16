//
// Created by bemly on 2025/6/17.
//

import Foundation
import CryptoKit // For MD5 hashing on iOS 13+ / macOS 10.15+

public class NELogin {
    public init() {}

    // 定义可能发生的错误
    enum EmailLoginError: Error, LocalizedError {
        case missingParameter(String)
        case invalidURL
        case networkError(Error)
        case invalidResponse(String)
        case jsonParsingFailed(Error)

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
            }
        }
    }

    // 定义一个异步函数来模拟原始的 module.exports
    func emailLogin(query: [String: Any], request: @escaping (URLRequest, @escaping (Result<Data, Error>) -> Void) -> Void) async throws -> [String: Any] {

        // 假设 query 中包含以下键：
        // - "email": String (邮箱)
        // - "password": String (原始密码)
        // - "md5_password": String? (可选，已MD5加密的密码)
        // - "cookie": [String: String]? (可选，Cookie字典)
        // - "proxy": String? (可选，代理地址 - 本示例不实现代理设置)
        // - "realIP": String? (可选，真实IP - 本示例不实现设置)

        guard let email = query["email"] as? String else {
            throw EmailLoginError.missingParameter("email")
        }
        guard let password = query["password"] as? String else {
            throw EmailLoginError.missingParameter("password")
        }

        var requestCookies: [String: String] = (query["cookie"] as? [String: String]) ?? [:]
        requestCookies["os"] = "ios"
        requestCookies["appver"] = "8.7.01"

        let md5Password: String
        if let existingMd5Password = query["md5_password"] as? String {
            md5Password = existingMd5Password
        } else {
            // 使用 CryptoKit 进行 MD5 加密
            let passwordData = Data(password.utf8)
            md5Password = Insecure.MD5.hash(data: passwordData).map { String(format: "%02hhx", $0) }.joined()
        }

        // 构建请求体数据
        let postData: [String: String] = [
            "username": email,
            "password": md5Password,
            "rememberLogin": "true"
        ]

        // 将字典转换为 URL 编码的字符串作为 POST 请求体
        let postString = postData.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }.joined(separator: "&")
        let postBody = postString.data(using: .utf8)

        // 构建 URLRequest
        guard let url = URL(string: "https://music.163.com/api/login") else {
            throw EmailLoginError.invalidURL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postBody
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // 设置 Cookie Header
        let cookieString = requestCookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
        if !cookieString.isEmpty {
            urlRequest.setValue(cookieString, forHTTPHeaderField: "Cookie")
        }

        // 设置 User-Agent (模拟原始代码中的 ua: 'pc')
        urlRequest.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36", forHTTPHeaderField: "User-Agent")


        // -- 模拟原始的 request 函数调用 --
        // 原始的 request 函数接收了 'crypto: 'weapi'' 和 'ua: 'pc'' 这些额外参数
        // 在 URLSession 中，这些需要手动设置。特别是 'weapi' 加密，需要额外的实现。
        // 这里我们假设 'weapi' 加密是在你的 'request' 闭包内部处理的，
        // 或者不是针对请求体而是针对某些特定参数，并且此处的 postBody 是未加密的原始数据。

        return try await withCheckedThrowingContinuation { continuation in
            request(urlRequest) { result in
                switch result {
                case .success(let data):
                    do {
                        // 解析 JSON 响应
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            throw EmailLoginError.invalidResponse("无法将响应解析为 JSON")
                        }

                        if let code = json["code"] as? Int {
                            if code == 502 {
                                continuation.resume(returning: [
                                    "status": 200, // 注意，原始代码这里返回 200，但 body.code 是 502
                                    "body": [
                                        "msg": "账号或密码错误",
                                        "code": 502,
                                        "message": "账号或密码错误"
                                    ]
                                ])
                                return
                            } else if code == 200 {
                                // 从 URLSession 获取响应头中的 Cookie
                                var receivedCookies: [String] = []
                                // 注意：从 URLResponse 中获取 Set-Cookie header 需要访问 URLResponse 对象
                                // 在这个模拟的 request 闭包中，我们只收到 Data，所以需要假设 request 闭包会处理 Cookie
                                // 如果你的实际 request 闭包会返回 URLResponse，则可以从 response.allHeaderFields 中获取 "Set-Cookie"
                                // 为了模拟原始代码，我们假设 request 闭包已经将 cookie 从响应头中提取并传递过来

                                // 这里只是一个占位符，模拟原始代码的 cookie 处理
                                // 实际应用中，你需要从 URLResponse 的 Header Fields 中解析 'Set-Cookie'
                                // 例如： if let httpResponse = response as? HTTPURLResponse, let cookieHeader = httpResponse.allHeaderFields["Set-Cookie"] as? String { ... }

                                // 假设 request 闭包能够返回或处理原始的 result.cookie
                                // 比如，让 request 闭包返回 (Result<(Data, [String]), Error>)
                                // 在本例中，我们无法直接获取，因此直接将 body 传递下去，cookie 部分需要自行调整

                                var finalBody = json
                                // 假设这里可以获取到 result.cookie，这取决于你的 request 闭包如何定义
                                // 为了简化，我们暂时不处理 result.cookie.join(';') 的部分，因为它需要访问实际的 HTTPURLResponse
                                // 如果你需要，这里需要你根据实际的网络请求库/方法来获取并处理 Cookie

                                continuation.resume(returning: [
                                    "status": 200,
                                    "body": finalBody,
                                    // "cookie": "...", // 原始代码的 cookie 字符串，需要从实际响应中解析
                                ])
                                return
                            }
                        }
                        // 其他情况直接返回原始 body
                        continuation.resume(returning: ["status": 200, "body": json])

                    } catch {
                        continuation.resume(throwing: EmailLoginError.jsonParsingFailed(error))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // -- 模拟一个简单的 Swift 请求函数 (替代原始代码中的 `request`) --
    // 在实际应用中，你会使用 URLSession.shared.data(for: urlRequest) 或类似的异步 API
    func performRequest(urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        completion(.failure(EmailLoginError.networkError(error)))
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.failure(EmailLoginError.invalidResponse("非 HTTP 响应")))
                        return
                    }
                    guard (200...299).contains(httpResponse.statusCode) else {
                        // 这里你可以根据 httpResponse.statusCode 进行更细致的错误处理
                        // 但为了模拟原始代码，我们主要关注 body.code
                        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                            print("HTTP Status Code: \(httpResponse.statusCode), Response Body: \(jsonString)")
                        }
                        completion(.failure(EmailLoginError.networkError(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))))
                        return
                    }
                    guard let data = data else {
                        completion(.failure(EmailLoginError.invalidResponse("没有接收到数据")))
                        return
                    }
                    completion(.success(data))
                }.resume()
    }

}



// --- 如何调用这个函数 ---
/*
// 在一个异步上下文（例如 View Controller 的 viewDidLoad 或一个异步方法中）
Task {
    do {
        let query: [String: Any] = [
            "email": "test@example.com",
            "password": "yourpassword", // 原始密码
            // "md5_password": "already_hashed_password", // 如果已经有 MD5 密码
            "cookie": ["NMTID": "some_id", "MUSIC_U": "some_token"] // 示例 Cookie
        ]

        // 调用 emailLogin 函数，并传入你的 request 闭包
        let result = try await emailLogin(query: query, request: performRequest)

        print("登录结果:", result)
        if let body = result["body"] as? [String: Any], let code = body["code"] as? Int {
            if code == 200 {
                print("登录成功！")
            } else {
                print("登录失败，错误码：\(code)")
            }
        }

    } catch {
        print("登录过程中发生错误: \(error.localizedDescription)")
    }
}
*/
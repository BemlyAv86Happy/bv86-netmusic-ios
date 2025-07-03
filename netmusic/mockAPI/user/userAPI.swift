//
// Created by 0xav10086 on 2025/7/3.
//

// userAPI.swift
// 位于 mockAPI/user/

import Foundation

protocol UserAPIService {
    func getUserDetail() async throws -> UserInfoData
    // ... 其他用户相关 API
}

struct MockUserService: UserAPIService {
    func getUserDetail() async throws -> UserInfoData {
        print("--- Mock: getUserDetail ---")
        try await Task.sleep(nanoseconds: 500_000_000)
        return UserInfoData(userName: "MockUserDetail", userInfo: "Mock详细信息")
    }
}

// struct RealUserService: UserAPIService {
//     func getUserDetail() async throws -> UserInfoData { /* ... */ }
// }
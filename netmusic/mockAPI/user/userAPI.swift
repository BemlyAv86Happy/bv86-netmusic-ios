//
// Created by 0xav10086 on 2025/7/3.
//

// userAPI.swift
// 位于 mockAPI/user/

import Foundation
import SwiftUI // Required for URL usage in UserInfoData for AsyncImage preview

protocol UserAPIService {
    func getUserDetail(userId: Int) async throws -> UserInfoData
}

struct MockUserService: UserAPIService {
    func getUserDetail(userId: Int) async throws -> UserInfoData {
        print("--- Mock: getUserDetail for user \(userId) ---")
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay

        // Return mock data consistent with the new UserInfoData struct
        return UserInfoData(
            userName: "蜂群789号",
            avatarUrl: URL(string: "https://picsum.photos/80/80?random=1"),
            backgroundUrl: URL(string: "https://picsum.photos/600/200?random=2"),
            followers: 12345,
            follows: 678,
            signature: "Building awesome apps with SwiftUI! This is a test signature to see how it wraps.",
            level: 10        )
    }
}

// struct RealUserService: UserAPIService {
//     func getUserDetail(userId: Int) async throws -> UserInfoData { /* ... */ }
// }
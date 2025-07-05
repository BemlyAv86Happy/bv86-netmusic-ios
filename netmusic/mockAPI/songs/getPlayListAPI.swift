//
// Created by 0xav10086 on 2025/7/5.
//

import Foundation

func getUserPlayList(userID: Int) async throws -> [PlaylistItem] {
    print("Getting user playlists for user \(userID)")
    try await Task.sleep(nanoseconds: 700_000_000) // Simulate network delay

    return [
        PlaylistItem(id: 1, name: "My Favorite Songs Vol. 1", coverImgUrl: URL(string: "https://picsum.photos/200/200?random=3"), playCount: 15678, trackCount: 30),
        PlaylistItem(id: 2, name: "Chill Vibes Playlist", coverImgUrl: URL(string: "https://picsum.photos/200/200?random=4"), playCount: 8765, trackCount: 25),
        PlaylistItem(id: 3, name: "Workout Jams", coverImgUrl: URL(string: "https://picsum.photos/200/200?random=5"), playCount: 23456, trackCount: 45),
        PlaylistItem(id: 4, name: "Study Focus", coverImgUrl: URL(string: "https://picsum.photos/200/200?random=6"), playCount: 4567, trackCount: 20),
        PlaylistItem(id: 5, name: "Relaxing Instrumentals", coverImgUrl: URL(string: "https://picsum.photos/200/200?random=7"), playCount: 9876, trackCount: 18),
        PlaylistItem(id: 6, name: "Morning Coffee", coverImgUrl: URL(string: "https://picsum.photos/200/200?random=8"), playCount: 11223, trackCount: 35),
        PlaylistItem(id: 7, name: "Evening Drive", coverImgUrl: URL(string: "https://picsum.photos/200/200?random=9"), playCount: 5432, trackCount: 22),
        PlaylistItem(id: 8, name: "Party Mix", coverImgUrl: URL(string: "https://picsum.photos/200/200?random=10"), playCount: 34567, trackCount: 50),
    ]
}
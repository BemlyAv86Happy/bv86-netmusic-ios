//
// Created by 0xav10086 on 2025/7/2.
//

import SwiftUI

//struct userMainView: View {
////    var body: some View {
////        Text("userMainView!")
////    }
//    @EnvironmentObject var authManager: AuthenticationManager // 注入认证管理器
//
//    var body: some View {
//        VStack {
//            HStack {
//                // 左上角跳过登录按钮
//                Button("退出登录") {
//                    authManager.logout()
//                }
//                .padding()
//                Spacer() // 将按钮推到左边
//            }
//
//            Spacer() // 将内容垂直居中
//        }
//    }
//}
struct UserProfile: Identifiable, Codable {
    let id = UUID() // For Identifiable conformance, not from API
    var nickname: String
    var avatarUrl: URL?
    var backgroundUrl: URL?
    var followeds: Int // Followers
    var follows: Int // Following
    var signature: String?
    var userType: Int? // Used for isArtist
    var accountType: Int? // Used for isArtist
}

struct UserDetail: Identifiable, Codable {
    let id = UUID() // For Identifiable conformance, not from API
    var profile: UserProfile
    var level: Int
}

struct PlaylistItem: Identifiable, Codable {
    let id: Int // Assuming ID from API
    var name: String
    var coverImgUrl: URL?
    var playCount: Int
    var trackCount: Int
}

// MARK: - userMainView

struct userMainView: View {
    @State private var userDetail: UserDetail? = nil
    @State private var playList: [PlaylistItem] = []
    @State private var loading: Bool = true
    @State private var errorMessage: String? = nil

    // Replace with your actual ImageLoader or similar utility
    // For demonstration, a simple async image loader helper
    private func getImgUrl(_ url: URL?, _ size: String? = nil) -> URL? {
        // You might append size parameters here for actual image service
        url
    }

    // Replace with your actual localization setup
    private func t(_ key: String, args: [String: Any]? = nil) -> String {
        // Simplified translation logic for demonstration
        switch key {
        case "user.detail.artist": return "Artist"
        case "user.profile.followers": return "Followers"
        case "user.profile.following": return "Following"
        case "user.profile.level": return "Level"
        case "user.detail.noSignature": return "No signature"
        case "user.detail.playlists": return "Playlists"
        case "user.detail.noPlaylists": return "No playlists found."
        case "user.playlist.trackCount": return "Songs: \(args?["count"] as? Int ?? 0)"
        case "user.message.loadFailed": return "Failed to load user data."
        case "user.detail.invalidUserId": return "Invalid User ID."
        case "user.message.loadBasicInfoFailed": return "Failed to load basic user information."
        default: return key
        }
    }

    // Simplified formatNumber for demonstration
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private func isArtist(profile: UserProfile) -> Bool {
        profile.userType == 4 || profile.userType == 2 || profile.accountType == 2
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) { // Replaces n-scrollbar
                VStack(alignment: .leading, spacing: 16) {
                    if loading {
                        ProgressView("Loading user data...") // v-loading equivalent
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if let userDetail = userDetail {
                        // MARK: - User Info Section
                        userInfoSection(userDetail: userDetail)
                            .padding(.bottom, 8) // Equivalent to mb-4 adjusted for SwiftUI spacing

                        // MARK: - N-Tabs Equivalent (Simplified)
                        // For tabs, you'd typically use a Picker or a custom tab view.
                        // Here, we'll just show the playlist section directly as it's the only one required.
                        // If you need actual tabs, you'll need more complex logic (e.g., using a @State variable to control selected tab).

                        // Playlist List
                        VStack(alignment: .leading) {
                            Text(t("user.detail.playlists"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            if playList.isEmpty {
                                Text(t("user.detail.noPlaylists"))
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                playlistGrid(playList: playList)
                                    .padding(.horizontal) // Apply padding to the grid itself
                            }
                        }
                    } else if errorMessage != nil {
                        Text(errorMessage ?? t("user.message.loadFailed"))
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // Bottom padding (pb-20)
                    Spacer()
                        .frame(height: 80) // Equivalent to pb-20 (padding-bottom 80px)
                }
                .padding(.trailing, 16) // pr-4
                .padding(.bottom, 16) // pb-4, part of content-wrapper
            }
            .navigationTitle("") // Hide default navigation title
            .navigationBarHidden(true) // Hide navigation bar completely if desired
            .onAppear(perform: loadUserData) // onMounted equivalent
            .onChange(of: 0) { _ in // Placeholder for route.params.uid watch. Actual implementation depends on your routing.
                // In a real app, you'd pass userId as an @State or @Binding and use onChange on it.
                // For a simple view, onAppear is usually sufficient if the view is recreated for different users.
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func userInfoSection(userDetail: UserDetail) -> some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                // Background Image
                if let backgroundUrl = getImgUrl(userDetail.profile.backgroundUrl) {
                    AsyncImage(url: backgroundUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                        case .failure:
                            Color.gray // Placeholder for error
                                .frame(height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Color.gray // Default background if no URL
                        .frame(height: 200)
                }

                // Overlay for opacity
                Color.black.opacity(0.4)
                    .frame(height: 200)

                // User Info Content
                HStack(alignment: .center) {
                    // Avatar
                    if let avatarUrl = getImgUrl(userDetail.profile.avatarUrl, "80y80") {
                        AsyncImage(url: avatarUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle.fill") // Placeholder for error
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    }

                    // User Info Detail
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center) {
                            Text(userDetail.profile.nickname)
                                .font(.title) // text-xl -> .title, font-bold
                                .fontWeight(.bold)

                            if isArtist(profile: userDetail.profile) {
                                Image(systemName: "checkmark.seal.fill") // ri-verified-badge-fill
                                    .foregroundColor(.blue) // artist-icon
                                    .font(.title3)
                                    .tooltip(t("user.detail.artist")) // Custom tooltip modifier needed for actual tooltip functionality on iOS 15
                            }
                        }

                        HStack(spacing: 24) { // user-info-stats, mr-6 -> 24 spacing
                            userInfoStatItem(label: "\(userDetail.profile.followeds)", text: t("user.profile.followers")) {
                                showFollowerList()
                            }
                            userInfoStatItem(label: "\(userDetail.profile.follows)", text: t("user.profile.following")) {
                                showFollowList()
                            }
                            userInfoStatItem(label: "\(userDetail.level)", text: t("user.profile.level"))
                        }
                        .padding(.top, 4) // mt-2

                        Text(userDetail.profile.signature ?? t("user.detail.noSignature"))
                            .font(.footnote) // text-sm
                            .foregroundColor(.white.opacity(0.8)) // text-gray-200
                            .lineLimit(2) // line-clamp-2
                            .padding(.top, 4) // mt-2
                    }
                    .foregroundColor(.white)
                    .padding(.leading, 16) // ml-4
                }
                .padding(24) // p-6
            }
            .frame(height: 200) // Explicit height for the ZStack
            .cornerRadius(12) // rounded-xl
            .clipped() // overflow-hidden
        }
        .padding(.horizontal) // Adds horizontal padding to the section
        // Note: For animate__fadeInDown, you'd integrate a custom animation logic,
        // potentially using .onAppear and .animation modifiers with .opacity or .offset.
    }

    @ViewBuilder
    private func userInfoStatItem(label: String, text: String, action: (() -> Void)? = nil) -> some View {
        Button(action: { action?() }) {
            VStack {
                Text(label)
                    .font(.headline) // text-lg, font-bold
                    .fontWeight(.bold)
                Text(text)
                    .font(.caption) // Default font size for label
            }
            .padding(.horizontal, 8) // px-2
            .padding(.vertical, 4) // Adjust vertical padding
            .background(
                RoundedRectangle(cornerRadius: 8) // rounded-lg
                    .fill(Color.black.opacity(0.0)) // Initial transparent background
            )
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling
        .hoverEffect(.highlight) // iOS 15+ for hover effect on iPad/macOS, mimics hover:bg-black hover:bg-opacity-20
        .onHover { isHovering in
            // Manual hover effect for touch devices or more control
            // You might use a @State to change background color here
        }
    }

    @ViewBuilder
    private func playlistGrid(playList: [PlaylistItem]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) { // grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap-4
            ForEach(playList) { item in
                playlistItemView(item: item)
                    .onTapGesture {
                        openPlaylist(item: item)
                    }
            }
        }
        .padding(.vertical, 8) // py-4
        // For animate__fadeInUp, similar animation logic as above
    }

    @ViewBuilder
    private func playlistItemView(item: PlaylistItem) -> some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                // Cover Image
                if let coverUrl = getImgUrl(item.coverImgUrl, "200y200") {
                    AsyncImage(url: coverUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .aspectRatio(1, contentMode: .fit)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12)) // rounded-xl
                        case .failure:
                            Color.gray // Placeholder for error
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Color.gray // Default if no URL
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Play Count
                HStack(spacing: 2) {
                    Image(systemName: "play.fill") // ri-play-fill
                    Text(formatNumber(item.playCount))
                }
                .font(.caption) // text-xs
                .foregroundColor(.white)
                .padding(.horizontal, 8) // px-2
                .padding(.vertical, 4) // py-1
                .background(Capsule().fill(Color.black.opacity(0.5))) // rounded-full, bg-black bg-opacity-50
                .padding([.top, .trailing], 8) // top-2, right-2
            }

            // Playlist Info
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.subheadline) // text-sm
                    .fontWeight(.medium)
                    .foregroundColor(Color(uiColor: .label)) // text-gray-900 dark:text-white
                    .lineLimit(2) // line-clamp-2

                Text(t("user.playlist.trackCount", args: ["count": item.trackCount]))
                    .font(.caption2) // text-xs
                    .foregroundColor(Color(uiColor: .secondaryLabel)) // text-gray-500 dark:text-gray-400
                    .padding(.top, 2) // mt-1
            }
            .padding(.horizontal, 4) // px-1
            .padding(.top, 8) // mt-2
        }
        .background(Color(uiColor: .systemBackground)) // Consider using a custom background color if not system default
        .cornerRadius(12) // rounded-xl
        .shadow(radius: 2) // Optional: Add a subtle shadow if desired
        .onHover { isHovering in
            // Custom hover effect for scale-105
            // Requires a @State variable and .scaleEffect modifier
        }
        .animation(.easeOut(duration: 0.2), value: 0) // transition-all duration-200, placeholder
    }

    // MARK: - API Calls (Placeholders)

    private func loadUserData() {
        loading = true
        errorMessage = nil
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

                // 1. getUserDetail & getUserPlaylist
                let userDetailRes = try await getUserDetail(userId: 123) // Placeholder user ID
                let playlistRes = try await getUserPlaylist(userId: 123)

                await MainActor.run {
                    self.userDetail = userDetailRes
                    self.playList = playlistRes
                }
            } catch {
                await MainActor.run {
                    print("Error loading user data: \(error)")
                    errorMessage = t("user.message.loadFailed")
                    // Specific error handling for user.message.loadBasicInfoFailed if needed
                }
            }
            await MainActor.run {
                loading = false
            }
        }
    }

    // Function to simulate getUserDetail API call
    func getUserDetail(userId: Int) async throws -> UserDetail {
        // Replace with your actual network request to fetch user details
        // Example mock data:
        return UserDetail(
            profile: UserProfile(
                nickname: "SwiftUI User",
                avatarUrl: URL(string: "https://picsum.photos/80/80?random=1"),
                backgroundUrl: URL(string: "https://picsum.photos/600/200?random=2"),
                followeds: 12345,
                follows: 678,
                signature: "Building awesome apps with SwiftUI! This is a test signature to see how it wraps.",
                userType: 1, // Not an artist
                accountType: 1
            ),
            level: 10
        )
    }

    // Function to simulate getUserPlaylist API call
    func getUserPlaylist(userId: Int) async throws -> [PlaylistItem] {
        // Replace with your actual network request to fetch user playlists
        // Example mock data:
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

    // MARK: - Navigation/Action Placeholders

    private func showFollowList() {
        print("Navigate to Follow List for user \(userDetail?.profile.nickname ?? "N/A")")
        // In a real app, you would use NavigationLink or a programmatic navigation approach.
        // e.g., router.push({ path: `/user/follows`, query: { uid: userId.value.toString(), name: userDetail.value.profile.nickname } });
    }

    private func showFollowerList() {
        print("Navigate to Follower List for user \(userDetail?.profile.nickname ?? "N/A")")
        // e.g., router.push({ path: `/user/followers`, query: { uid: userId.value.toString(), name: userDetail.value.profile.nickname } });
    }

    private func openPlaylist(item: PlaylistItem) {
        print("Open playlist: \(item.name)")
        // Simulate getListDetail and navigation
        Task {
            do {
                // Simulate getListDetail API call
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                print("Navigating to music list for playlist: \(item.name) with ID: \(item.id)")
                // navigateToMusicList(router, { ... });
            } catch {
                print("Failed to get list detail: \(error)")
            }
        }
    }
}


// MARK: - Tooltip Modifier for iOS 15 (Basic Example)
// SwiftUI has a built-in .popover() for iOS 15+, but a custom tooltip might be closer to Vue's NTooltip.
// For a simple text tooltip, .help() modifier is available on iOS 15+ for macOS/iPadOS, but not iPhone.
// A custom modifier is needed for a consistent look across platforms or more complex content.

extension View {
    func tooltip(_ text: String) -> some View {
        self.modifier(TooltipModifier(text: text))
    }
}
struct TooltipModifier: ViewModifier {
    let text: String

    @State private var showTooltip: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if showTooltip {
                        Text(text)
                            .font(.caption2)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.secondary.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                            .offset(y: -30) // Position above the content
                            .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: showTooltip)
                , alignment: .top
            )
            // Simulating hover for iOS touch - typically needs a long press gesture or explicit trigger
            // For macOS/iPadOS, .onHover is available
            .onLongPressGesture(minimumDuration: 0.5) {
                showTooltip = true
            } onPressingChanged: { pressing in
                if !pressing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showTooltip = false
                    }
                }
            }
    }
}
struct userMainView_Previews: PreviewProvider {
    static var previews: some View  {
        userMainView()
    }
}
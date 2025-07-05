//
//  userMainView.swift
//  netmusic
//
//  Created by 0xav10086 on 2025/7/2.
//

import SwiftUI

// MARK: - userMainView

struct userMainView: View {
    @State private var userDetail: UserInfoData? = nil
    @State private var playList: [PlaylistItem] = []
    @State private var loading: Bool = true
    @State private var errorMessage: String? = nil

    // Instantiate your mock API service
    private let userService: UserAPIService = MockUserService()

    // Environment object for localization
    @EnvironmentObject var localizationManager: LocalizationManager

    private func getImgUrl(_ url: URL?, _ size: String? = nil) -> URL? {
        // You might append size parameters here for actual image service
        url
    }

    private func t(_ key: String, args: [String: Any]? = nil) -> String {
        return localizationManager.bundle.localizedString(forKey: key, value: "", table: nil)
    }

    // Simplified formatNumber for demonstration
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    if loading {
                        ProgressView(t("user.mainView.loadData")) // Localized loading message
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if let userDetail = userDetail {
                        // MARK: - User Info Section (Top 1/4)
                        userInfoSection(userDetail: userDetail)
                            .padding(.bottom, 8)

                        // MARK: - Playlist List Section (Remaining 3/4)
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
                                playlistListView(playList: playList) // Changed to list view
                                    .padding(.horizontal)
                            }
                        }
                    } else if errorMessage != nil {
                        Text(errorMessage ?? t("user.message.loadFailed"))
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Spacer()
                        .frame(height: 80)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear(perform: loadUserData)
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func userInfoSection(userDetail: UserInfoData) -> some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                if let backgroundUrl = getImgUrl(userDetail.backgroundUrl) {
                    AsyncImage(url: backgroundUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .clipped()
                        case .failure:
                            Color.gray
                                .frame(height: 100)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Color.gray
                        .frame(height: 100)
                }

                Color.black.opacity(0.4)
                    .frame(height: 100)

                HStack(alignment: .center) {
                    if let avatarUrl = getImgUrl(userDetail.avatarUrl, "80y80") {
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
                                Image(systemName: "person.circle.fill")
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

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center) {
                            Text(userDetail.userName)
                                .font(.title)
                                .fontWeight(.bold)

                            // Removed isArtist check and related UI elements here
                        }

                        HStack(spacing: 24) {
                            userInfoStatItem(label: "\(formatNumber(userDetail.followers))", text: t("user.profile.followers")) {
                                showFollowerList()
                            }
                            userInfoStatItem(label: "\(formatNumber(userDetail.follows))", text: t("user.profile.following")) {
                                showFollowList()
                            }
                            userInfoStatItem(label: "\(userDetail.level)", text: t("user.profile.level"))
                        }
                        .padding(.top, 4)

                        Text(userDetail.signature ?? t("user.detail.noSignature"))
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                            .padding(.top, 4)
                    }
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                }
                .padding(24)
            }
            .frame(height: 100) // Fixed height for user info section
            .cornerRadius(12)
            .clipped()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func userInfoStatItem(label: String, text: String, action: (() -> Void)? = nil) -> some View {
        Button(action: { action?() }) {
            VStack {
                Text(label)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(text)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.0))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .hoverEffect(.highlight)
        .onHover { isHovering in }
        .animation(.easeOut(duration: 0.2), value: 0)
    }

    // New Playlist List View (single column)
    @ViewBuilder
    private func playlistListView(playList: [PlaylistItem]) -> some View {
        LazyVStack(spacing: 12) { // Changed to LazyVStack for single column
            ForEach(playList) { item in
                playlistItemView(item: item)
                    .onTapGesture {
                        openPlaylist(item: item)
                    }
            }
        }
        .padding(.vertical, 8)
    }

    // Modified Playlist Item View for list row
    @ViewBuilder
    private func playlistItemView(item: PlaylistItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Cover Image
            if let coverUrl = getImgUrl(item.coverImgUrl, "60y60") { // Smaller size for list
                AsyncImage(url: coverUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8)) // Slightly smaller radius
                    case .failure:
                        Color.gray
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Color.gray
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Playlist Info (Name and Track Count)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(uiColor: .label))
                    .lineLimit(1) // Limit to one line for list items

                Text(t("user.playlist.trackCount", args: ["count": item.trackCount]))
                    .font(.caption2)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }

            Spacer() // Pushes play count to the right

            // Play Count
            HStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.caption)
                Text(formatNumber(item.playCount))
                    .font(.caption)
            }
            .foregroundColor(Color(uiColor: .secondaryLabel)) // Consistent color
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1) // Lighter shadow for list items
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes full available width
        .hoverEffect(.highlight)
        .animation(.easeOut(duration: 0.2), value: 0)
    }

    // MARK: - API Calls (Integration)

    private func loadUserData() {
        loading = true
        errorMessage = nil
        Task {
            do {
                let userDetailRes = try await userService.getUserDetail(userId: 123)
                let playlistRes = try await getUserPlayList(userID: 123)

                await MainActor.run {
                    self.userDetail = userDetailRes
                    self.playList = playlistRes
                }
            } catch {
                await MainActor.run {
                    print("Error loading user data: \(error)")
                    errorMessage = t("user.message.loadFailed") // Localized error message
                }
            }
            await MainActor.run {
                loading = false
            }
        }
    }

    // MARK: - Navigation/Action Placeholders

    private func showFollowList() {
        print("Navigate to Follow List for user \(userDetail?.userName ?? "N/A")")
    }

    private func showFollowerList() {
        print("Navigate to Follower List for user \(userDetail?.userName ?? "N/A")")
    }

    private func openPlaylist(item: PlaylistItem) {
        print("Open playlist: \(item.name)")
        Task {
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
                print("Navigating to music list for playlist: \(item.name) with ID: \(item.id)")
            } catch {
                print("Failed to get list detail: \(error)")
            }
        }
    }
}

// MARK: - Tooltip Modifier for iOS 15 (Basic Example)

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
                            .offset(y: -30)
                            .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: showTooltip)
                , alignment: .top
            )
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

// MARK: - Preview Provider

struct userMainView_Previews: PreviewProvider {
    static var previews: some View {
        userMainView()
            .environmentObject(LocalizationManager())
            // You might need to add other environment objects if your preview relies on them, e.g.,
            // .environmentObject(AuthenticationManager())
    }
}
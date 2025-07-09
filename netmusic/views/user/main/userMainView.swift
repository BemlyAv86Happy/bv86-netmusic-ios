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
//    @State private var scrollOffset: CGFloat = 0 // To track scroll position
//
//    // Initial and minimum heights for the collapsing header
//    private let initialUserInfoHeight: CGFloat = 200 // Original height of user info background
//    private let minCollapsedHeaderHeight: CGFloat = 60 // Height of collapsed header (avatar + name)
//    private let playlistTitleHeight: CGFloat = 60 // Estimated height of "Playlists" title with its padding
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

    // MARK: - Helper Views
    // Calculate the total initial height of the sticky header area (user info + playlists title)
//    private func calculateTotalInitialHeaderHeight() -> CGFloat {
//        // The user info section has an initial background height of 200.
//        // The playlist title has its own estimated height with padding.
//        return initialUserInfoHeight + playlistTitleHeight
//    }
    private func userInfoStatItem(value: String, label: String) -> some View {
        VStack {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    if loading {
                        ProgressView(t("user.mainView.loadData"))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let userDetail = userDetail {
                        CollapsingUserInfoHeader(userDetail: userDetail, getImgUrl: getImgUrl, t: t, formatNumber: formatNumber) // Pass functions
                            .frame(height: 200) // Fixed height for the header
                            .padding(.bottom)

                        if !playList.isEmpty {
                            VStack(alignment: .leading) {
                                Text(t("user.mainView.myPlaylists"))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                    .padding(.top, 10)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(playList) { playlist in
                                        PlaylistItemView(playlist: playlist, getImgUrl: getImgUrl)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        } else {
                            Text(t("user.mainView.noPlaylists"))
                                .foregroundColor(.gray)
                                .padding()
                        }
                    } else if let errorMessage = errorMessage {
                        Text(t("user.mainView.errorLoading") + ": \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .onAppear(perform: loadUserData)
            }
            .navigationTitle(t("user.mainView.profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for settings or other options
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    private func loadUserData() {
        Task {
            loading = true
            errorMessage = nil
            do {
                // For demonstration, let's assume a fixed user ID or retrieve it from authManager
                let userId = 123 // Replace with actual user ID from login
                userDetail = try await userService.getUserDetail(userId: userId)
                playList = try await getUserPlayList(userID: userId)
            } catch {
                errorMessage = error.localizedDescription
                print("Error loading user data: \(error.localizedDescription)")
            }
            loading = false
        }
    }
}


// MARK: - CollapsingUserInfoHeader
// This header is designed to be part of a ScrollView and collapse/expand
struct CollapsingUserInfoHeader: View {
    let userDetail: UserInfoData
    let getImgUrl: (URL?, String?) -> URL? // Passed in
    let t: (String, [String: Any]?) -> String // Passed in
    let formatNumber: (Int) -> String // Passed in

    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let height = max(0, minY + 200) // Adjust 200 based on desired header height
            let progress = 1 - min(1, max(0, minY) / 100) // Adjust 100 for collapse speed

            ZStack(alignment: .bottomLeading) {
                // Background Image
                AsyncImage(url: getImgUrl(userDetail.backgroundUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: height)
                            .clipped()
                            .overlay(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
                    } else if phase.error != nil {
                        Color.gray // Fallback for error
                            .frame(width: geometry.size.width, height: height)
                    } else {
                        ProgressView() // Placeholder during loading
                            .frame(width: geometry.size.width, height: height)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Avatar
                    AsyncImage(url: getImgUrl(userDetail.avatarUrl, "80y80")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 5)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                    }

                    // User Name
                    HStack {
                        Text(userDetail.userName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        // Artist Icon (simplified for demonstration)
                        if userDetail.userType == 4 || userDetail.accountType == 4 { // Assuming 4 is artist type
                            Image(systemName: "music.mic.fill")
                                .foregroundColor(.yellow)
                                .tooltip(t("user.detail.artist"))
                        }
                    }

                    // User Stats
                    HStack(spacing: 20) {
                        // Now calling the function passed as a parameter
                        userInfoStatItem(value: formatNumber(userDetail.followers), label: t("user.profile.followers"))
                        userInfoStatItem(value: formatNumber(userDetail.follows), label: t("user.profile.following"))
                        userInfoStatItem(value: "\(userDetail.level)", label: t("user.profile.level"))
                    }

                    // Signature
                    Text(userDetail.signature ?? t("user.detail.noSignature"))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                .padding()
                .offset(y: max(0, -minY)) // Parallax effect / sticky header
            }
            .frame(height: 200) // Original height
        }
    }

    // Moved userInfoStatItem here to be a member of CollapsingUserInfoHeader
    private func userInfoStatItem(value: String, label: String) -> some View {
        VStack {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - PlaylistItemView

struct PlaylistItemView: View {
    let playlist: PlaylistItem
    let getImgUrl: (URL?, String?) -> URL? // Passed in

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: getImgUrl(playlist.coverImgUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 150)
                            .overlay(Image(systemName: "music.note.list").foregroundColor(.white.opacity(0.6)))
                    }
                }

                HStack(spacing: 2) {
                    Image(systemName: "play.fill")
                        .font(.caption2)
                    Text("\(playlist.playCount)")
                        .font(.caption2)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(5)
                .offset(x: -5, y: 5)
            }

            Text(playlist.name)
                .font(.subheadline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.top, 4)

            Text("\(playlist.trackCount) " + "songs") // You might want to localize "songs"
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 150)
    }
}

// MARK: - TooltipModifier

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
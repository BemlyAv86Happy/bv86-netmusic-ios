// views/home/home.swift

import SwiftUI

struct HomeView: View {
    // No `path` binding needed here since we are only supporting iOS 15
    // and navigation will be primarily handled by TabView's tab selection
    // or direct NavigationLinks if you add them within HomeView.

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {

                ListView() // Your ListView component
                    .frame(height: geometry.size.height * 0.78)
                    .background(Color.yellow.opacity(0.2))
            }
        }
        .navigationTitle(AppRoute.home.title)
    }
}

// MARK: - Preview Provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}


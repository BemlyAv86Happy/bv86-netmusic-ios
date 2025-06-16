// views/home/home.swift

import SwiftUI

struct HomeView: View {
    // This binding now refers to the main navigationPath from netmusicApp.swift
    @Binding var path: NavigationPath
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top section: Search Button/Area (9.5%)
                // Instead of embedding SearchView, this is now a clickable area/button
                // that navigates to SearchView.
                Button {
                    path.append(AppRoute.search) // Programmatic navigation
                } label: {
                    VStack {
                        Image(systemName: AppRoute.search.iconName)
                            .font(.largeTitle)
                        Text(AppRoute.search.title)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Make button fill space
                    .background(Color.blue.opacity(0.2)) // Visual background for the button area
                    .foregroundColor(.primary)
                }
                .frame(height: geometry.size.height * 0.095)
                
                
                Color.black
                    .frame(height: geometry.size.height * 0.005)
                
                // Middle section: ListView (80%)
                // This remains embedded as you described, for displaying API content
                ListView()
                    .frame(height: geometry.size.height * 0.80)
                    .background(Color.yellow.opacity(0.1)) // Placeholder background
                    .overlay(Text("ListView Area (API Content)").foregroundColor(.primary).font(.headline))
                
                // Bottom section: Navigation buttons (9.5%)
                HStack(spacing: 0) {
                    // History/Favorite Button (1/3 width)
                    Button {
                        path.append(AppRoute.historyAndFavorite) // Navigate to HistoryAndFavoriteView
                    } label: {
                        VStack {
                            Image(systemName: AppRoute.historyAndFavorite.iconName)
                                .font(.title2)
                            Text(AppRoute.historyAndFavorite.title)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.primary)
                    }
                    .frame(width: geometry.size.width / 3)
                    
                    Color.gray
                        .frame(width: 1)
                    
                }
            }
            .navigationTitle(AppRoute.home.title)
        }
    }
}

// MARK: - Preview Provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a constant binding for previewing
        HomeView(path: .constant(NavigationPath()))
    }
}

/*
// Placeholder Views for compilation - ensure these exist in your project
struct SearchView: View {
    var body: some View {
        Text("This is the Search Screen")
            .font(.title)
            .navigationTitle(AppRoute.search.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
    }
}

struct ListView: View {
    var body: some View {
        Text("This is the List Screen (API Content)")
            .font(.title)
            .navigationTitle(AppRoute.list.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.mint.opacity(0.1))
    }
}

struct HistoryAndFavoriteView: View {
    var body: some View {
        Text("This is the History & Favorite Screen")
            .font(.title)
            .navigationTitle(AppRoute.historyAndFavorite.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.pink.opacity(0.1))
    }
}

struct UserView: View {
    var body: some View {
        Text("This is the User Screen")
            .font(.title)
            .navigationTitle(AppRoute.user.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.teal.opacity(0.1))
    }
}

struct SettingsView: View {
    var body: some View {
        Text("This is the Settings Screen")
            .font(.title)
            .navigationTitle(AppRoute.settings.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.brown.opacity(0.1))
    }
}
*/

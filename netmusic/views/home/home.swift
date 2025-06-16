// views/home/home.swift

import SwiftUI

struct HomeView: View {
    var body: some View {
        GeometryReader { geometry in
            // The ZStack allows us to place the background color behind other content
            ZStack {
                // Background color occupying the entire screen area
                Color.yellow.opacity(0.3)                  .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Top Spacer to push ListView down
                    Spacer()

                    // ListView component, centered vertically by the Spacers
                    ListView()
                    Spacer()
                }
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

/*
// Placeholder Views for compilation - ensure these are defined in your project, e.g., in their own files
struct ListView: View {
    var body: some View {
        Text("This is the List Screen (API Content Placeholder)")
            .font(.title)
            .navigationTitle(AppRoute.list.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.mint.opacity(0.1))
    }
}
*/

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MusicPlayerViewModel()
    @State private var selectedTrackIndex = 0
    @State private var isPlayerExpanded = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.searchQuery, onSubmit: {
                    Task {
                        await viewModel.searchTracks()
                    }
                })
                .padding(.top, 4)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text(viewModel.searchQuery.isEmpty ? "Trending Tracks" : "Search Results")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        if viewModel.isLoading {
                            // Loading indicator
                            VStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding()
                                Spacer()
                            }
                            .frame(height: 300)
                        } else if let errorMessage = viewModel.errorMessage {
                            // Error message
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.bottom, 8)
                                
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else if viewModel.tracks.isEmpty {
                            // No results
                            VStack {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.bottom, 8)
                                
                                Text("No tracks found")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            // Album carousel
                            if viewModel.tracks.count > 1 {
                                AlbumCarousel(
                                    tracks: viewModel.tracks,
                                    selectedIndex: $selectedTrackIndex,
                                    onTap: { index in
                                        viewModel.playTrack(at: index)
                                    }
                                )
                                .padding(.bottom, 20)
                            }
                            
                            // Track list
                            VStack(alignment: .leading, spacing: 12) {
                                Text(viewModel.searchQuery.isEmpty ? "Popular Tracks" : "All Results")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
                                    SearchResultRow(track: track) {
                                        selectedTrackIndex = index
                                        viewModel.playTrack(at: index)
                                    }
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedTrackIndex == index ? Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.2) : Color.clear)
                                    )
                                }
                            }
                            .padding(.bottom, 100) // Space for mini player
                        }
                    }
                }
                
                Spacer()
            }
            
            // Mini player at bottom
            if viewModel.currentTrack != nil && !isPlayerExpanded {
                MiniPlayer(viewModel: viewModel, onTap: {
                    withAnimation(.spring()) {
                        isPlayerExpanded = true
                    }
                })
                .padding(.horizontal)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom))
            }
            
            // Full player overlay
            if isPlayerExpanded {
                FullPlayerView(viewModel: viewModel, isExpanded: $isPlayerExpanded)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity.combined(with: .move(edge: .bottom))
                    ))
            }
        }
        .onChange(of: viewModel.currentTrack) { newTrack in
            if let newTrack = newTrack, let index = viewModel.tracks.firstIndex(where: { $0.id == newTrack.id }) {
                selectedTrackIndex = index
            }
        }
        .task {
            await viewModel.loadTopTracks()
        }
    }
}

#Preview {
    HomeView()
} 
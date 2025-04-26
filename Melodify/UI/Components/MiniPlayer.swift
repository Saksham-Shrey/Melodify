import SwiftUI

struct MiniPlayer: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    let onTap: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        if let track = viewModel.currentTrack {
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.4, green: 0.2, blue: 0.8),
                                    Color(red: 0.6, green: 0.3, blue: 0.9)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(viewModel.progress), height: 3)
                }
                .frame(height: 3)
                
                // Mini player content
                Button(action: onTap) {
                    HStack(spacing: 12) {
                        // Album art
                        AsyncImage(url: URL(string: track.albumArtURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .scaleEffect(isPlayingAndAnimating ? 1.05 : 1.0)
                                    .shadow(color: Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.3), radius: 6, x: 0, y: 3)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .foregroundColor(.white.opacity(0.5))
                                    )
                            }
                        }
                        
                        // Track info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.title)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text(track.artistName)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Control buttons
                        HStack(spacing: 20) {
                            Button(action: { viewModel.previous() }) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Button(action: { viewModel.togglePlayPause() }) {
                                Image(systemName: playButtonIcon)
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .frame(width: 22)
                            }
                            
                            Button(action: { viewModel.next() }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: -4)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        } else {
            EmptyView()
        }
    }
    
    // Computed properties for play state
    private var isPlayingAndAnimating: Bool {
        if case .playing = viewModel.playbackState, isAnimating {
            return true
        }
        return false
    }
    
    private var playButtonIcon: String {
        if case .playing = viewModel.playbackState {
            return "pause.fill"
        } else {
            return "play.fill"
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [.black, Color(red: 0.1, green: 0.1, blue: 0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            let viewModel = MusicPlayerViewModel()
            MiniPlayer(viewModel: viewModel, onTap: {})
                .padding(.horizontal)
                .padding(.bottom, 8)
                .onAppear {
                    viewModel.playTrack(at: 0)
                }
        }
    }
} 
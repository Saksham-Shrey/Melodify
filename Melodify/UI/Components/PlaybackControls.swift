import SwiftUI

struct PlaybackControls: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    @State private var isEditingSlider = false
    @State private var sliderValue: Float = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            CustomSlider(
                value: $sliderValue,
                isEditing: $isEditingSlider,
                backgroundColor: Color.white.opacity(0.2),
                foregroundColor: Color(red: 0.4, green: 0.2, blue: 0.8),
                thumbColor: .white,
                onEditingChanged: { editing in
                    isEditingSlider = editing
                    if !editing {
                        viewModel.seek(to: sliderValue)
                    }
                }
            )
            .frame(height: 8)
            .padding(.horizontal)
            
            // Time labels
            HStack {
                Text(viewModel.formatTime(viewModel.currentTime))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("-" + viewModel.formatTime(max(0, viewModel.duration - viewModel.currentTime)))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            
            // Track info
            if let track = viewModel.currentTrack {
                VStack(spacing: 4) {
                    Text(track.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("\(track.artistName) • \(track.albumName)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                .padding(.vertical, 8)
            }
            
            // Control buttons
            HStack(spacing: 32) {
                Button(action: { viewModel.toggleShuffle() }) {
                    Image(systemName: viewModel.isShuffleEnabled ? "shuffle.circle.fill" : "shuffle")
                        .font(.system(size: 24))
                        .foregroundColor(viewModel.isShuffleEnabled ? Color(red: 0.4, green: 0.2, blue: 0.8) : .white)
                }
                
                Button(action: { viewModel.previous() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                Button(action: { viewModel.togglePlayPause() }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.2, blue: 0.8),
                                        Color(red: 0.6, green: 0.3, blue: 0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.5), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: viewModelPlayButtonIcon)
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .offset(x: playButtonOffset)
                    }
                }
                
                Button(action: { viewModel.next() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                Button(action: { viewModel.rewind() }) {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .padding(.top, 16)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: -10)
        )
        .onAppear {
            sliderValue = viewModel.progress
        }
        .onChange(of: viewModel.progress) { newValue in
            if !isEditingSlider {
                sliderValue = newValue
            }
        }
    }
    
    // Computed properties for the play/pause button
    private var viewModelPlayButtonIcon: String {
        if case .playing = viewModel.playbackState {
            return "pause.fill"
        } else {
            return "play.fill"
        }
    }
    
    private var playButtonOffset: CGFloat {
        if case .playing = viewModel.playbackState {
            return 0
        } else {
            return 2
        }
    }
}

struct CustomSlider: View {
    @Binding var value: Float
    @Binding var isEditing: Bool
    
    let backgroundColor: Color
    let foregroundColor: Color
    let thumbColor: Color
    
    let onEditingChanged: (Bool) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(backgroundColor)
                    .frame(width: geometry.size.width, height: 6)
                
                // Progress track
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [foregroundColor, foregroundColor.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(value), height: 6)
                
                // Draggable circle
                Circle()
                    .fill(thumbColor)
                    .frame(width: 14, height: 14)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .offset(x: geometry.size.width * CGFloat(value) - 7)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isEditing = true
                                onEditingChanged(true)
                                
                                let newValue = Float(
                                    max(0, min(1, gesture.location.x / geometry.size.width))
                                )
                                value = newValue
                            }
                            .onEnded { _ in
                                isEditing = false
                                onEditingChanged(false)
                            }
                    )
            }
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
            
            PlaybackControls(viewModel: MusicPlayerViewModel())
        }
    }
} 
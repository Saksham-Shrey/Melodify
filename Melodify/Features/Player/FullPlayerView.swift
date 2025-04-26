import SwiftUI

struct FullPlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @Binding var isExpanded: Bool
    
    @State private var dragOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var isRotating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background blur with overlay
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(
                        AsyncImage(url: URL(string: viewModel.currentTrack?.albumArtURL ?? "")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .blur(radius: 40)
                                    .opacity(0.7)
                            } else {
                                Color.black
                            }
                        }
                        .ignoresSafeArea()
                    )
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: 20) {
                    // Header with close button
                    HStack {
                        Button(action: {
                            withAnimation(.spring()) {
                                isExpanded = false
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        
                        Spacer()
                        
                        Text("Now Playing")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // Options button (can be extended for more features)
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(90))
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // 3D Album Art
                    if let track = viewModel.currentTrack {
                        ZStack {
                            // Reflection and shadow
                            AsyncImage(url: URL(string: track.albumArtURL)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .scaleEffect(x: 1, y: -0.2)
                                        .offset(y: 160)
                                        .opacity(0.3)
                                        .blur(radius: 3)
                                        .mask(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                }
                            }
                            .frame(width: 280, height: 50)
                            
                            // Main album art with 3D effect
                            AsyncImage(url: URL(string: track.albumArtURL)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .rotation3DEffect(
                                            .degrees(rotation),
                                            axis: (x: 0, y: 1, z: 0),
                                            perspective: 0.3
                                        )
                                        .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                                        .scaleEffect(scale)
                                        .animation(.spring(), value: scale)
                                        .onAppear {
                                            if case .playing = viewModel.playbackState, !isRotating {
                                                withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                                                    isRotating = true
                                                    rotation = 360
                                                }
                                            }
                                        }
                                        .onChange(of: viewModel.playbackState) { state in
                                            if case .playing = state, !isRotating {
                                                withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                                                    isRotating = true
                                                    rotation = 360
                                                }
                                            } else if case .playing = state {} else {
                                                isRotating = false
                                                withAnimation(.spring()) {
                                                    rotation = 0
                                                }
                                            }
                                        }
                                } else if phase.error != nil {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.3, green: 0.2, blue: 0.5),
                                                    Color(red: 0.5, green: 0.3, blue: 0.7)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            Image(systemName: "music.note")
                                                .foregroundColor(.white.opacity(0.5))
                                                .font(.system(size: 80))
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(1.5)
                                        )
                                }
                            }
                            .frame(width: 280, height: 280)
                        }
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(0.8, min(1.2, value.magnitude))
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                    }
                                }
                        )
                    }
                    
                    Spacer()
                    
                    // Track info
                    if let track = viewModel.currentTrack {
                        VStack(spacing: 5) {
                            Text(track.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .padding(.horizontal)
                            
                            Text("\(track.artistName) • \(track.albumName)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Player controls
                    PlaybackControls(viewModel: viewModel)
                }
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > geometry.size.height * 0.25 {
                                withAnimation(.spring()) {
                                    isExpanded = false
                                }
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        let viewModel = MusicPlayerViewModel()
        FullPlayerView(viewModel: viewModel, isExpanded: .constant(true))
            .onAppear {
                viewModel.playTrack(at: 0)
            }
    }
} 
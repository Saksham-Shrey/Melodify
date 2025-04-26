import SwiftUI

struct AlbumCarousel: View {
    let tracks: [Track]
    @Binding var selectedIndex: Int
    let onTap: (Int) -> Void
    
    @State private var offset: CGFloat = 0
    @State private var dragging = false
    @State private var previousSelectedIndex = 0
    @State private var showScrollIndicator = true
    
    private let spacing: CGFloat = 20
    private let cardWidth: CGFloat = 240
    private let cardHeight: CGFloat = 240
    private let angleMultiplier: Double = 0.05
    private let maxRotation: Double = 45
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Carousel
            GeometryReader { geometry in
                let size = geometry.size
                
                ZStack {
                    // Background gradient
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.1, blue: 0.4).opacity(0.8),
                                    Color(red: 0.1, green: 0.1, blue: 0.3).opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 10)
                    
                    // Carousel
                    ZStack {
                        ForEach(0..<min(tracks.count, 7), id: \.self) { i in
                            let realIndex = (selectedIndex + i - 3 + tracks.count) % tracks.count
                            let track = tracks[realIndex]
                            let offset = CGFloat(i - 3) * (cardWidth + spacing) + self.offset
                            let scale = calculateScale(offset: offset, screenWidth: size.width)
                            let opacity = calculateOpacity(offset: offset, screenWidth: size.width)
                            let angle = calculateAngle(offset: offset, screenWidth: size.width)
                            
                            AlbumCard(track: track, isSelected: realIndex == selectedIndex)
                                .frame(width: cardWidth, height: cardHeight)
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .rotation3DEffect(
                                    .degrees(angle),
                                    axis: (x: 0, y: 1, z: 0),
                                    anchor: .center,
                                    perspective: 0.3
                                )
                                .offset(x: offset)
                                .zIndex(Double(1000) - Double(abs(offset)))
                                .onTapGesture {
                                    if abs(offset) < cardWidth / 2 {
                                        // Direct tap on center card - play immediately
                                        onTap(realIndex)
                                    } else {
                                        // If not the center card, snap to it first, then play
                                        withAnimation(.spring()) {
                                            selectedIndex = realIndex
                                            // Wait for animation to complete before playing
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                onTap(realIndex)
                                            }
                                        }
                                    }
                                }
                                .contentShape(Rectangle())
                        }
                    }
                    .frame(width: size.width, height: cardHeight)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragging = true
                                offset = value.translation.width
                                
                                // Hide scroll indicator when user starts dragging
                                withAnimation {
                                    showScrollIndicator = false
                                }
                            }
                            .onEnded { value in
                                dragging = false
                                
                                // Calculate new index based on drag distance and direction
                                let threshold = cardWidth / 3 // Make it easier to swipe
                                if abs(offset) > threshold {
                                    let newIndex: Int
                                    if offset > 0 {
                                        // Dragged right
                                        newIndex = (selectedIndex - 1 + tracks.count) % tracks.count
                                    } else {
                                        // Dragged left
                                        newIndex = (selectedIndex + 1) % tracks.count
                                    }
                                    withAnimation(.spring()) {
                                        selectedIndex = newIndex
                                        offset = 0
                                    }
                                    
                                    // Play the track after a short delay to allow animation to finish
                                    if previousSelectedIndex != newIndex {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            onTap(newIndex)
                                        }
                                        previousSelectedIndex = newIndex
                                    }
                                } else {
                                    // Snap back
                                    withAnimation(.spring()) {
                                        offset = 0
                                    }
                                }
                                
                                // Show scroll indicator again after dragging stops
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        showScrollIndicator = true
                                    }
                                }
                            }
                    )
                    
                    // Left and right arrows as visual indicators
                    if showScrollIndicator && tracks.count > 1 {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.2))
                                .clipShape(Circle())
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedIndex = (selectedIndex - 1 + tracks.count) % tracks.count
                                        // Play the track after selection
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            onTap(selectedIndex)
                                        }
                                    }
                                }
                                .padding(.leading)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.2))
                                .clipShape(Circle())
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedIndex = (selectedIndex + 1) % tracks.count
                                        // Play the track after selection
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            onTap(selectedIndex)
                                        }
                                    }
                                }
                                .padding(.trailing)
                        }
                        .opacity(0.8)
                        .transition(.opacity)
                    }
                }
                .clipped()
                .onChange(of: selectedIndex) { newIndex in
                    previousSelectedIndex = newIndex
                }
            }
            .frame(height: cardHeight + 40)
            .onAppear {
                previousSelectedIndex = selectedIndex
                
                // Auto-hide scroll indicator after initial display
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showScrollIndicator = false
                    }
                }
            }
            
            // Pagination indicator
            if tracks.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<min(tracks.count, 9), id: \.self) { i in
                        let index = tracks.count <= 9 ? i : (i == 8 ? tracks.count - 1 : i)
                        Circle()
                            .fill(selectedIndex == index ? 
                                  Color(red: 0.4, green: 0.2, blue: 0.8) : 
                                  Color.white.opacity(0.3))
                            .frame(width: selectedIndex == index ? 10 : 8, 
                                   height: selectedIndex == index ? 10 : 8)
                            .scaleEffect(selectedIndex == index ? 1.2 : 1.0)
                            .animation(.spring(), value: selectedIndex)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedIndex = index
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onTap(index)
                                    }
                                }
                            }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 4)
            }
        }
    }
    
    private func calculateScale(offset: CGFloat, screenWidth: CGFloat) -> CGFloat {
        let maxScale: CGFloat = 1.0
        let minScale: CGFloat = 0.7
        
        let absOffset = min(abs(offset), screenWidth / 2)
        let scale = maxScale - (absOffset / (screenWidth / 2)) * (maxScale - minScale)
        
        return max(minScale, scale)
    }
    
    private func calculateOpacity(offset: CGFloat, screenWidth: CGFloat) -> Double {
        let maxOpacity: Double = 1.0
        let minOpacity: Double = 0.4
        
        let absOffset = min(abs(offset), screenWidth / 2)
        let opacity = maxOpacity - (absOffset / (screenWidth / 2)) * (maxOpacity - minOpacity)
        
        return max(minOpacity, opacity)
    }
    
    private func calculateAngle(offset: CGFloat, screenWidth: CGFloat) -> Double {
        let angle = offset * angleMultiplier
        return max(-maxRotation, min(maxRotation, angle))
    }
}

struct AlbumCard: View {
    let track: Track
    let isSelected: Bool
    
    // Animation states
    @State private var showOverlay = false
    
    var body: some View {
        ZStack {
            // Card background with glassmorphic effect
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: isSelected ? Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.5) : Color.black.opacity(0.2), 
                       radius: isSelected ? 15 : 10, 
                       x: 0, 
                       y: isSelected ? 8 : 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? 
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.7),
                                        Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: isSelected ? 2 : 0.5
                        )
                )
            
            VStack(spacing: 12) {
                // Album artwork with play overlay
                ZStack {
                    AsyncImage(url: URL(string: track.albumArtURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 5)
                        } else if phase.error != nil {
                            Image(systemName: "music.note")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(40)
                                .foregroundColor(.white.opacity(0.5))
                        } else {
                            ProgressView()
                                .frame(width: 80, height: 80)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showOverlay = hovering
                        }
                    }
                    
                    // Play overlay when hovering
                    if showOverlay {
                        ZStack {
                            Color.black.opacity(0.4)
                            Image(systemName: "play.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 0, y: 0)
                        }
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .transition(.opacity)
                    }
                }
                
                // Song title and artist (only show when selected)
                if isSelected {
                    VStack(spacing: 2) {
                        Text(track.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                        
                        Text(track.artistName)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 10)
                }
                
                // Reflection effect (subtle)
                AsyncImage(url: URL(string: track.albumArtURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .scaleEffect(x: 1, y: -0.25)
                            .opacity(0.3)
                            .offset(y: -5)
                            .blur(radius: 2)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .white.opacity(0.5)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
                .frame(width: 200, height: 30)
            }
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    AlbumCarousel(
        tracks: Track.samples,
        selectedIndex: .constant(1),
        onTap: { _ in }
    )
    .frame(height: 300)
    .padding()
    .background(Color.black)
} 

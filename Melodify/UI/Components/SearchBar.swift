import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 18))
                    .padding(.leading, 8)
                
                TextField("Search songs, artists...", text: $text)
                    .padding(8)
                    .foregroundColor(.white)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit(onSubmit)
                    .onChange(of: isFocused) { newValue in
                        isEditing = newValue
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.trailing, 8)
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.3), .white.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            
            if isEditing {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    withAnimation {
                        isEditing = false
                    }
                }
                .foregroundColor(.white)
                .padding(.leading, 8)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut, value: isEditing)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct SearchResultRow: View {
    let track: Track
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Album art thumbnail
                AsyncImage(url: URL(string: track.albumArtURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else if phase.error != nil {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.5)))
                            )
                    }
                }
                .frame(width: 50, height: 50)
                
                // Track info
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("\(track.artistName) • \(track.albumName)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Duration
                Text(formatDuration(track.duration))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial.opacity(0.3))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
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
        
        VStack(spacing: 20) {
            SearchBar(text: .constant(""), onSubmit: {})
            
            SearchResultRow(track: Track.samples[0], action: {})
                .padding(.horizontal)
        }
    }
} 
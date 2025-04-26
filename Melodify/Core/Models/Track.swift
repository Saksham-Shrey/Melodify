import Foundation

struct Track: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let artistName: String
    let albumName: String
    let albumArtURL: String
    let previewURL: String
    let duration: Int // in seconds
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
    
    // Sample data for preview
    static let samples: [Track] = [
        Track(id: "1", title: "Blinding Lights", artistName: "The Weeknd", albumName: "After Hours", 
              albumArtURL: "https://e-cdns-images.dzcdn.net/images/cover/fd00ebd6d30d7253f813dcc1a5ea9a38/500x500-000000-80-0-0.jpg", 
              previewURL: "https://cdns-preview-d.dzcdn.net/stream/c-dfa1d129bfa6eba7d2ebd2d3fb7081df-6.mp3", 
              duration: 201),
        Track(id: "2", title: "Save Your Tears", artistName: "The Weeknd", albumName: "After Hours", 
              albumArtURL: "https://e-cdns-images.dzcdn.net/images/cover/fd00ebd6d30d7253f813dcc1a5ea9a38/500x500-000000-80-0-0.jpg", 
              previewURL: "https://cdns-preview-9.dzcdn.net/stream/c-969989a1b65cd0e839a4f33bc4c1e47b-4.mp3", 
              duration: 215),
        Track(id: "3", title: "Stay", artistName: "The Kid LAROI & Justin Bieber", albumName: "Stay", 
              albumArtURL: "https://e-cdns-images.dzcdn.net/images/cover/be82c5b7ee614a3dcada4bf95e12a95f/500x500-000000-80-0-0.jpg", 
              previewURL: "https://cdns-preview-0.dzcdn.net/stream/c-0c9e1920a0bf6b49abe210d52cf1d1b7-4.mp3", 
              duration: 137)
    ]
} 
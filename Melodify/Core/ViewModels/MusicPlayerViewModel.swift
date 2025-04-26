import Foundation
import Combine

class MusicPlayerViewModel: ObservableObject {
    // Services
    private let musicService = MusicService()
    private let audioPlayerService = AudioPlayerService()
    
    // Published properties for UI
    @Published var tracks: [Track] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = ""
    
    // Forwarded properties from audio service
    @Published var currentTrack: Track?
    @Published var playbackState: PlaybackState = .stopped
    @Published var progress: Float = 0
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isShuffleEnabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        Task {
            await loadTopTracks()
        }
    }
    
    private func setupBindings() {
        // Forward audio service published properties to view model
        audioPlayerService.$currentTrack
            .assign(to: &$currentTrack)
        
        audioPlayerService.$playbackState
            .assign(to: &$playbackState)
        
        audioPlayerService.$progress
            .assign(to: &$progress)
        
        audioPlayerService.$currentTime
            .assign(to: &$currentTime)
        
        audioPlayerService.$duration
            .assign(to: &$duration)
    }
    
    // MARK: - Data fetching
    @MainActor
    func loadTopTracks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            tracks = try await musicService.getTopTracks()
            if !tracks.isEmpty {
                audioPlayerService.setQueue(tracks: tracks)
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    @MainActor
    func searchTracks() async {
        guard !searchQuery.isEmpty else {
            await loadTopTracks()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            tracks = try await musicService.searchTracks(query: searchQuery)
            if !tracks.isEmpty {
                audioPlayerService.setQueue(tracks: tracks)
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError:
                errorMessage = "Network error. Please check your connection and try again."
            case .serverError(let code):
                errorMessage = "Server error (code: \(code)). Please try again later."
            case .decodingError:
                errorMessage = "Error processing data from the server."
            case .invalidURL:
                errorMessage = "Invalid request URL."
            case .unknown:
                errorMessage = "An unknown error occurred."
            }
        } else {
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Playback control
    func playTrack(at index: Int) {
        guard index >= 0 && index < tracks.count else { return }
        audioPlayerService.setQueue(tracks: tracks, startingAt: index)
    }
    
    func togglePlayPause() {
        audioPlayerService.togglePlayPause()
    }
    
    func next() {
        audioPlayerService.next()
    }
    
    func previous() {
        audioPlayerService.previous()
    }
    
    func rewind() {
        audioPlayerService.rewind()
    }
    
    func seek(to percentage: Float) {
        let targetTime = Double(percentage) * duration
        audioPlayerService.seek(to: targetTime)
    }
    
    func toggleShuffle() {
        isShuffleEnabled.toggle()
        audioPlayerService.toggleShuffle()
    }
    
    // MARK: - Formatting helpers
    func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 
import Foundation
import AVFoundation

enum PlaybackState: Equatable {
    case loading
    case playing
    case paused
    case stopped
    case error(String)
    
    static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.playing, .playing), (.paused, .paused), (.stopped, .stopped):
            return true
        case (.error(let lhsMsg), .error(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

class AudioPlayerService: ObservableObject {
    private var audioPlayer: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    
    @Published var currentTrack: Track?
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var progress: Float = 0
    
    private var trackQueue: [Track] = []
    private var shuffledQueue: [Track] = []
    private var queueIndex: Int = 0
    private var isShuffleOn: Bool = false
    private var recentlyPlayedIds = Set<String>()
    
    init() {
        setupAudioSession()
        setupNotifications()
    }
    
    deinit {
        if let timeObserver = timeObserver, let player = audioPlayer {
            player.removeTimeObserver(timeObserver)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    @objc private func playerItemDidPlayToEndTime() {
        next()
    }
    
    // Load and prepare a track for playback
    func loadTrack(track: Track) {
        guard let url = URL(string: track.previewURL) else {
            playbackState = .error("Invalid track URL")
            return
        }
        
        playbackState = .loading
        currentTrack = track
        
        let asset = AVAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        
        if audioPlayer == nil {
            audioPlayer = AVPlayer(playerItem: playerItem)
            setupTimeObserver()
        } else {
            audioPlayer?.replaceCurrentItem(with: playerItem)
        }
        
        // Get duration
        asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            guard let self = self else { return }
            
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            
            DispatchQueue.main.async {
                if status == .loaded {
                    self.duration = asset.duration.seconds
                    self.play()
                } else {
                    self.playbackState = .error("Failed to load track duration")
                }
            }
        }
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let player = self.audioPlayer, let currentItem = player.currentItem else { return }
            
            self.currentTime = time.seconds
            
            if self.duration > 0 {
                self.progress = Float(self.currentTime / self.duration)
            }
        }
    }
    
    // Basic playback controls
    func play() {
        audioPlayer?.play()
        playbackState = .playing
    }
    
    func pause() {
        audioPlayer?.pause()
        playbackState = .paused
    }
    
    func stop() {
        audioPlayer?.pause()
        audioPlayer?.seek(to: CMTime.zero)
        playbackState = .stopped
    }
    
    func togglePlayPause() {
        if case .playing = playbackState {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to timeInSeconds: Double) {
        let time = CMTime(seconds: timeInSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        audioPlayer?.seek(to: time)
    }
    
    func rewind() {
        let newTime = max(0, currentTime - 10)
        seek(to: newTime)
    }
    
    // Queue management
    func setQueue(tracks: [Track], startingAt index: Int = 0) {
        trackQueue = tracks
        queueIndex = max(0, min(index, tracks.count - 1))
        
        if isShuffleOn {
            shuffleQueue()
        } else {
            shuffledQueue = trackQueue
        }
        
        if !shuffledQueue.isEmpty {
            loadTrack(track: shuffledQueue[queueIndex])
        }
    }
    
    func next() {
        if shuffledQueue.isEmpty { return }
        
        queueIndex = (queueIndex + 1) % shuffledQueue.count
        loadTrack(track: shuffledQueue[queueIndex])
    }
    
    func previous() {
        if shuffledQueue.isEmpty { return }
        
        // If we're past 3 seconds in the song, go back to the start of the current song
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        
        queueIndex = (queueIndex - 1 + shuffledQueue.count) % shuffledQueue.count
        loadTrack(track: shuffledQueue[queueIndex])
    }
    
    func toggleShuffle() {
        isShuffleOn.toggle()
        
        // Save current track
        let currentTrack = self.currentTrack
        
        if isShuffleOn {
            shuffleQueue()
        } else {
            // When turning shuffle off, find the current track in the original queue
            shuffledQueue = trackQueue
            if let track = currentTrack, let index = trackQueue.firstIndex(where: { $0.id == track.id }) {
                queueIndex = index
            }
        }
    }
    
    private func shuffleQueue() {
        guard let currentTrack = currentTrack else {
            shuffledQueue = trackQueue.shuffled()
            return
        }
        
        // Add current track to recently played
        recentlyPlayedIds.insert(currentTrack.id)
        // Limit size of recently played
        if recentlyPlayedIds.count > min(5, trackQueue.count / 2) {
            recentlyPlayedIds.remove(recentlyPlayedIds.first!)
        }
        
        // Smart shuffle: avoid recently played tracks
        var availableTracks = trackQueue.filter { !recentlyPlayedIds.contains($0.id) }
        var shuffled: [Track] = []
        
        // Start with current track
        shuffled.append(currentTrack)
        
        // If we have few available tracks, reset the history
        if availableTracks.count < 3 && trackQueue.count > 5 {
            recentlyPlayedIds = [currentTrack.id]
            availableTracks = trackQueue.filter { $0.id != currentTrack.id }
        }
        
        // Shuffle remaining tracks
        shuffled.append(contentsOf: availableTracks.shuffled())
        
        // Add back recently played tracks (except current) at the end
        let recentlyPlayed = trackQueue.filter { 
            recentlyPlayedIds.contains($0.id) && $0.id != currentTrack.id 
        }
        shuffled.append(contentsOf: recentlyPlayed.shuffled())
        
        shuffledQueue = shuffled
        queueIndex = 0 // Current track is now at the beginning
    }
} 
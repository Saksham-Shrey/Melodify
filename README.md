# Melodify - Modern Music Player

<div align="center">
  <img src="https://github.com/user-attachments/assets/c80b8e5d-b647-4e20-96a4-d7b0d3bd7bcf" alt="Melodify Logo" width="200" style="border-radius: 15px;"/>
  <p><i>A sophisticated music player with immersive 3D carousel experience</i></p>

  
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-FF2D55?style=for-the-badge&logo=swift&logoColor=white)
  ![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
  ![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)
  ![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)
</div>

## Overview

Melodify is a next-generation music player app that combines stunning visual design with powerful audio features. Built with SwiftUI and MVVM architecture, it delivers a fluid, immersive music experience with its 3D carousel interface, glassmorphic design elements, and smart playback capabilities.


## Key Features

### Interactive Music Experience
- **3D Album Carousel**: Swipe, tap, or use controls to browse albums with fluid 3D animations
- **Immersive Full-screen Player**: Dynamic album art rotation that responds to playback state
- **Background Playback Support**: Keep the music going while using other apps

### Smart Audio Engine
- **Comprehensive Playback Controls**:
  - Play/Pause with smooth transitions
  - Previous/Next track navigation
  - 10-second rewind for revisiting favorite moments
  - Smart shuffle algorithm that prioritizes fresh content
- **Real-time Progress Tracking**: Visualize your position in the current track
- **Mini-player**: Access controls without interrupting your browsing experience

### Modern UI Design
- **Glassmorphic Interface**: Stunning translucent elements with depth effects
- **Dynamic Animations**: Fluid transitions and responsive UI elements
- **Adaptive Layout**: Beautiful experience across all iOS devices and orientations
- **Dark Mode Optimized**: Designed for low-light environments

### Content Discovery
- **Powerful Search**: Find tracks, artists, and albums instantly
- **Trending Section**: Discover popular music through the Deezer API
- **Responsive Results**: Fast-loading content with elegant loading states

## Technical Architecture

Melodify is engineered with modern best practices and follows a clean MVVM architecture:

```
Melodify/
├── Core/                  # Core application logic
│   ├── Models/            # Data structures
│   ├── Services/          # Network and audio services
│   └── ViewModels/        # Business logic and state management
├── Features/              # Feature-specific views
│   ├── Home/              # Home screen experience
│   └── Player/            # Playback interface
├── UI/                    # Reusable UI components
│   └── Components/        # Custom UI controls
└── Resources/             # Assets and supporting files
```

### Key Technical Highlights

- **Swift Concurrency**: Uses async/await for efficient network operations
- **Combine Framework**: Reactive data binding for UI updates
- **AVFoundation**: Professional audio handling with precise control
- **SwiftUI Animations**: GPU-accelerated animations for fluid experience
- **Clean API Integration**: Structured network layer with Deezer API

## Requirements & Dependencies

### System Requirements
- **iOS**: 16.0 or later
- **Xcode**: 14.0 or later
- **Swift**: 5.5 or later
- **Device**: Compatible with iPhone and iPad

### External Dependencies
- **Deezer API**: Powers music discovery and streaming
- **SF Symbols**: Used for consistent iconography

## Installation

### For Users
1. Clone this repository
   ```bash
   git clone https://github.com/yourusername/Melodify.git
   ```
2. Open `Melodify.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘+R)

### For Developers
1. Clone the repository as above
2. Install development dependencies if needed
   ```bash
   # If using CocoaPods (future expansion)
   pod install
   ```
3. Open the project in Xcode
4. Build and run the application

## Usage Examples

### Playing Music
1. Browse through the album carousel by swiping left or right
2. Tap on an album to select and play it
3. Use the navigation dots below the carousel for quick access
4. Access full player by tapping on the mini-player

### Searching for Music
1. Tap the search bar at the top
2. Enter artist, album, or track name
3. Browse and play from search results

### Using the Full Player
1. Use the central play/pause button for playback control
2. Swipe down to minimize to mini-player
3. Use rewind button to go back 10 seconds
4. Tap shuffle to enable smart shuffle mode

## Extension Points

Melodify is designed for extensibility. Here are some areas for potential enhancement:

- **Offline Caching**: Add persistent storage for offline playback
- **User Playlists**: Enable custom playlist creation and management
- **Social Sharing**: Implement music sharing capabilities
- **Audio Effects**: Add equalizer and audio enhancement features
- **Cross-device Sync**: Enable continuity across user's devices

## Contributing

Contributions are welcome and appreciated! Here's how you can contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows the project's coding standards and includes appropriate tests.

## Roadmap

- [ ] User accounts and personalization
- [ ] Offline mode with download management
- [ ] Enhanced visualizations and animations
- [ ] CarPlay integration
- [ ] Siri shortcuts support
- [ ] Apple Watch companion app

## Contact & Support

For questions, suggestions, or support requests, please:
- Open an issue in this repository
- Contact the maintainer at [sakshamshrey@gmail.com](sakshamshrey@gmail.com)

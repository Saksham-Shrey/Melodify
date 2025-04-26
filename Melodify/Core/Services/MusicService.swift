import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknown
}

class MusicService {
    // Deezer API proxy to bypass CORS restrictions
    private let baseURL = "https://api.deezer.com"
    
    func searchTracks(query: String) async throws -> [Track] {
        guard let url = URL(string: "\(baseURL)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            do {
                let searchResponse = try decoder.decode(DeezerSearchResponse.self, from: data)
                return searchResponse.data.map { deezerTrack in
                    Track(
                        id: "\(deezerTrack.id)",
                        title: deezerTrack.title,
                        artistName: deezerTrack.artist.name,
                        albumName: deezerTrack.album.title,
                        albumArtURL: deezerTrack.album.coverMedium,
                        previewURL: deezerTrack.preview,
                        duration: deezerTrack.duration
                    )
                }
            } catch {
                throw APIError.decodingError(error)
            }
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            }
            throw APIError.networkError(error)
        }
    }
    
    func getTopTracks() async throws -> [Track] {
        // Get trending/popular tracks from Deezer charts
        guard let url = URL(string: "\(baseURL)/chart/0/tracks") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            do {
                let chartResponse = try decoder.decode(DeezerChartResponse.self, from: data)
                return chartResponse.data.map { deezerTrack in
                    Track(
                        id: "\(deezerTrack.id)",
                        title: deezerTrack.title,
                        artistName: deezerTrack.artist.name,
                        albumName: deezerTrack.album.title,
                        albumArtURL: deezerTrack.album.coverMedium,
                        previewURL: deezerTrack.preview,
                        duration: deezerTrack.duration
                    )
                }
            } catch {
                throw APIError.decodingError(error)
            }
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            }
            throw APIError.networkError(error)
        }
    }
}

// Deezer API response models
struct DeezerSearchResponse: Codable {
    let data: [DeezerTrack]
}

struct DeezerChartResponse: Codable {
    let data: [DeezerTrack]
}

struct DeezerTrack: Codable {
    let id: Int
    let title: String
    let duration: Int
    let preview: String
    let artist: DeezerArtist
    let album: DeezerAlbum
}

struct DeezerArtist: Codable {
    let id: Int
    let name: String
}

struct DeezerAlbum: Codable {
    let id: Int
    let title: String
    let coverMedium: String
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case coverMedium = "cover_medium"
    }
}
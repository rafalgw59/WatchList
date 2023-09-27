
import Foundation

struct MovieSeries: Identifiable, Codable {
    var title: String
    var releaseDate: Date
    var type: String
    var imageFilename: String
    var episodes: [Episode]?
    var id: UUID
    var nextEpisodeReleaseDate: Date? {
        get {
            if type == "series" {
                if let episodes = episodes, !episodes.isEmpty {
                    let sortedEpisodes = episodes.sorted { $0.releaseDate < $1.releaseDate }
                    for episode in sortedEpisodes {
                        if episode.releaseDate > Date() {
                            return episode.releaseDate
                        }
                    }
                }
            }
            return nil
        }
        set {

        }
    }
    var numberOfEpisodes: Int? {
        return episodes?.count
    }
    var nextEpisode: Episode? {
        if type == "series", let episodes = episodes, !episodes.isEmpty {
            let now = Date()
            let sortedEpisodes = episodes.sorted { $0.releaseDate < $1.releaseDate }

            for episode in sortedEpisodes {
                if episode.releaseDate > now {
                    return episode
                }
            }
        }
        return nil
    }

    var releaseDateCountdownText: String {
        let now = Date()
        let calendar = Calendar.current

        if now < releaseDate {
            let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: releaseDate)
            let days = components.day ?? 0
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0
            let seconds = components.second ?? 0

            return String(format: "%02dd %02dh %02dmin %02dsec", days, hours, minutes, seconds)
        } else {
            return "Released"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate
        case type
        case episodes
        case imageFilename
    }
}

struct Episode: Identifiable, Codable, Equatable {
    var episodeNumber: Int
    var title: String
    var releaseDate: Date
    var id: UUID
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        return lhs.episodeNumber == rhs.episodeNumber &&
               lhs.title == rhs.title &&
               lhs.releaseDate == rhs.releaseDate
    }
    
    static func saveEpisodes(episodes: [Episode]) {
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(episodes){
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }
}


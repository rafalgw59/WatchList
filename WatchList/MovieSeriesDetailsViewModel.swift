
import Foundation
import Combine

class MovieSeriesDetailsViewModel: ObservableObject {
    private var timer: Timer?
    @Published var episodes: [Episode]
    @Published var countdownText: String = ""
   
    var releaseDate: Date?
    
    var numberOfEpisodes: Int {
        return episodes.count
    }
    
    init(episodes: [Episode]) {
        self.episodes = episodes.sorted { $0.releaseDate < $1.releaseDate }
        loadEpisodesFromPlist()
        
    }

    func addEpisode(_ episode: Episode) {
        episodes.append(episode)
        episodes.sort { $0.releaseDate < $1.releaseDate }
        saveEpisodesToPlist()
    }
    func editEpisode(_ episode: Episode){
//        if let index = episodes.firstIndex(where: {$0.id == episode.id}){
//            episodes[index] = episode
//        }
        saveEpisodesToPlist()
    }

    func deleteEpisode(_ episode: Episode) {
        if let index = episodes.firstIndex(where: { $0.id == episode.id }) {
            episodes.remove(at: index)
            saveEpisodesToPlist()
        }
    }
    
    var nearestEpisode: Episode? {
        let now = Date()
        let upcomingEpisodes = episodes.filter { $0.releaseDate > now }
        return upcomingEpisodes.min(by: { $0.releaseDate < $1.releaseDate })
    }
    
    func isEpisodeReleased(_ episode: Episode) -> Bool {
        return episode.releaseDate <= Date()
    }

    private func loadEpisodesFromPlist() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let archiveURL = documentsDirectory.appendingPathComponent("episodes.plist")
            if let savedEpisodesData = try? Data(contentsOf: archiveURL),
                let savedEpisodes = try? PropertyListDecoder().decode([Episode].self, from: savedEpisodesData) {
                self.episodes = savedEpisodes
            }
        }
    }

    func saveEpisodesToPlist() {
        let encoder = PropertyListEncoder()
        if let encodedEpisodes = try? encoder.encode(episodes) {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let archiveURL = documentsDirectory.appendingPathComponent("episodes.plist")
                do {
                    try encodedEpisodes.write(to: archiveURL)
                } catch {
                    print("Error saving episodes to plist: \(error)")
                }
            }
        }
    }
    func startCountdownTimer(for releaseDate: Date) {
        // ...
        self.releaseDate = releaseDate
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateCountdownText()
        }
        // ...
    }

    func stopTimer(){
        timer?.invalidate()
        timer = nil
    }
    func updateCountdownText() {
        guard let releaseDate = releaseDate else {
            countdownText = ""
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        if now < releaseDate {
            let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: releaseDate)
            let days = components.day ?? 0
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0
            let seconds = components.second ?? 0
            
            countdownText = String(format: "%02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
        } else {
            countdownText = "Released"
        }
    }
}

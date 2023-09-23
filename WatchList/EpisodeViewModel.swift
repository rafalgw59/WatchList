//
//  EpisodeViewModel.swift
//  WatchList
//
//  Created by Rafał Gawlik on 23/09/2023.
//

import Foundation

class EpisodeViewModel: ObservableObject {
    @Published var episodes: [Episode]
    
    init(episodes: [Episode] = []){
        self.episodes = episodes
    }
    
    func addEpisode(_ episode: Episode){
        episodes.append(episode)
    }
    func editEpisode(_ episode: Episode){
        if let index = episodes.firstIndex(where: {$0.id == episode.id}){
            episodes[index] = episode
        }
    }
    func deleteEpisode(_ episode: Episode){
        episodes.removeAll {$0.id == episode.id}
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
}


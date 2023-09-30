import SwiftUI
import Foundation
import Combine

class MovieSeriesData: ObservableObject {
    @Published var movieSeries: [MovieSeries] = []
    @Published var coverImages: [UIImage?] = []
    init(){
        if let data = loadMovieSeriesDataFromFile("MovieSeriesData"){
            movieSeries = data
        }
    }
    func getTitle(byId id: UUID) -> MovieSeries? {
        return movieSeries.first { $0.id == id }
    }
    func getType(byId id: UUID) -> String? {
        return getTitle(byId: id)?.type
    }
    func getEpisodes(byId id: UUID) -> [Episode]? {
        return getTitle(byId: id)?.episodes
    }
    //release data
    func getReleaseDate(byId id: UUID) -> Date? {
        return getTitle(byId: id)?.releaseDate

    }
    //imagefilename
    func getImageFilename(byId id: UUID) -> String? {
        return getTitle(byId: id)?.imageFilename
    }
    func getNextEpisodeReleaseDate(byId id: UUID) -> Date? {
        return getTitle(byId: id)?.nextEpisodeReleaseDate
    }
    
    
    private func loadMovieSeriesDataFromFile(_ plistName: String) -> [MovieSeries]? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(plistName).plist")
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = PropertyListDecoder()
                let movieSeriesArray = try decoder.decode([MovieSeries].self,from: data)
                return movieSeriesArray
            } catch {
                print("Error loading cover image: \(error)")
            }
        }
        return nil
    }
}

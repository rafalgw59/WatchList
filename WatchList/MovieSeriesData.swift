
import Foundation
import Combine

class MovieSeriesData: ObservableObject {
    @Published var movieSeries: [MovieSeries] = []
    
    init(){
        if let data = loadMovieSeriesDataFromFile("MovieSeriesData"){
            movieSeries = data
        }
    }
    func getTitle(byName name: String) -> MovieSeries? {
        return movieSeries.first { $0.title == name }
    }
    func getType(forTitle name: String) -> String? {
        return getTitle(byName: name)?.type
    }
    func getEpisodes(forTitle name: String) -> [Episode]? {
        return getTitle(byName: name)?.episodes
    }
    //release data
    func getReleaseDate(forTitle name: String) -> Date? {
        return getTitle(byName: name)?.releaseDate

    }
    //imagefilename
    func getImageFilename(forTitle name: String) -> String? {
        return getTitle(byName: name)?.imageFilename
    }
    func getNextEpisodeReleaseDate(forTitle name: String) -> Date? {
        return getTitle(byName: name)?.nextEpisodeReleaseDate
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


import SwiftUI

struct AddEpisodeToExistingMovieSeriesView: View {
    @ObservedObject var movieSeriesData: MovieSeriesData
    @Binding var movieSeriesId: UUID
    @Binding var episodes: [Episode]
    @Binding var isAddingEpisode: Bool
    @State private var id: UUID = UUID()
    @State private var title: String = ""
    @State private var episodeNumber: Int = 0
    @State private var releaseDate: Date = Date()
    @ObservedObject var countdownTimerViewModel: CountdownTimerViewModel = CountdownTimerViewModel.shared
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Episode Details")) {
                    TextField("Episode Title", text: $title)
                    Stepper("Episode Number: \(episodeNumber)", value: $episodeNumber)
                        .keyboardType(.numberPad) // Allow only numeric input
                    DatePicker("Release Date", selection: $releaseDate)
                }
            }
            .navigationBarItems(
                leading: Button("Save") {
                    saveEpisode()
                }
                .disabled(title.isEmpty)
            )
        }
    }

    private func saveEpisode() {
        let newEpisode = Episode(episodeNumber: episodeNumber, title: title, releaseDate: releaseDate, id: id)
        episodes.append(newEpisode)
        print("Saved episode: \(newEpisode)")
        print("Updated episodes: \(episodes)")
        if let movieSeriesIndex = movieSeriesData.movieSeries.firstIndex(where: {$0.id == movieSeriesId}){
            movieSeriesData.movieSeries[movieSeriesIndex].episodes? = episodes
            addToPlist(episodeToAdd: newEpisode)
            
            if let sortedEpisodes = movieSeriesData.movieSeries[movieSeriesIndex].episodes?.sorted(by: {$0.releaseDate < $1.releaseDate}){
                countdownTimerViewModel.startCountdownTimer(for: nil, nextEpisodeReleaseDate: sortedEpisodes.first?.releaseDate)

            }
        }
        isAddingEpisode = false
    }
    
    private func addToPlist(episodeToAdd episode: Episode){
        if var movieSeriesArray = loadMovieSeriesData("MovieSeriesData"){
            if let movieSeriesIndex = movieSeriesArray.firstIndex(where: {$0.id == movieSeriesId}){
                movieSeriesArray[movieSeriesIndex].episodes?.append(episode)
                saveMovieSeriesData(movieSeriesArray, plistName: "MovieSeriesData")
            }
        }
    }
    private func loadMovieSeriesData(_ plistName: String) -> [MovieSeries]? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(plistName).plist")
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = PropertyListDecoder()
                let movieSeries = try decoder.decode([MovieSeries].self, from: data)
                return movieSeries
            } catch {
                print("Error loading data from \(plistName).plist: \(error)")
            }
        }
        return nil
    }
    private func saveMovieSeriesData(_ movieSeries: [MovieSeries], plistName: String) {
        let encoder = PropertyListEncoder()
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(plistName).plist")
            do {
                let data = try encoder.encode(movieSeries)
                try data.write(to: fileURL)
                print("Movie series data saved to \(fileURL.path)")
            } catch {
                print("Error saving movie series data: \(error)")
            }
        }
    }

}

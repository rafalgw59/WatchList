
import SwiftUI
import Combine

struct EditableEpisodeDetailsView: View {
    @ObservedObject var movieSeriesData: MovieSeriesData
//    @Binding var movieSeries: MovieSeries
    @Binding var episodes: [Episode]
    @Binding var episode: Episode?
    @Binding var isEditingEpisode: Bool
    //let episodeDeletedCallback: () -> Void
    @State private var episodeNumberText: String
    @State private var title: String
    @State private var releaseDate: Date
    @ObservedObject var countdownTimerViewModel: CountdownTimerViewModel = CountdownTimerViewModel.shared
    //var episodeNumberText: String
    
    init(movieSeriesData:MovieSeriesData,episodes: Binding<[Episode]>, episode: Binding<Episode?>, isEditingEpisode: Binding<Bool>, countdownTimerViewModel: CountdownTimerViewModel) {
        self.movieSeriesData = movieSeriesData
        self.countdownTimerViewModel = countdownTimerViewModel
        self._episodes = episodes
        self._episode = episode
        self._isEditingEpisode = isEditingEpisode
        _episodeNumberText = State(initialValue: String(episode.wrappedValue?.episodeNumber ?? 0))
        _title = State(initialValue: episode.wrappedValue?.title ?? "")
        _releaseDate = State(initialValue: episode.wrappedValue?.releaseDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            if let episode = episode {
                Form {
                    Section(header: Text("Episode Details")) {
                        TextField("Episode Number",text: $episodeNumberText)
                            .keyboardType(.numberPad)
                            .onAppear {
                                episodeNumberText = String(episode.episodeNumber)
                                
                                let passedid = episode.id
                                print(passedid)
                            }
                        
                        TextField("Title", text: $title)
                            .onAppear {
                                title = episode.title
                            }
                        
                        DatePicker("Release Date", selection: $releaseDate, in: Date()...)
                            .onAppear {
                                releaseDate = episode.releaseDate
                            }
                    }
                    
                    Section {
                        Button("Save Changes") {
                            editEpisode(episodeToEdit: episode)
                        }
                        .foregroundColor(.blue)
                        
                        Button("Delete Episode") {
                            deleteEpisode(episodeToDelete: episode)
                            //countdownTimerViewModel.startCountdownTimer(for: <#T##Date?#>, nextEpisodeReleaseDate: )
                        }
                        .foregroundColor(.red)
                    }
                }
                .navigationTitle("Edit Episode")
            } else {
                EmptyView()
            }
        }
    }

    
    private func editEpisode(episodeToEdit episode: Episode) {
        if let movieSeriesIndex = movieSeriesData.movieSeries.firstIndex(where: { $0.episodes?.contains { $0.id == episode.id } ?? false }) {

            var updatedEpisode = episode
            updatedEpisode.episodeNumber = Int(episodeNumberText) ?? 0
            updatedEpisode.title = title
            updatedEpisode.releaseDate = releaseDate

            movieSeriesData.movieSeries[movieSeriesIndex].episodes?.removeAll { $0.id == updatedEpisode.id }
            
            movieSeriesData.movieSeries[movieSeriesIndex].episodes?.append(updatedEpisode)
            updateEpisodeInPlist(updatedEpisode)

            if let sortedEpisodes = movieSeriesData.movieSeries[movieSeriesIndex].episodes?.sorted(by: {$0.releaseDate < $1.releaseDate}){
                countdownTimerViewModel.startCountdownTimer(for: nil, nextEpisodeReleaseDate: sortedEpisodes.first?.releaseDate)

            }


        }

        isEditingEpisode = false
    }


    private func deleteEpisode(episodeToDelete episode: Episode) {
        if let movieSeriesIndex = movieSeriesData.movieSeries.firstIndex(where: { $0.episodes?.contains { $0.id == episode.id} ?? false}) {
            if let episodeIndex = movieSeriesData.movieSeries[movieSeriesIndex].episodes?.firstIndex(where: { $0.id == episode.id}) {
                movieSeriesData.movieSeries[movieSeriesIndex].episodes?.remove(at: episodeIndex)
                removeEpisodeFromPlist(episode)
                episodes.removeAll(where: {$0.id == episode.id})
                movieSeriesData.movieSeries[movieSeriesIndex].episodes = episodes
                if let sortedEpisodes = movieSeriesData.movieSeries[movieSeriesIndex].episodes?.sorted(by: {$0.releaseDate < $1.releaseDate}) {
                    if let nextEpisodeReleaseDate = sortedEpisodes.first?.releaseDate {
                        countdownTimerViewModel.startCountdownTimer(for: nil, nextEpisodeReleaseDate: nextEpisodeReleaseDate)
                        print("Timer started with nextEpisodeReleaseDate: \(nextEpisodeReleaseDate)")
                    } else {
                        // No more episodes, set timer to series release date
                        countdownTimerViewModel.startCountdownTimer(for: movieSeriesData.movieSeries[movieSeriesIndex].releaseDate, nextEpisodeReleaseDate: nil)
                        countdownTimerViewModel.updateCountdown()
                        print("Timer started with Series Release Date 1: \(movieSeriesData.movieSeries[movieSeriesIndex].releaseDate)")
                    }
                } else {
                    // No more episodes, set timer to series release date
                    countdownTimerViewModel.startCountdownTimer(for: movieSeriesData.movieSeries[movieSeriesIndex].releaseDate, nextEpisodeReleaseDate: nil)
                    print("Timer started with Series Release Date 2: \(movieSeriesData.movieSeries[movieSeriesIndex].releaseDate)")
                }
                

                //episodeDeletedCallback()
            }
        }
        
        isEditingEpisode = false
    }


    
    private func removeEpisodeFromPlist(_ deletedEpisode: Episode) {
        if var movieSeriesArray = loadMovieSeriesData("MovieSeriesData") {
            if let movieSeriesIndex = movieSeriesArray.firstIndex(where: { $0.episodes?.contains { $0.id == deletedEpisode.id } ?? false }) {
                movieSeriesArray[movieSeriesIndex].episodes?.removeAll { $0.id == deletedEpisode.id }
                
                saveMovieSeriesData(movieSeriesArray,plistName: "MovieSeriesData")
            }
        }
    }
 
    
    private func updateEpisodeInPlist(_ updatedEpisode: Episode) {
        if var movieSeriesArray = loadMovieSeriesData("MovieSeriesData") {
            if let movieSeriesIndex = movieSeriesArray.firstIndex(where: { $0.episodes?.contains { $0.id == updatedEpisode.id } ?? false }) {
                if let episodeIndex = movieSeriesArray[movieSeriesIndex].episodes?.firstIndex(where: { $0.id == updatedEpisode.id }) {
                    movieSeriesArray[movieSeriesIndex].episodes?[episodeIndex] = updatedEpisode
                    
                    saveMovieSeriesData(movieSeriesArray,plistName: "MovieSeriesData")
                }
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
    
    private func updateMovieSeriesData() {
        var updatedMovieSeries = movieSeriesData.movieSeries

        if let episodeIndex = updatedMovieSeries.firstIndex(where: { $0.episodes?.contains { $0.id == episode?.id } ?? false }) {
            if let episode = episode {
                updatedMovieSeries[episodeIndex].episodes?.removeAll { $0.id == episode.id }
                updatedMovieSeries[episodeIndex].episodes?.append(episode)
            }
        }

        movieSeriesData.movieSeries = updatedMovieSeries
    }

}


    
    








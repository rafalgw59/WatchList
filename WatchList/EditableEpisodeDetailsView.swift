
import SwiftUI
import Combine

struct EditableEpisodeDetailsView: View {
    //@ObservedObject var viewModel: MovieSeriesDetailsViewModel
    
    @Binding var episodes: [Episode]
    @Binding var episode: Episode?
    @Binding var isEditingEpisode: Bool
    
    @State private var episodeNumberText: String
    @State private var title: String
    @State private var releaseDate: Date
    
    init(episodes: Binding<[Episode]>, episode: Binding<Episode?>, isEditingEpisode: Binding<Bool>) {
        self._episodes = episodes
        self._episode = episode
        self._isEditingEpisode = isEditingEpisode
        _episodeNumberText = State(initialValue: String(episode.wrappedValue?.episodeNumber ?? 0))
        _title = State(initialValue: episode.wrappedValue?.title ?? "")
        _releaseDate = State(initialValue: episode.wrappedValue?.releaseDate ?? Date())
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Episode Details")) {
                    TextField("Episode Number", text: $episodeNumberText)
                        .keyboardType(.numberPad)
                        .onAppear {
                            episodeNumberText = String(episode?.episodeNumber ?? 0)
                        }

                    TextField("Title", text: $title)
                        .onAppear {
                            title = episode?.title ?? ""
                        }

                    DatePicker("Release Date", selection: $releaseDate, in: Date()...)
                        .onAppear {
                            releaseDate = episode?.releaseDate ?? Date()
                        }
                }

                Section {
                    Button("Save Changes") {
                        if var updatedEpisode = episode {
                            updatedEpisode.episodeNumber = Int(episodeNumberText) ?? 0
                            updatedEpisode.title = title
                            updatedEpisode.releaseDate = releaseDate
                            
                            
                            episode = updatedEpisode
                            viewModel.editEpisode(updatedEpisode)
//                            episodePublisher.send(updatedEpisode)
                            print("Episode updated and saved to plist")
                            print(updatedEpisode.title,updatedEpisode.episodeNumber,updatedEpisode.releaseDate)
                        }
                        isEditingEpisode = false
                    }
                    .foregroundColor(.blue)

                    Button("Delete Episode") {
                        if let deletedEpisode = episode {
                            viewModel.deleteEpisode(deletedEpisode)
                            episode = nil
                        }
                        isEditingEpisode = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Episode")
        }
    }
//    private func saveEpisode() {
//        let newEpisode = Episode(episodeNumber: episodeNumber, title: title, releaseDate: releaseDate)
//        episodes.append(newEpisode)
//        isAddingEpisode = false
//    }
    
    private func editEpisode(){
        
    }
    private func deleteEpisode(){
        
    }
    private func saveEpisode(){
        
    }
    
    private func updateEpisodeInPlist(_ updatedEpisode: Episode) {
        if var movieSeriesArray = loadMovieSeriesData("MovieSeriesData") {
            // Find the movie series that contains the episode
            if let movieSeriesIndex = movieSeriesArray.firstIndex(where: { $0.episodes?.contains { $0.id == updatedEpisode.id } ?? false }) {
                // Find the episode in the movie series and update it
                if let episodeIndex = movieSeriesArray[movieSeriesIndex].episodes?.firstIndex(where: { $0.id == updatedEpisode.id }) {
                    movieSeriesArray[movieSeriesIndex].episodes?[episodeIndex] = updatedEpisode
                    
                    // Save the updated data back to the plist
                    saveMovieSeriesData(movieSeriesArray)
                }
            }
        }
    }
    private func loadMovieSeriesData(_ plistName: String) -> [MovieSeries]? {
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
           let data = FileManager.default.contents(atPath: path) {
            do {
                let decoder = PropertyListDecoder()
                let movieSeries = try decoder.decode([MovieSeries].self, from: data)
                return movieSeries
            } catch {
                print("Error decoding data from \(plistName).plist: \(error)")
            }
        }
        return nil
    }
    
    private func saveMovieSeriesData(_ movieSeries: [MovieSeries]) {
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(movieSeries)
            if let path = Bundle.main.path(forResource: "MovieSeriesData", ofType: "plist") {
                try data.write(to: URL(fileURLWithPath: path))
            }
        } catch {
            print("Error encoding data: \(error)")
        }
    }


    
    
}







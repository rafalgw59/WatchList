import SwiftUI
import Combine

struct MovieSeriesDetailsView: View {

    var movieSeries: MovieSeries
    @ObservedObject var viewModel: MovieSeriesDetailsViewModel = MovieSeriesDetailsViewModel(episodes: [])
    @ObservedObject var countdownTimerViewModel: CountdownTimerViewModel = CountdownTimerViewModel.shared
    @ObservedObject var episodeViewModel: EpisodeViewModel
    @Binding var showDetailsView: Bool
    @ObservedObject var movieSeriesData: MovieSeriesData
    @State private var countdownText: String = ""
    @State private var isTimerRunning = false
    @State private var selectedEpisode: Episode?
    @State private var isEditingEpisode = false
    @State private var isAddingEpisode = false
    @State private var isAddingMultipleEpisodes = false
    @State private var selectedEpisodeForEditing: Episode?
    @State private var isEditingSheetPresented = false
    @State private var shouldReload = false
    @State private var releaseStatus: String = ""
    @State private var episodes: [Episode] = []
    @State private var coverImage: UIImage? = nil
    @State var movieSeriesID: UUID = UUID()
    @State private var isEditingMovieSeries = false
    @State private var movieSeriesIndex: Int = 0
    @StateObject var dateManager = DateManager()

    
    private var selectedEpisodePublisher = PassthroughSubject<Episode?, Never>()
    private var timer: Timer?

    init(movieSeries: MovieSeries, movieSeriesData: MovieSeriesData, showDetailsView: Binding<Bool>) {
        self._showDetailsView = showDetailsView
        self.movieSeries = movieSeries
        self.movieSeriesData = movieSeriesData
        self.viewModel = MovieSeriesDetailsViewModel(episodes: movieSeries.episodes ?? [])
        self.episodeViewModel = EpisodeViewModel(episodes: movieSeries.episodes ?? [])
        if movieSeries.type == "movie" {
            self.countdownTimerViewModel = CountdownTimerViewModel()
            if let movieSeriesReleaseDate = movieSeriesData.getReleaseDate(byId: movieSeries.id){
                countdownTimerViewModel.startCountdownTimer(for: movieSeriesReleaseDate, nextEpisodeReleaseDate: nil)
            }
        } else if movieSeries.type == "series" {
            self.countdownTimerViewModel = CountdownTimerViewModel()
            if let nextEpisodeReleaseDate = movieSeriesData.getNextEpisodeReleaseDate(byId: movieSeries.id){
                countdownTimerViewModel.startCountdownTimer(for: nil, nextEpisodeReleaseDate: nextEpisodeReleaseDate)

            }
        } else {
            self.countdownTimerViewModel = CountdownTimerViewModel()
        }

    }


    var body: some View {
        NavigationView{
            VStack {
                
                ZStack {
                    
                    //Image(movieSeries.imageFilename)
                    if !movieSeriesData.getImageFilename(byId: movieSeries.id)!.isEmpty {
                        Image(uiImage: movieSeriesData.coverImages[movieSeriesIndex] ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.8)
                            .cornerRadius(15)
                            .frame(height: 200)
                            .padding(.top, 50)
                    } else {
                        
                    }
                    
                    
                    Text(movieSeries.title)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 50)
                }
                
                Text("Release Date: \(formattedDate())")
                    .font(.headline)
                    .padding()
                
                Text("\(countdownTimerViewModel.countdownText)")
                    .font(.headline)
                    .padding()
                
                
                
                if let selectedMovieSeries = movieSeriesData.getTitle(byId: movieSeries.id) {
                    Text("Type: \(selectedMovieSeries.type)")
                        .font(.subheadline)
                        .padding()
                    
                    if selectedMovieSeries.type == "series" {
                        Divider()
                        
                        //Text("Episodes: \(viewModel.numberOfEpisodes)")
                        Text("Episodes: \(String(format: "%d", selectedMovieSeries.numberOfEpisodes ?? 0))")
                            .font(.headline)
                            .padding()
                        if let episodes = selectedMovieSeries.episodes, !episodes.isEmpty {
                            let sortedEpisodes = episodes.sorted { $0.releaseDate < $1.releaseDate }
                            if sortedEpisodes[0].releaseDate > Date() {
                                Text("Next Episode: Episode \(sortedEpisodes[0].episodeNumber): \(sortedEpisodes[0].title)")
                                    .font(.headline)
                                    .padding(.top)
                                    .padding(.bottom)
                            }
                        }
                        
                        List {
                            ForEach(selectedMovieSeries.episodes!, id: \.id) { episode in
                                Button(action: {
                                    selectedEpisodeForEditing = episode
                                    isEditingSheetPresented = true
                                    
                                }) {
                                    EpisodeRowView(episode: episode, formattedDate: formattedDate)
                                }
                            }
                            Section{
                                Button("Add Episode"){
                                    dateManager.msReleaseDate = episodes.last?.releaseDate ?? selectedMovieSeries.releaseDate
                                    isAddingEpisode = true
                                }
                                .foregroundColor(.blue)
                                
//                                Button("Add Multiple Episodes"){
//                                    isAddingMultipleEpisodes = true
//                                }
                            }
                        }
                        
                    }
                    
                }
                
                Spacer()
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarLeading){
                    Button(action: {
                        isEditingMovieSeries = true
                    }) {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                            .foregroundColor(.black)
                    }
                }
                ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarTrailing){
                    Button(action: {
                        //deleteMovieSeries(for: )
                    }) {
                        Image(systemName: "trash")
                            .imageScale(.large)
                            .foregroundColor(.red)
                    }
                }

            }
        }

        .onAppear {
            if let selectedMovieSeries = movieSeriesData.movieSeries.first(where: {$0.title == movieSeries.title}){
                if let episodes = selectedMovieSeries.episodes, !episodes.isEmpty {
                    countdownTimerViewModel.startCountdownTimer(for: nil, nextEpisodeReleaseDate: selectedMovieSeries.nextEpisodeReleaseDate)
                } else {
                    countdownTimerViewModel.startCountdownTimer(for: selectedMovieSeries.releaseDate, nextEpisodeReleaseDate: nil)
                }

                if let episodes = selectedMovieSeries.episodes {
                    self.episodes = episodes
                }
                self.movieSeriesID = selectedMovieSeries.id
            }
            movieSeriesIndex = movieSeriesData.movieSeries.firstIndex(where: { $0.id == movieSeries.id })!
            coverImage = loadCoverImage(for: movieSeries.title)
            dateManager.msReleaseDate = episodes.last?.releaseDate ?? movieSeries.releaseDate
        }

        .onDisappear {
            countdownTimerViewModel.stopTimer()
        }

        .sheet(isPresented: $isEditingSheetPresented) {

            EditableEpisodeDetailsView(movieSeriesData: movieSeriesData, episodes: $episodes, episode: $selectedEpisodeForEditing, isEditingEpisode: $isEditingSheetPresented, countdownTimerViewModel: countdownTimerViewModel)
            
            
        }
        .sheet(isPresented: $isAddingEpisode){
            AddEpisodeToExistingMovieSeriesView(movieSeriesData: movieSeriesData, movieSeriesId: $movieSeriesID, episodes: $episodes, isAddingEpisode: $isAddingEpisode,countdownTimerViewModel: countdownTimerViewModel)
                .environmentObject(dateManager)
        }

        .sheet(isPresented: $isAddingMultipleEpisodes){
            //AddMultipleEpisodesView()
        }
        .sheet(isPresented: $isEditingMovieSeries){
            MovieSeriesEditView(movieSeriesData: movieSeriesData, movieSeriesID: $movieSeriesID,isEditingMovieSeries: $isEditingMovieSeries, showDetailsView: $showDetailsView, countdownTimerViewModel: countdownTimerViewModel,MS: movieSeries)
                .onDisappear{
                    showDetailsView = false
                }
        }

    }
    private func deleteMovieSeries(for id: UUID){
        movieSeriesData.movieSeries.removeAll(where: {$0.id == movieSeriesID})
        deleteMovieSeriesFromPlist(for: movieSeriesID)
    }
    private func deleteMovieSeriesFromPlist(for id: UUID) {
        // Assuming "MovieSeries.plist" is your plist file name
        let plistName = "MovieSeries"

        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(plistName).plist")

            // Load the current data from the plist
            if var movieSeries = loadMovieSeriesData(plistName) {
                // Remove the MovieSeries with the matching ID
                movieSeries.removeAll { $0.id == id }

                // Encode and save the updated data back to the plist
                let encoder = PropertyListEncoder()
                do {
                    let data = try encoder.encode(movieSeries)
                    try data.write(to: fileURL)
                } catch {
                    print("Error saving data to \(plistName).plist: \(error)")
                }
            }
        }
    }

    private func loadCoverImage(for title: String) -> UIImage? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(title).png")
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Error loading cover image: \(error)")
            }
        }
        return nil
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
    private func formattedDate(_ date: Date? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        if let date = date {
            return formatter.string(from: date)
        }

        return formatter.string(from: movieSeries.releaseDate)
    }

    private func startCountdownTimer() {
        isTimerRunning = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            countdownText = movieSeries.releaseDateCountdownText
            countdownText = releaseStatusText()
        }
    }

    private func stopCountdownTimer() {
        isTimerRunning = false
    }

    private func releaseStatusText() -> String {
        if movieSeries.type == "movie" {
            if movieSeries.releaseDate > Date() {
                return "Release In: \(formattedTimeUntilRelease(movieSeries.releaseDate))"
            } else {
                return "Released"
            }
        } else if movieSeries.type == "series" {
            if let episodes = movieSeries.episodes, !episodes.isEmpty {
                let sortedEpisodes = episodes.sorted { $0.releaseDate < $1.releaseDate }
                if sortedEpisodes[0].releaseDate > Date() {
                    return "Release In: \(formattedTimeUntilRelease(sortedEpisodes[0].releaseDate))"
                } else {
                    for i in 1..<sortedEpisodes.count {
                        if sortedEpisodes[i].releaseDate > Date() {
                            let timeRemaining = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: sortedEpisodes[i].releaseDate)
                            if let days = timeRemaining.day, let hours = timeRemaining.hour, let minutes = timeRemaining.minute, let seconds = timeRemaining.second {
                                if days > 0 {
                                    return "Next Episode In: \(days)d \(hours)h \(minutes)m \(seconds)s"
                                } else {
                                    return "Next Episode In: \(hours)h \(minutes)m \(seconds)s"
                                }
                            }
                        }
                    }
                    return "All Episodes Released"
                }
            }
        }

        return ""
    }


    private func formattedTimeUntilRelease(_ releaseDate: Date) -> String {
        let timeRemaining = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: releaseDate)

        if let days = timeRemaining.day, let hours = timeRemaining.hour, let minutes = timeRemaining.minute, let seconds = timeRemaining.second {
            if days > 0 {
                return "\(days)d \(hours)h \(minutes)m \(seconds)s"
            } else {
                return "\(hours)h \(minutes)m \(seconds)s"
            }
        }

        return ""
    }

}

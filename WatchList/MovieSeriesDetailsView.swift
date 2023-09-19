import SwiftUI
import Combine

struct MovieSeriesDetailsView: View {
    @State private var swipedEpisode: Episode?

    var movieSeries: MovieSeries
    @ObservedObject var viewModel: MovieSeriesDetailsViewModel
    @ObservedObject var countdownTimerViewModel: CountdownTimerViewModel
    @State private var countdownText: String = ""
    @State private var isTimerRunning = false
    @State private var selectedEpisode: Episode?
    @State private var isEditingEpisode = false
    @State private var selectedEpisodeForEditing: Episode?
    @State private var isEditingSheetPresented = false
    @State private var releaseStatus: String = ""
    
    //var MovieSeries: MovieSeries
    private var timer: Timer?

    init(movieSeries: MovieSeries) {
        self.movieSeries = movieSeries
        self.viewModel = MovieSeriesDetailsViewModel(episodes: movieSeries.episodes ?? [])
        self.countdownTimerViewModel = CountdownTimerViewModel()
        
        if movieSeries.type == "movie" {
            countdownTimerViewModel.startCountdownTimer(for: movieSeries.releaseDate, nextEpisodeReleaseDate: nil)
        } else if movieSeries.type == "series", let nextEpisodeReleaseDate = movieSeries.nextEpisodeReleaseDate {
            countdownTimerViewModel.startCountdownTimer(for: nil, nextEpisodeReleaseDate: nextEpisodeReleaseDate)
        }
    }


    var body: some View {
        VStack {
            ZStack {
                Image(movieSeries.imageFilename)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.8)
                    .cornerRadius(15)
                    .frame(height: 200)
                    .padding(.top, 50)

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

        

            Text("Type: \(movieSeries.type)")
                .font(.subheadline)
                .padding()

            if movieSeries.type == "series" {
                Divider()
                Text("Episodes: \(viewModel.numberOfEpisodes)")
                    .font(.headline)
                    .padding()
                if let episodes = movieSeries.episodes, !episodes.isEmpty {
                    let sortedEpisodes = episodes.sorted { $0.releaseDate < $1.releaseDate }
                    if sortedEpisodes[0].releaseDate > Date() {
                        Text("Next Episode: Episode \(sortedEpisodes[0].episodeNumber): \(sortedEpisodes[0].title)")
                            .font(.headline)
                            .padding(.top)
                            .padding(.bottom)
                    }
                }
                
                List {
                    ForEach(viewModel.episodes) { episode in
                        Button(action: {
                            selectedEpisodeForEditing = episode
                            isEditingSheetPresented = true
                        }) {
                            EpisodeRowView(episode: episode, formattedDate: formattedDate)
                        }
                    }
                }

            }

            Spacer()
        }
        .navigationBarTitle("Details", displayMode: .inline)
        .onAppear {
            countdownTimerViewModel.startCountdownTimer(for: movieSeries.releaseDate, nextEpisodeReleaseDate: movieSeries.nextEpisodeReleaseDate)
        }
        .onDisappear {
            countdownTimerViewModel.stopTimer()
        }

        .sheet(item: $selectedEpisodeForEditing) { episode in
            EditableEpisodeDetailsView(episode: $selectedEpisodeForEditing, isEditingEpisode: $isEditingSheetPresented)

        }
    }


    private func formattedDate(_ date: Date? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

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

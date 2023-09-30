
import SwiftUI

struct MovieTimerView: View {
    var movieSeries: MovieSeries
    @ObservedObject var movieSeriesData: MovieSeriesData
    @ObservedObject var countdownTimerViewModel: CountdownTimerViewModel = CountdownTimerViewModel.shared
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var nextEpisode: Episode? = nil
    @State private var coverImage: UIImage? = nil
    @State private var movieSeriesIndex: Int = 0
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {

                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: geometry.size.width)
                        .cornerRadius(15)
                        .opacity(0.8)
                    // Image as the background
                    
                    if !movieSeriesData.getImageFilename(byId: movieSeries.id)!.isEmpty {
                        Image(uiImage: movieSeriesData.coverImages[movieSeriesIndex] ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(15)
                            .opacity(0.8)
                    } else {
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.8)
                            .cornerRadius(15)
                            .frame(height: 200)
                            .padding(.top, 50)
                    }



                    VStack {
                        Text(movieSeries.title)
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                            .shadow(color: .black, radius: 1)


                        Text(formatRemainingTime())
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .shadow(color: .black, radius: 1)

                        if movieSeries.type == "series" {
                            if let episode = movieSeries.nextEpisode {
                                Text("Next Episode: Episode \(episode.episodeNumber): \(episode.title)")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .padding()
                                    .shadow(color: .black, radius: 1)

                            }
                        }
                    }
                    .padding(8)
                }
                .onAppear {
                    let cellSize = CGSize(width: geometry.size.width, height: 200)
                    print("Cell Size: \(cellSize)")
                }
            }
        }
        .frame(height: 200)
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets())
        .onAppear {
            movieSeriesIndex = movieSeriesData.movieSeries.firstIndex(where: { $0.id == movieSeries.id })!

            updateRemainingTime()
            coverImage = loadCoverImage(for: movieSeries.title)
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateRemainingTime()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
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

    private func updateRemainingTime() {
        remainingTime = calculateRemainingTime()
        nextEpisode = findNextEpisode()
    }

    private func calculateRemainingTime() -> TimeInterval {
        let currentDate = Date()
        let releaseDate: Date

        if movieSeries.type == "series" {
            releaseDate = nextEpisode?.releaseDate ?? movieSeries.releaseDate
        } else {
            releaseDate = movieSeries.releaseDate
        }

        if currentDate >= releaseDate {
            return 0
        } else {
            return releaseDate.timeIntervalSince(currentDate)
        }
    }

    private func formatRemainingTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full

        return formatter.string(from: remainingTime) ?? ""
    }

    private func findNextEpisode() -> Episode? {
        guard movieSeries.type == "series", let episodes = movieSeries.episodes else {
            return nil
        }

        let currentDate = Date()
        let sortedEpisodes = episodes.sorted { $0.releaseDate < $1.releaseDate }

        for episode in sortedEpisodes {
            if episode.releaseDate > currentDate {
                return episode
            }
        }

        return nil
    }
}


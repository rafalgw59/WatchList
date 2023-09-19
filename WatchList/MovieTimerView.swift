
import SwiftUI

struct MovieTimerView: View {
    var movieSeries: MovieSeries

    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var nextEpisode: Episode? = nil

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
                    Image(movieSeries.imageFilename)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(15)
                        .opacity(0.8)


                    VStack {
                        Text(movieSeries.title)
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()

                        Text(formatRemainingTime())
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                        
                        if movieSeries.type == "series" {
                            if let episode = nextEpisode {
                                Text("Next Episode: Episode \(episode.episodeNumber): \(episode.title)")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .padding()
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
            updateRemainingTime()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateRemainingTime()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
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


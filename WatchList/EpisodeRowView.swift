import SwiftUI
struct EpisodeRowView: View {
    var episode: Episode
    var formattedDate: (Date?) -> String
    var body: some View {
        VStack(alignment: .leading) {
            Text("Episode \(episode.episodeNumber): \(episode.title)")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Release Date: \(formattedDate(episode.releaseDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()

       

    }

}

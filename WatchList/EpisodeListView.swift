
import SwiftUI

struct EpisodeListView: View {
    @ObservedObject var viewModel: MovieSeriesDetailsViewModel
    @Binding var selectedEpisode: Episode?
    @Binding var isEditingEpisode: Bool
    @State private var isEditingSheetPresented = false

    var formattedDate: (Date?) -> String

    init(viewModel: MovieSeriesDetailsViewModel, selectedEpisode: Binding<Episode?>, isEditingEpisode: Binding<Bool>, formattedDate: @escaping (Date?) -> String) {
        self.viewModel = viewModel
        self._selectedEpisode = selectedEpisode
        self._isEditingEpisode = isEditingEpisode
        self.formattedDate = formattedDate
    }

    var body: some View {
        List {
            if let nearestEpisode = viewModel.nearestEpisode {
                VStack(alignment: .leading) {
                    Text("Next Episode: Episode \(nearestEpisode.episodeNumber): \(nearestEpisode.title)")
                        .font(.headline)
                        .padding(.top)
                    Text("Release Date: \(formattedDate(nearestEpisode.releaseDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }

            ForEach(viewModel.episodes) { episode in
                Button(action: {
                    selectedEpisode = episode
                    isEditingSheetPresented.toggle()
                }) {
                    EpisodeRowView(episode: episode, formattedDate: formattedDate)
                }
            }
        }
        .sheet(isPresented: $isEditingSheetPresented) {
            if let selectedEpisode = selectedEpisode {
                EditableEpisodeDetailsView(episode: $selectedEpisode, isEditingEpisode: $isEditingEpisode)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}





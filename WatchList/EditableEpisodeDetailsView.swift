
import SwiftUI

struct EditableEpisodeDetailsView: View {
    @Binding var episode: Episode?
    @Binding var isEditingEpisode: Bool
    
    @State private var episodeNumberText: String
    @State private var title: String
    @State private var releaseDate: Date
    
    init(episode: Binding<Episode?>, isEditingEpisode: Binding<Bool>) {
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
                        }
                        isEditingEpisode = false
                    }
                    .foregroundColor(.blue)

                    Button("Delete Episode") {
                        episode = nil
                        isEditingEpisode = false 
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Episode")
        }
    }
}







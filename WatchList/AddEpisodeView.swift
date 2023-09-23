
import SwiftUI

struct AddEpisodeView: View {
//    @Binding var episode: Episode?
    @Binding var episodes: [Episode]
    @Binding var isAddingEpisode: Bool
    @State private var title: String = ""
    @State private var episodeNumber: Int = 0
    @State private var releaseDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Episode Details")) {
                    TextField("Episode Title", text: $title)
                    Stepper("Episode Number: \(episodeNumber)", value: $episodeNumber)
                        .keyboardType(.numberPad) // Allow only numeric input
                    DatePicker("Release Date", selection: $releaseDate, displayedComponents: .date)
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
        let newEpisode = Episode(episodeNumber: episodeNumber, title: title, releaseDate: releaseDate)
        episodes.append(newEpisode)
        isAddingEpisode = false
    }

}

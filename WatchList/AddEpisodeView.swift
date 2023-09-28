
import SwiftUI

struct AddEpisodeView: View {
    @ObservedObject var movieSeriesData: MovieSeriesData
    @Binding var episodes: [Episode]
    @Binding var isAddingEpisode: Bool
    @Binding var newMovieSeries: MovieSeries
    @State private var id: UUID = UUID()
    @State private var title: String = ""
    //@State private var episodeNumber: Int = 1
    @State private var releaseDate: Date = Date()
    @EnvironmentObject var dateManager: DateManager
    @State private var calculatedReleaseDate: Date = Date()
    @State private var episodeNumber: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Episode Details")) {
                    TextField("Episode Title", text: $title)
                    Picker("Episode:", selection: $episodeNumber){
                        ForEach(0..<50){
                            Text("Episode \($0)")
                        }
                    }
                    //                        .keyboardType(.numberPad) // Allow only numeric input
                    DatePicker("Release Date", selection: $calculatedReleaseDate)
                    Text("\(calculatedReleaseDate)")
                    
                }
                Section(header: Text("Episodes")){
                    List{
                        ForEach(episodes) { episode in
                            Text(episode.title)
                        }
                    }
                }
            }
            
            .navigationBarItems(
                leading: Button("Save") {
                    saveEpisode()
                }
                    .disabled(title.isEmpty)
            )
            .onAppear{
                episodeNumber = episodes.count + 1
                title = "Episode \(episodeNumber)"
                calculateReleaseDate()
            }
        }
 
    }

    private func saveEpisode() {
        let newEpisode = Episode(episodeNumber: episodeNumber, title: title, releaseDate: calculatedReleaseDate, id: id)
        episodes.append(newEpisode)
        isAddingEpisode = false
    }
    private func calculateReleaseDate() {
        let calendar = Calendar.current
        if let startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: dateManager.msReleaseDate) {
            let numberOfWeeksToAdd = episodeNumber - 1// Adjust this as needed
            if let calculatedDate = calendar.date(byAdding: .weekOfYear, value: numberOfWeeksToAdd, to: startDate) {
                calculatedReleaseDate = calculatedDate
            }
        }
    }


}


import SwiftUI

@main
struct WatchListApp: App {
    @StateObject var movieSeriesData = MovieSeriesData()
    var body: some Scene {
        WindowGroup {
            ContentView(movieSeriesData: movieSeriesData)
        }
    }
}

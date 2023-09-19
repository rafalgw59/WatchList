
import SwiftUI
import Mantis

struct ContentView: View {
    
    @State private var showDetailsSheet = false
    @State private var movieSeriesData: [MovieSeries] = []
    @State private var selectedMovieSeries: MovieSeries? = nil
    @State private var showAddMovieSeries = false
//    @State private var cropperType: ImageCropperType = .normal
//    @State private var cropShapeType: Mantis.CropShapeType = .rect
//    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .canUseMultiplePresetFixedRatio()
    @State private var selectedImage: UIImage? = nil
    @State private var showCropScreen = false
    var timer = Timer()
    
    var body: some View {
        NavigationView {
            VStack {
                List(movieSeriesData, id: \.title) { movieSeries in
                    MovieTimerView(movieSeries: movieSeries)
                        .onTapGesture {
                            showDetailsSheet.toggle()
                            selectedMovieSeries = movieSeries
                            showDetailsSheet = true
                        }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)

                Button(action: {
                    showAddMovieSeries = true
                   
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .padding()
                .sheet(isPresented: $showAddMovieSeries){
                    AddMovieSeriesView(movieSeriesData: $movieSeriesData)
                    
                }
            }
            .navigationBarTitle("My Movies and Series")

            .sheet(item: $selectedMovieSeries){ MovieSeries in
                MovieSeriesDetailsView(movieSeries: MovieSeries)

            }
            .onAppear {
                if let data = loadMovieSeriesData("MovieSeriesData") {
                    movieSeriesData = data
                }
            }
        }
    }
       
    
    private func loadMovieSeriesData(_ plistName: String) -> [MovieSeries]? {
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
           let data = FileManager.default.contents(atPath: path) {
            do {
                let decoder = PropertyListDecoder()
                let movieSeries = try decoder.decode([MovieSeries].self, from: data)
                return movieSeries
            } catch {
                print("Error decoding data from \(plistName).plist: \(error)")
            }
        }
        return nil
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



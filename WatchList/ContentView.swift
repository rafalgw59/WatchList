
import SwiftUI
import Mantis

struct ContentView: View {
    @ObservedObject var movieSeriesData: MovieSeriesData
    @ObservedObject var countdownTimerViewModel: CountdownTimerViewModel = CountdownTimerViewModel.shared
    @State private var showDetailsSheet: Bool = false
//    @State private var movieSeriesData: [MovieSeries] = []
    @State private var selectedMovieSeriesID: IdentifiableUUID?
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
                List(movieSeriesData.movieSeries, id: \.id) { movieSeries in
                    MovieTimerView(movieSeries: movieSeries, movieSeriesData: movieSeriesData)
                        .onTapGesture {
                            //showDetailsSheet.toggle()
                            selectedMovieSeriesID = IdentifiableUUID(id: movieSeries.id)
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
                    AddMovieSeriesView(movieSeriesData: movieSeriesData, isAddingMovieSeries: $showAddMovieSeries)
                    
                }
            }
            .navigationBarTitle("My Movies and Series")

            .sheet(item: $selectedMovieSeriesID){ identifiableUUID in
                MovieSeriesDetailsView(movieSeriesID: identifiableUUID.id, movieSeriesData: movieSeriesData,showDetailsView: $showDetailsSheet,selectedMovieSeriesID: $selectedMovieSeriesID)

            }
//            .sheet(isPresented: $showDetailsSheet){
//                if let id = selectedMovieSeriesID {
//                    MovieSeriesDetailsView(movieSeriesID: id.id, movieSeriesData: movieSeriesData, showDetailsView: $showDetailsSheet)
//                } else {
//                    EmptyView()
//                }
//            }

            .onAppear {
                if let data = loadMovieSeriesDataFromFile("MovieSeriesData") {
                    self.movieSeriesData.movieSeries = data
                    self.movieSeriesData.coverImages = movieSeriesData.movieSeries.compactMap { ms in
                        let coverFilename = ms.imageFilename
                            
                        return loadCoverImage(for: coverFilename)
                            
                       
                    }
                    
                }
            }
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
    
    
    private func loadMovieSeriesDataFromFile(_ plistName: String) -> [MovieSeries]? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(plistName).plist")
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = PropertyListDecoder()
                let movieSeriesArray = try decoder.decode([MovieSeries].self,from: data)
                return movieSeriesArray
            } catch {
                print("Error loading cover image: \(error)")
            }
        }
        return nil
    }
}

struct IdentifiableUUID: Identifiable {
    var id: UUID
}




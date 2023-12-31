import SwiftUI
import Mantis


struct AddMovieSeriesView: View {
    @ObservedObject var movieSeriesData: MovieSeriesData
    @Binding var isAddingMovieSeries: Bool
    @State private var newMovieSeries: MovieSeries = MovieSeries(title: "", releaseDate: Date(), type: "", imageFilename: "", id: UUID())
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showCropScreen = false
    @State private var showEpisodeFields = false
    @State private var showAddEpisodeSheet = false
    @State private var episodes: [Episode] = []
    @State private var editingEpisode: Episode?
    @StateObject var dateManager = DateManager()
    @State var datePicked = Date()
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geometry in
                
                
                Form {
                    
                    Section(header: Text("Cover Image")) {
                        
                        if let selectedImage = selectedImage {
                            ZStack{
                                Rectangle()
                                    .fill(.clear)
                                    .frame(maxWidth: geometry.size.width)
                                    .cornerRadius(15)
                                    .opacity(0.8)
                                
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                //.opacity(0.8)
                                    .cornerRadius(15)
                                    .frame(height: 200)
                                //.padding(.top, 50)
                                    .onTapGesture {
                                        showImagePicker = true
                                    }
                            }
                        }else {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Select an Image")
                                }
                            }
                            .font(.title)
                            .padding()
                            .frame(height: 200)
                        }
                        

                    }
                    
                    Section(header: Text("Movie/Series Details")) {
                        TextField("Title", text: $newMovieSeries.title)
                        DatePicker("Release Date", selection: $newMovieSeries.releaseDate)
                        
                        Picker("Type", selection: $newMovieSeries.type) {
                            Text("Movie").tag("movie")
                            Text("Series").tag("series")
                        }
                        if newMovieSeries.type == "series" {
                            Button("Add Episode") {
                                dateManager.msReleaseDate = newMovieSeries.releaseDate
                                showAddEpisodeSheet = true
                            }

                        }

                    }
                    if newMovieSeries.type == "series"{
                        Section(header: Text("Episodes")){
                            List{
                                ForEach(episodes){ episode in
                                    Button(action: {
                                        editingEpisode = episode
                                        //showAddEpisodeSheet = true
                                    }) {
                                        VStack(alignment: .leading){
                                            Text("Episode \(episode.episodeNumber): \(episode.title)")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text("Release Date: \(formattedDate(episode.releaseDate))")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                }


            }
            
            
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(image: $selectedImage,isPresented: $showImagePicker) { selectedImage in
                    self.selectedImage = selectedImage
                    self.showImagePicker = false
                }
                .onDisappear {
                    self.showCropScreen = true
                }
            }
            .fullScreenCover(isPresented: $showCropScreen, content: {
                ImageCropper(image: $selectedImage)
                .ignoresSafeArea()
                .onDisappear{
                    //add imageFilename to plist/model, imageFilename is title of movie/series
                    if let selectedImage = selectedImage {
                        let imageName = newMovieSeries.title
                        //saveImageToAssets(image: selectedImage, imageName: imageName)
                    }
                    //selectedImage = $newMovieSeries.imageFilename
                    //add image to assets
                    //selectedImage =
                }
            })
            .navigationBarTitle("Add Movie/Series", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    newMovieSeries.episodes = episodes
                    saveMovieSeries()
                
                
                
                
                }) {
                    Text("Add")
                }
                .disabled(!isFormValid())
            )
        }
        .sheet(isPresented: $showAddEpisodeSheet){
            AddEpisodeView(movieSeriesData: movieSeriesData ,episodes: $episodes, isAddingEpisode: $showAddEpisodeSheet, newMovieSeries: $newMovieSeries)
                .environmentObject(dateManager)
        }

    }

    private func saveMovieSeries() {
        newMovieSeries.imageFilename = newMovieSeries.title
        newMovieSeries.id = UUID()
        saveImage(file: newMovieSeries.imageFilename)
        movieSeriesData.coverImages.append(selectedImage)
        var movieSeriesArray = loadMovieSeriesData("MovieSeriesData")
        movieSeriesArray.append(newMovieSeries)
        saveMovieSeriesData(movieSeriesArray, plistName: "MovieSeriesData")
        movieSeriesData.movieSeries = movieSeriesArray
    
        isAddingMovieSeries = false
    }
    
    private func formattedDate(_ date: Date? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: date!)
    }
    
    func saveImage(file: String) {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(file)
                .appendingPathExtension("png")
            try selectedImage!.pngData()?.write(to: fileURL)
        } catch {
            print("could not create file: \(file)")
        }
    }
    private func isFormValid() -> Bool {
        return !newMovieSeries.title.isEmpty && !newMovieSeries.type.isEmpty
    }
    private func loadMovieSeriesData(_ plistName: String) -> [MovieSeries] {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(plistName).plist")
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = PropertyListDecoder()
                let movieSeries = try decoder.decode([MovieSeries].self, from: data)
                return movieSeries
            } catch {
                print("Error loading data from \(plistName).plist: \(error)")
                return []
            }
        } else {
            let defaultMovieSeriesData: [MovieSeries] = []
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(defaultMovieSeriesData)
                try data.write(to: fileURL)
                return defaultMovieSeriesData
            } catch {
                print("Error creating and saving \(plistName).plist: \(error)")
                return []
            }
        }
    }

    private func saveMovieSeriesData(_ movieSeries: [MovieSeries], plistName: String) {
        let encoder = PropertyListEncoder()
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(plistName).plist")
            do {
                let data = try encoder.encode(movieSeries)
                try data.write(to: fileURL)
                print("Movie series data saved to \(fileURL.path)")
            } catch {
                print("Error saving movie series data: \(error)")
            }
        }
    }
}

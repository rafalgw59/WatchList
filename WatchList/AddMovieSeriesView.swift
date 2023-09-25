import SwiftUI
import Mantis

struct AddMovieSeriesView: View {
    @Binding var movieSeriesData: [MovieSeries]
    @Binding var isAddingMovieSeries: Bool
    @State private var newMovieSeries: MovieSeries = MovieSeries(title: "", releaseDate: Date(), type: "", imageFilename: "", id: UUID())
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showCropScreen = false
    @State private var showEpisodeFields = false
    @State private var showAddEpisodeSheet = false
    @State private var episodes: [Episode] = []
    @State private var editingEpisode: Episode?
    //@State private var movieSeriesData: [MovieSeries]
    

//    @State private var cropShapeType: Mantis.CropShapeType = .rect
////    @State private var cropShapeType: Mantis.CropShapeType = .path(points: [CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 1),CGPoint(x: 1, y: 1),CGPoint(x: 1, y: 0)],maskOnly: true)
//
//    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 16.0 / 9.0)
//    @State private var cropperType: ImageCropperType = .noRotaionDial

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
                                showAddEpisodeSheet = true
                            }
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
            
            AddEpisodeView(episodes: $episodes, isAddingEpisode: $showAddEpisodeSheet)

        }
//        .sheet(isPresented: $showCropScreen) {
//            // Present the ImageCropper with the selected image and predefined crop settings
//            ImageCropper(image: $selectedImage, cropShapeType: cropShapeType, presetFixedRatioType: presetFixedRatioType, type: cropperType)
//        }
    }

    private func saveMovieSeries() {
        newMovieSeries.imageFilename = newMovieSeries.title
        saveImage(file: newMovieSeries.imageFilename)
        movieSeriesData.append(newMovieSeries)
        //saving data to plist
        let encoder = PropertyListEncoder()
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("MovieSeriesData.plist")
            do {
                let data = try encoder.encode(movieSeriesData)
                try data.write(to: fileURL)
                print("Movie series data saved to \(fileURL.path)")
            } catch {
                print("Error saving movie series data: \(error)")
            }
        }
        isAddingMovieSeries = false
    }
    
    private func formattedDate(_ date: Date? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .full

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
}

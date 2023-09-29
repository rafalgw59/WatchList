import SwiftUI
import Combine
import Mantis

struct MovieSeriesEditView: View {
    
    @ObservedObject var movieSeriesData: MovieSeriesData
    @Binding var movieSeriesID: UUID
    @Binding var isEditingMovieSeries: Bool
    @Binding var showDetailsView: Bool
    @ObservedObject var countdownTimerViewModel: CountdownTimerViewModel = CountdownTimerViewModel.shared
    @State private var showImagePicker = false
    @State private var movieSeriesIndex: Int = 0
    @State private var showCropScreen = false
    @State private var oldImageName: String =  ""
    @State private var oldImage: UIImage?
    var MS: MovieSeries
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                Form{
                    Section(header: Text("Image")){
                        if !movieSeriesData.getImageFilename(byId: movieSeriesID)!.isEmpty {
                            ZStack{
                                Rectangle()
                                    .fill(.clear)
                                    .frame(maxWidth: geometry.size.width)
                                    .cornerRadius(15)
                                    .opacity(0.8)
                                
                                Image(uiImage: movieSeriesData.coverImages[movieSeriesIndex] ?? UIImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(15)
                                    .frame(height: 200)
                                    .onTapGesture {
                                        showImagePicker = true
                                    }
                            }
                        } else {
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
                    Section(header: Text("Details")){
                        TextField("Title", text: $movieSeriesData.movieSeries[movieSeriesIndex].title )
                        DatePicker("Release Date", selection: $movieSeriesData.movieSeries[movieSeriesIndex].releaseDate)
                    }
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarLeading){
                    Button(action: {
                        isEditingMovieSeries = false
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarTrailing){
                    Button(action: {
                        print(oldImage)
                        print(movieSeriesData.coverImages[movieSeriesIndex])
                        saveChanges()
                        isEditingMovieSeries = false
                        showDetailsView = false
                    }) {
                        Text("Done")
                            
                    }
                }

            }
        }
        .onAppear {
            movieSeriesIndex = movieSeriesData.movieSeries.firstIndex(where: { $0.id == movieSeriesID })!
            oldImageName = movieSeriesData.movieSeries[movieSeriesIndex].imageFilename
            oldImage = movieSeriesData.coverImages[movieSeriesIndex]

        }
        .onDisappear {
            isEditingMovieSeries = false
            showDetailsView = false
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $movieSeriesData.coverImages[movieSeriesIndex],isPresented: $showImagePicker) { selectedImage in
                movieSeriesData.coverImages[movieSeriesIndex] = selectedImage
                self.showImagePicker = false
            }
            .onDisappear {
                self.showCropScreen = true
            }
        }
        .fullScreenCover(isPresented: $showCropScreen, content: {
            ImageCropper(image: $movieSeriesData.coverImages[movieSeriesIndex])
            .ignoresSafeArea()
            .onDisappear{
                if let selectedImage = movieSeriesData.coverImages[movieSeriesIndex] {
                    let imageName = movieSeriesData.movieSeries.first { $0.id == movieSeriesID }!.title
                }

            }
        })
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
    private func saveChanges(){
        if movieSeriesData.coverImages[movieSeriesIndex] != oldImage {
            deleteImage(named: oldImageName)
            
            saveImage(file: movieSeriesData.movieSeries[movieSeriesIndex].title)
        }
        
        if movieSeriesData.movieSeries[movieSeriesIndex].title != oldImageName {
            renameImage(from: oldImageName, to: movieSeriesData.movieSeries[movieSeriesIndex].title)
            
            movieSeriesData.movieSeries[movieSeriesIndex].imageFilename = movieSeriesData.movieSeries[movieSeriesIndex].title
        }
        
        savetoFile(movieSeriesData.movieSeries, plistName: "MovieSeriesData")
        updateTimerIfNeeded()
    }

    func saveImage(file: String) {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(file)
                .appendingPathExtension("png")
            try movieSeriesData.coverImages[movieSeriesIndex]!.pngData()?.write(to: fileURL)
        } catch {
            print("could not create file: \(file)")
        }
    }
    func renameImage(from currentName: String, to newName: String) {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let currentURL = documentsDirectory.appendingPathComponent(currentName).appendingPathExtension("png")
            
            let newURL = documentsDirectory.appendingPathComponent(newName).appendingPathExtension("png")
            
            try FileManager.default.moveItem(at: currentURL, to: newURL)
        } catch {
            print("Error renaming image: \(error)")
        }
    }
    func deleteImage(named imageName: String) {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // Create the URL of the image file to be deleted
            let imageURL = documentsDirectory.appendingPathComponent(imageName).appendingPathExtension("png")
            
            // Check if the file exists before attempting to delete
            if FileManager.default.fileExists(atPath: imageURL.path) {
                try FileManager.default.removeItem(at: imageURL)
                print("Image '\(imageName)' deleted successfully.")
            } else {
                print("Image '\(imageName)' does not exist.")
            }
        } catch {
            print("Error deleting image '\(imageName)': \(error)")
        }
    }
    private func updateTimerIfNeeded() {
        // Check if the release date has changed and there are no episodes
        if movieSeriesData.movieSeries[movieSeriesIndex].releaseDate != movieSeriesData.movieSeries[movieSeriesIndex].releaseDate &&
            movieSeriesData.movieSeries[movieSeriesIndex].episodes!.isEmpty {
            
            // Start the countdown timer for the new release date
            countdownTimerViewModel.startCountdownTimer(for: movieSeriesData.movieSeries[movieSeriesIndex].releaseDate, nextEpisodeReleaseDate: nil)
        }
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
    private func savetoFile(_ movieSeries: [MovieSeries], plistName: String){
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


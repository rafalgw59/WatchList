import SwiftUI
import Mantis

struct AddMovieSeriesView: View {
    @Binding var movieSeriesData: [MovieSeries]
    
    @State private var newMovieSeries: MovieSeries = MovieSeries(title: "", releaseDate: Date(), type: "", imageFilename: "")
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showCropScreen = false
    
    
    

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
                        
                        
                        
                        //                    if let selectedImage = selectedImage {
                        //                        Image(uiImage: selectedImage)
                        //                            .resizable()
                        //                            .scaledToFit()
                        //                            .frame(height: 200)
                        //                    }
                    }
                    
                    Section(header: Text("Movie/Series Details")) {
                        TextField("Title", text: $newMovieSeries.title)
                        DatePicker("Release Date", selection: $newMovieSeries.releaseDate, displayedComponents: .date)
                        
                        Picker("Type", selection: $newMovieSeries.type) {
                            Text("Movie").tag("movie")
                            Text("Series").tag("series")
                        }
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(image: $selectedImage,isPresented: $showImagePicker) { selectedImage in
                    self.selectedImage = selectedImage
                    self.showImagePicker = false
//                    self.showCropScreen = true
                }
                .onDisappear {
                    self.showCropScreen = true
                }
            }
            .fullScreenCover(isPresented: $showCropScreen, content: {
                ImageCropper(image: $selectedImage)
                .ignoresSafeArea()
            })
            .navigationBarTitle("Add Movie/Series", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    saveMovieSeries()
                }) {
                    Text("Add")
                }
                .disabled(!isFormValid())
            )
        }
//        .sheet(isPresented: $showCropScreen) {
//            // Present the ImageCropper with the selected image and predefined crop settings
//            ImageCropper(image: $selectedImage, cropShapeType: cropShapeType, presetFixedRatioType: presetFixedRatioType, type: cropperType)
//        }
    }

    private func saveMovieSeries() {
        movieSeriesData.append(newMovieSeries)
    }

    private func isFormValid() -> Bool {
        return !newMovieSeries.title.isEmpty && !newMovieSeries.type.isEmpty
    }
}

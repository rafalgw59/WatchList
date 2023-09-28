import SwiftUI
import Combine
import Mantis

struct MovieSeriesEditView: View {
    
    @ObservedObject var movieSeriesData: MovieSeriesData
    @Binding var movieSeriesID: UUID
    @Binding var isEditingMovieSeries: Bool
    @ObservedObject var countdownTimerViewModel: CountdownTimerViewModel = CountdownTimerViewModel.shared
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                Form{
                    Section(header: Text(movieSeriesData.movieSeries.first { $0.id == movieSeriesID }?.title ?? "")){
                        if let selectedImage = selectedImage{
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
                        TextField("Title", text: $movieSeriesData.movieSeries.first { $0.id == movieSeriesID }!.title )
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
                        Text("back")
                           
                    }
                }
                ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarTrailing){
                    Button(action: {
                        //deleteMovieSeries(for: )
                    }) {
                        Text("done")
                            
                    }
                }

            }
        }
        .onAppear {
            selectedImage = UIImage(named: movieSeriesData.movieSeries.first { $0.id == movieSeriesID }!.imageFilename)
        }
    }
        
}


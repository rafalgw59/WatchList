//
//  CustomImagePicker.swift
//  WatchList
//
//  Created by Rafał Gawlik on 22/09/2023.
//


import SwiftUI
import Mantis

struct CustomImagePicker: View {
    @Binding private var image: UIImage?
    @State private var showingCropper = false
    @State private var showingCropShapeList = false
    @State private var cropShapeType: Mantis.CropShapeType = .rect
    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .canUseMultiplePresetFixedRatio()
    @State private var cropperType: ImageCropperType = .normal
    @State private var contentHeight: CGFloat = 0
    
    @State private var showImagePicker = false
//    @State private var showCamera = false
    @State private var showSourceTypeSelection = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(image: Binding<UIImage?>) {
        _image = image
    }

    var body: some View {
        AdaptiveStack {
            createImageHolder()
            createFeatureDemoList()
        }
        .fullScreenCover(isPresented: $showingCropper, content: {
            ImageCropper(image: $image,
                         cropShapeType: cropShapeType,
                         presetFixedRatioType: presetFixedRatioType,
                         type: cropperType)
            .onDisappear(perform: reset)
            .ignoresSafeArea()
        })
//        .sheet(isPresented: $showingCropShapeList) {
//            CropShapeListView(cropShapeType: $cropShapeType, selectedType: $showingCropper)
//        }
//        .sheet(isPresented: $showSourceTypeSelection) {
//            SourceTypeSelectionView(showSourceTypeSelection: $showSourceTypeSelection, showCamera: $showCamera, showImagePicker: $showImagePicker)
//        }
//        .sheet(isPresented: $showCamera) {
//            CameraView(image: $image)
//        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $image, isPresented: $showImagePicker)
        }

        .onAppear{
            showImagePicker = true
        }
        .navigationBarTitle("Custom Image Picker")
        .navigationBarItems(trailing:
                                Button("Crop"){
            showingCropper = true
        }
        )
    }
    
    func reset() {
        cropShapeType = .rect
        presetFixedRatioType = .canUseMultiplePresetFixedRatio()
        cropperType = .normal
    }
    
    func createImageHolder() -> some View {
        VStack {
            Spacer()
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300, alignment: .center)
            } else {
                Image(systemName: "photo") // You can use any default image here
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300, alignment: .center)
            }
            HStack {
                Button("Choose Image") {
                    showSourceTypeSelection = true
                }
                .font(.title)
                Button("Reset Image") {
                    image = UIImage(named: "sunflower")!
                }
                .font(.title)
            }
            Spacer()
        }
    }

    
    func createFeatureDemoList() -> some View {
        ScrollView {
            if horizontalSizeClass == .regular {
                createFeatureDemoListContent()
                    .frame(maxWidth: .infinity, minHeight: 0, maxHeight: contentHeight < UIScreen.main.bounds.height ? .infinity : nil)
                    .padding(.vertical, (UIScreen.main.bounds.height - contentHeight) / 2)
            } else {
                createFeatureDemoListContent()
            }
        }
    }
    
    func createFeatureDemoListContent() -> some View {
        VStack(alignment: .leading) {
            Spacer()
            Button("Normal Crop") {
                showingCropper = true
            }.font(.title)
            Button("Select crop shape") {
                showingCropShapeList = true
            }.font(.title)
            Button("Keep 1:1 ratio") {
                presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
                showingCropper = true
            }.font(.title)
            Button("Hide Rotation Dial") {
                cropperType = .noRotaionDial
                showingCropper = true
            }.font(.title)
            Button("Hide Attached Toolbar") {
                cropperType = .noAttachedToolbar
                showingCropper = true
            }.font(.title)
            Spacer()
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        self.contentHeight = proxy.size.height
                    }
            }
        )
    }
}

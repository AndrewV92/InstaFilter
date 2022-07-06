//
//  ContentView.swift
//  InstaFilter
//
//  Created by Андрей Воробьев on 06.07.2022.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Текущий фильтр : \(currentFilter.name)")
                        .padding(4)
                    Spacer()
                }
                ZStack {
                    Rectangle()
                        .fill(.white)
                    
                    Text("Выберите фотографию")
                        .foregroundColor(.gray)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }.onTapGesture {
                    showingImagePicker = true
                }
                
                HStack {
                    Text("Интенсивность")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in applyProcessing() }
                }
                .padding(.vertical)
                
                HStack {
                    Button("Сменить фильтр") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Сохранить", action: save)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Инстафильтр")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Выберите фильтр", isPresented: $showingFilterSheet) {
                Button("Мозаика") { setFilter(CIFilter.crystallize()) }
                Button("Края") { setFilter(CIFilter.edges()) }
                Button("Гаусс") { setFilter(CIFilter.gaussianBlur()) }
                Button("Пиксельный") { setFilter(CIFilter.pixellate()) }
                Button("Сепия") { setFilter(CIFilter.sepiaTone()) }
                Button("Резкость") { setFilter(CIFilter.unsharpMask()) }
                Button("Виньетка") { setFilter(CIFilter.vignette()) }
                Button("Отмена", role: .cancel) { }
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}








struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

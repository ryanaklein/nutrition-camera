//
//  ImageView.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/1/24.
//  Originally taken from https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
//

import SwiftUI

struct ImageView: View {
    
    @Environment(\.modelContext) private var context
    
    let imageData: Data
    @Binding var path: NavigationPath
 
    @State private var imageOCR = OCR()
    @State private var languageCorrection = false
    @State private var selectedMacro = "calories"
    @State private var selectedLanguage = Locale.Language(identifier: "en-US")
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    @State private var saving = false
    @State private var saved = false

    var recognitionLevels = ["Accurate", "Fast"]

    /// Watch for changes to the request settings.
    var settingChanges: [String] {[
        languageCorrection.description,
        imageData.description,
        selectedLanguage.maximalIdentifier
    ]}

    var body: some View {
        
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: ContentView()) {
                        Text("Retake Photo")
                            .padding()
                            .font(.headline)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .onTapGesture {
                                
                            }
                    }
                    Spacer()
                    NavigationLink(destination: TranscriptView(imageOCR: $imageOCR)) {
                        Text("View Text")
                            .padding()
                            .font(.headline)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    Spacer()
                }

                /// Convert the image data to a `UIImage`, and display it in an `Image` view.
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            ForEach(imageOCR.foundStringsWithMacros) { observation in
                                
                                ButtonBox(foundString: observation, image: uiImage){
                                    handleTapGesture(id: observation.id)
                                }
                                
                            }
                        }
                        .padding()
                        .scaleEffect(currentZoom + totalZoom)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    currentZoom = value.magnification - 1
                                }
                                .onEnded { value in
                                    totalZoom += currentZoom
                                    currentZoom = 0
                                }
                        )
                        .accessibilityZoomAction { action in
                            if action.direction == .zoomIn {
                                totalZoom += 1
                            } else {
                                totalZoom -= 1
                            }
                        }
                }

                /// Select the recognition level — fast or accurate.
                Picker("Selected Macro", selection: $selectedMacro) {
                    ForEach(["calories", "fat", "carbs", "protein", "none"], id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if saved {
                    Button("Scan Again"){
                        path.removeLast()
                    }
                } else {
                    Button("Save"){
                        saveData()
                        path.removeLast()
                    }.opacity(saving ? 0 : 1)
                        .overlay{
                            if saving {
                                ProgressView()
                            }
                        }
                }
                

            }
            /// Initially perform the request, and then perform the request when changes occur to the request settings.
            .onChange(of: settingChanges, initial: true) {
                Task {
                    try await imageOCR.performOCR(imageData: imageData)
                }
            }
        
    }
    
    func handleTapGesture(id: UUID) {
        if let index = imageOCR.foundStringsWithMacros.firstIndex(where: {$0.id == id}) {
            imageOCR.foundStringsWithMacros[index].label = selectedMacro
        }
    }
    
    func saveData() {
        
        context.insert(NutritionLabel(image: imageData, foundStringList: imageOCR.foundStringsWithMacros))
        
    }
    
    func sendData() {
        saving = true
        let encoder = JSONEncoder()
        
        let data = try! encoder.encode(imageOCR.foundStringsWithMacros)
        
        let url = URL(string: "https://rtzetktjl3.execute-api.us-east-1.amazonaws.com/Prod/upload/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let error = error {
                saving = false
                saved = true
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                saving = false
                saved = true
                print ("server error")
                return
            }
            if let mimeType = response.mimeType,
               mimeType == "application/json",
               let data = data,
               let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
            saving = false
            saved = true
        }
        task.resume()
    }
}

struct ButtonBox: View {
    let foundString: FoundString
    let image: UIImage
    
    let callback: () -> Void
    
    var body: some View {
        
        GeometryReader{proxy in
            Button(action: callback){
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: getImageRect(proxy).width, height: getImageRect(proxy).height)
                    .border(getStroke(foundString: foundString))
                    
            }
            .position(CGPoint(x: getImageRect(proxy).midX, y: getImageRect(proxy).midY))
            
        }
    
        
    }
    
    func getImageRect(_ proxy: GeometryProxy) -> CGRect{
        return foundString.boundingBox.toImageCoordinates(proxy.size, origin: .upperLeft)
    }
    
    
    func getStroke(foundString: FoundString) -> Color{
        switch foundString.label {
        case "calories":
            return .blue
        case "fat":
            return .orange
        case "carbs":
            return.green
        case "protein":
            return .purple
        default:
            return .red
        }
    }
}

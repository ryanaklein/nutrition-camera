//
//  ImageView.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/1/24.
//  Originally taken from https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
//

import SwiftUI

struct ImageView: View {
    @Binding var showCamera: Bool
    @Binding var imageData: Data?

    @State private var imageOCR = OCR()
    @State private var languageCorrection = false
    @State private var selectedMacro = "Calories"
    @State private var selectedLanguage = Locale.Language(identifier: "en-US")
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0

    var recognitionLevels = ["Accurate", "Fast"]

    /// Watch for changes to the request settings.
    var settingChanges: [String] {[
        languageCorrection.description,
        imageData!.description,
        selectedLanguage.maximalIdentifier
    ]}

    var body: some View {
        NavigationStack {
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
                                showCamera = true
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
                if let uiImage = UIImage(data: imageData!) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            ForEach(imageOCR.foundStrings) { observation in
                                Button(action:{handleTapGesture(id: observation.id)}){
                                    Box(observation: observation)
                                        .stroke(.red, lineWidth: 1)
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
                    ForEach(["Calories", "Fat", "Carbs", "Protein"], id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)

            }
            /// Initially perform the request, and then perform the request when changes occur to the request settings.
            .onChange(of: settingChanges, initial: true) {
                Task {
                    try await imageOCR.performOCR(imageData: imageData!)
                }
            }
        }
    }
    
    func handleTapGesture(id: UUID) {
        if let index = imageOCR.foundStrings.firstIndex(where: {$0.id == id}) {
            imageOCR.foundStrings[index].macro = selectedMacro
        }
    }
}

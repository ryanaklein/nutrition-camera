//
//  Prediction.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 2/2/25.
//  Originally taken from https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
//

import SwiftUI

struct PredictionView: View {
    
    @Environment(\.modelContext) private var context
    
    let imageData: Data
    @Binding var path: NavigationPath
    
    @State private var imageOCR = OCR()
    @State private var languageCorrection = false
    @State private var selectedLanguage = Locale.Language(identifier: "en-US")
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    @State private var saving = false
    @State private var saved = false
    
    @State private var predictions = [
        "calories": Prediction(foundString: nil, confidence: 0.0),
        "fat": Prediction(foundString: nil, confidence: 0.0),
        "carbs": Prediction(foundString: nil, confidence: 0.0),
        "protein": Prediction(foundString: nil, confidence: 0.0)
    ]
    
    @State private var foundStringPredictions: [FoundString] = []
    
    var recognitionLevels = ["Accurate", "Fast"]
    
    /// Watch for changes to the request settings.
    var settingChanges: [String] {[
        languageCorrection.description,
        imageData.description,
        selectedLanguage.maximalIdentifier
    ]}
    
    var body: some View {
        VStack {
            Spacer()
            
            /// Convert the image data to a `UIImage`, and display it in an `Image` view.
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        ForEach(foundStringPredictions) { observation in
                            
                            PredictionBox(foundString: observation, image: uiImage)
                        }
                    }
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
            Spacer()
            VStack{
                VStack {
                    HStack{
                        Text("Calories: ")
                        if let calories = predictions["calories"]?.foundString?.string {
                            Text(calories)
                        }
                        Spacer()
                        Text("Fat: ")
                        if let fat = predictions["fat"]?.foundString?.string {
                            Text(fat)
                        }
                    }
                    .padding()
                    HStack{
                        Text("Carbs: ")
                        if let carbs = predictions["carbs"]?.foundString?.string {
                            Text(carbs)
                        }
                        Spacer()
                        Text("Protein: ")
                        if let protein = predictions["protein"]?.foundString?.string {
                            Text(protein)
                        }
                    }
                    .padding()
                }
                
                Button("Predict"){
                    predict()
                }
                .opacity(saving ? 0 : 1)
                .overlay{
                    if saving {
                        ProgressView()
                    }
                }
                .accessibilityIgnoresInvertColors(false)
                .disabled(!imageOCR.ocrComplete)
            }
            .background(.white)
            
            
            
        }
        /// Initially perform the request, and then perform the request when changes occur to the request settings.
        .onChange(of: settingChanges, initial: true) {
            Task {
                try await imageOCR.performOCR(imageData: imageData)
            }
        }
        
    }
    
    func debugLabel() {
        if let nutritionLabel = imageOCR.nutritionLabel, let foundStringList = nutritionLabel.foundStringList {
            
            print("Calories rect: \(nutritionLabel.getMacroTextForType("calories")!.normalizedRect!)")
            print("Fat rect: \(nutritionLabel.getMacroTextForType("fat")!.normalizedRect!)")
            print("Carbs rect: \(nutritionLabel.getMacroTextForType("carbs")!.normalizedRect!)")
            print("Protein rect: \(nutritionLabel.getMacroTextForType("protein")!.normalizedRect!)")
            
            for foundString in foundStringList {
                
                if ["calories", "fat", "carbs", "protein"].contains(foundString.label){
                    
                    print("******\(foundString.label)******")
                    if let distance = foundString.distanceToCalories, let slope = foundString.slopeToCalories {
                        print("Distance to calories: \(distance)")
                        print("Slope to calories: \(slope)")
                    }
                    
                    if let distance = foundString.distanceToFat, let slope = foundString.slopeToFat {
                        print("Distance to fat: \(distance)")
                        print("Slope to fat: \(slope)")
                    }
                    
                    if let distance = foundString.distanceToCarbs, let slope = foundString.slopeToCarbs {
                        print("Distance to carbs: \(distance)")
                        print("Slope to carbs: \(slope)")
                    }
                    
                    if let distance = foundString.distanceToProtein, let slope = foundString.slopeToProtein {
                        print("Distance to protein: \(distance)")
                        print("Slope to protein: \(slope)")
                    }
                    print("\n")
                }
            }
        }
    }
    
    func predict() {
        
        guard let foundStringList = imageOCR.nutritionLabel?.foundStringList else {
            print("No found string list!")
            return
        }
        
        let classifier = try! NutritionLabelClassifier(configuration: .init())
        
        
        for foundString in foundStringList {
            
            
            print("Predicting \(foundString.string) in \(foundString.fullLine)")
            
            guard let distanceToCalories = foundString.distanceToCalories, let slopeToCalories = foundString.slopeToCalories, let distanceToFat = foundString.distanceToFat, let slopeToFat = foundString.slopeToFat, let distanceToCarbs = foundString.distanceToCarbs, let slopeToCarbs = foundString.slopeToCarbs, let distanceToProtein = foundString.distanceToProtein, let slopeToProtein = foundString.slopeToProtein else {
                print("Not all values available")
                continue
            }
            
            let isInCalorieString = Int64(foundString.isInCalorieString ? 1 : 0)
            let isInFatString = Int64(foundString.isInFatString ? 1 : 0)
            let isInCarbsString = Int64(foundString.isInCarbsString ? 1 : 0)
            let isInProteinString = Int64(foundString.isInProteinString ? 1 : 0)
            let isGrams = Int64(foundString.isGrams ? 1 : 0)
            let isUnitless = Int64(foundString.isUnitless ? 1 : 0)
            
            
            
            
            let output = try! classifier.prediction(isInCalorieString: isInCalorieString, isInFatString: isInFatString, isInCarbsString: isInCarbsString, isInProteinString: isInProteinString, isGrams: isGrams, isUnitless: isUnitless, distanceToCalories: Double(distanceToCalories), slopeToCalories: Double(slopeToCalories), distanceToFat: Double(distanceToFat), slopeToFat: Double(slopeToFat), distanceToCarbs: Double(distanceToCarbs), slopeToCarbs: Double(slopeToCarbs), distanceToProtein: Double(distanceToProtein), slopeToProtein: Double(slopeToProtein))
            
            
            print("Predicted \(output.label) with probaility \(output.labelProbability)\n\n")
            
            if ["calories", "fat", "carbs", "protein"].contains(output.label), let currentPrediction = predictions[output.label], let newConfidence = output.labelProbability[output.label], newConfidence > currentPrediction.confidence {
                
                predictions[output.label] = Prediction(foundString: foundString, confidence: newConfidence)
            }
            
        }
        
        for (label, prediction) in predictions {
            if let foundString = prediction.foundString {
                foundString.label = label
                foundStringPredictions.append(foundString)
            }
        }
        
    }
    
    func sendData() {
        
        guard let foundStringList = imageOCR.nutritionLabel?.foundStringList else {
            print("No found string list!")
            return
        }
        saving = true
        let encoder = JSONEncoder()
        
        let data = try! encoder.encode(foundStringList)
        
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

struct PredictionBox: View {
    let foundString: FoundString
    let image: UIImage
    
    var body: some View {
        
        GeometryReader{proxy in
            Rectangle()
                .fill(Color.clear)
                .frame(width: getImageRect(proxy).width, height: getImageRect(proxy).height)
                .border(getStroke(foundString: foundString))
                .position(CGPoint(x: getImageRect(proxy).midX, y: getImageRect(proxy).midY))
            
        }
        
        
    }
    
    func getImageRect(_ proxy: GeometryProxy) -> CGRect{
        return foundString.normalizedRect.toImageCoordinates(proxy.size, origin: .upperLeft)
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

struct Prediction {
    let foundString: FoundString?
    let confidence: Double
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let image = UIImage(named: "label")!.heicData()
    ImageView(imageData: image!, path: $path)
}

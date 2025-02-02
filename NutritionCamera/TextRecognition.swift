//
//  TextRecognition.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/1/24.
//  Originally taken from https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
//

import SwiftUI
import Vision

@Observable
class OCR {
    /// The array of `RecognizedTextObservation` objects to hold the request's results.
    private var observations = [RecognizedTextObservation]()
    private var foundStrings: [FoundString] = []
    var nutritionLabel: NutritionLabel?
    var ocrComplete = false
    

    /// The Vision request.
    var request = RecognizeTextRequest()

    func performOCR(imageData: Data) async throws {
        
        nutritionLabel = NutritionLabel(image: imageData, foundStringList: [])
        
        let simpleDigits = try Regex("[0-9]+")
        
        /// Clear the `observations` array for photo recapture.
        observations.removeAll()
        foundStrings.removeAll()

        /// Perform the request on the image data and return the results.
        let results = try await request.perform(on: imageData)

        /// Add each observation to the `observations` array.
        for observation in results {
            
            
            if let topCandidate = observation.topCandidates(1).first {
                let transcript = topCandidate.string
                let strings = transcript.split(separator: " ")
                
                if transcript.lowercased().contains("calories") {
                    if nutritionLabel?.getMacroTextForType("calories") == nil {
                        if let macroBoundingBox = getBoundingBox(text: "calories", recognizedText: topCandidate){
                            nutritionLabel?.macroTextList?.append(MacroText(macro: "calories", x: macroBoundingBox.origin.x, y: macroBoundingBox.origin.y, width: macroBoundingBox.width, height: macroBoundingBox.height))
                            observations.append(observation)
                        }
                    }
                }
                
                if transcript.lowercased().contains("total fat") {
                    if let macroBoundingBox = getBoundingBox(text: "total fat", recognizedText: topCandidate){
                        nutritionLabel?.macroTextList?.append(MacroText(macro: "fat", x: macroBoundingBox.origin.x, y: macroBoundingBox.origin.y, width: macroBoundingBox.width, height: macroBoundingBox.height))
                        observations.append(observation)
                    }
                }
                
                if transcript.lowercased().contains("total carb") {
                    if let macroBoundingBox = getBoundingBox(text: "total carb", recognizedText: topCandidate){
                        nutritionLabel?.macroTextList?.append(MacroText(macro: "carbs", x: macroBoundingBox.origin.x, y: macroBoundingBox.origin.y, width: macroBoundingBox.width, height: macroBoundingBox.height))
                        observations.append(observation)
                    }
                }
                
                if transcript.lowercased().contains("protein") {
                    if let macroBoundingBox = getBoundingBox(text: "protein", recognizedText: topCandidate){
                        nutritionLabel?.macroTextList?.append(MacroText(macro: "protein", x: macroBoundingBox.origin.x, y: macroBoundingBox.origin.y, width: macroBoundingBox.width, height: macroBoundingBox.height))
                        observations.append(observation)
                    }
                }
                
                for string in strings {
                    
                    if string.contains(simpleDigits){
                        let stringRange = transcript.range(of: string)!
                        let boundingBox = topCandidate.boundingBox(for: stringRange)!.boundingBox
                        
                        let foundString = FoundString(id: UUID(), string: String(string), fullLine: transcript, boundingBox: boundingBox)
                        
                        nutritionLabel?.foundStringList?.append(foundString)
                    }
                    
                }
                
            }
            
        }
        ocrComplete = true
    }
    
    func getBoundingBox(text: String, recognizedText: RecognizedText) -> NormalizedRect?{
        
        let transcript = recognizedText.string
        
        guard let range = transcript.range(of: text, options: [.caseInsensitive]) else { return nil }
        
        
        return recognizedText.boundingBox(for: range)?.boundingBox
        
    }
    

}

/// Create and dynamically size a bounding box.
struct Box: Shape {
    private let normalizedRect: NormalizedRect

    init(observation: any BoundingBoxProviding) {
        normalizedRect = observation.boundingBox
    }

    func path(in rect: CGRect) -> Path {
        let rect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(rect)
    }
}

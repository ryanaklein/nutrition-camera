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
    var observations = [RecognizedTextObservation]()
    var foundStrings: [FoundString] = []
    var foundStringsWithMacros: [FoundString] = []
    var macroDict: [String:NormalizedRect] = [:]
    

    /// The Vision request.
    var request = RecognizeTextRequest()

    func performOCR(imageData: Data) async throws {
        
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
                    if let macroBoundingBox = getBoundingBox(text: "calories", recognizedText: topCandidate){
                        macroDict["calories"] = macroBoundingBox
                        observations.append(observation)
                    }
                }
                
                if transcript.lowercased().contains("total fat") {
                    if let macroBoundingBox = getBoundingBox(text: "total fat", recognizedText: topCandidate){
                        macroDict["fat"] = macroBoundingBox
                        observations.append(observation)
                    }
                }
                
                if transcript.lowercased().contains("total carb") {
                    if let macroBoundingBox = getBoundingBox(text: "total carb", recognizedText: topCandidate){
                        macroDict["carbs"] = macroBoundingBox
                        observations.append(observation)
                    }
                }
                
                if transcript.lowercased().contains("protein") {
                    if let macroBoundingBox = getBoundingBox(text: "protein", recognizedText: topCandidate){
                        macroDict["protein"] = macroBoundingBox
                        observations.append(observation)
                    }
                }
                
                for string in strings {
                    
                    if string.contains(simpleDigits){
                        let stringRange = transcript.range(of: string)!
                        let boundingBox = topCandidate.boundingBox(for: stringRange)!.boundingBox
                        
                        let foundString = FoundString(id: UUID(), string: String(string), fullLine: transcript, boundingBox: boundingBox)
                        
                        foundStrings.append(foundString)
                    }
                    
                }
                
            }
            
        }
        for var foundString in foundStrings {
            if let calories = macroDict["calories"] {
                foundString.slopeToCalories = calculateSlope(from: calories.cgRect, to: foundString.boundingBox.cgRect)
                foundString.distanceToCalories = calculateDistance(from: calories.cgRect, to: foundString.boundingBox.cgRect)
            }
            
            if let fat = macroDict["fat"] {
                foundString.slopeToFat = calculateSlope(from: fat.cgRect, to: foundString.boundingBox.cgRect)
                foundString.distanceToFat = calculateDistance(from: fat.cgRect, to: foundString.boundingBox.cgRect)
            }
            
            
            if let carbs = macroDict["carbs"] {
                foundString.slopeToCarbs = calculateSlope(from: carbs.cgRect, to: foundString.boundingBox.cgRect)
                foundString.distanceToCarbs = calculateDistance(from: carbs.cgRect, to: foundString.boundingBox.cgRect)
            }
            
            
            if let protein = macroDict["protein"] {
                foundString.slopeToProtein = calculateSlope(from: protein.cgRect, to: foundString.boundingBox.cgRect)
                foundString.distanceToProtein = calculateDistance(from: protein.cgRect, to: foundString.boundingBox.cgRect)
            }
            
            foundStringsWithMacros.append(foundString)
            
            
        }
    }
    
    func getBoundingBox(text: String, recognizedText: RecognizedText) -> NormalizedRect?{
        
        let transcript = recognizedText.string
        
        guard let range = transcript.range(of: text, options: [.caseInsensitive]) else { return nil }
        
        
        return recognizedText.boundingBox(for: range)?.boundingBox
        
    }
    
    func calculateDistance(from: CGRect, to: CGRect) -> Float{
        let squaredDistance = (from.midX - to.midX) * (from.midX - to.midX) + (from.midY - to.midY) * (from.midY - to.midY)
        return Float(sqrt(squaredDistance))
    }
    
    func calculateSlope(from: CGRect, to:CGRect) -> Float{
        return Float((from.midY - to.midY)/(from.midX - to.midX))
    }
}

/// Create and dynamically size a bounding box.
struct Box: Shape {
    private let normalizedRect: NormalizedRect

    init(observation: any BoundingBoxProviding) {
        normalizedRect = observation.boundingBox
    }

    func path(in rect: CGRect) -> Path {
        print("PATH")
        print(rect.size)
        let rect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(rect)
    }
}

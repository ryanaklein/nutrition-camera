//
//  FoundString.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 11/24/24.
//

import Foundation
import Vision
import SwiftData

@Model
class FoundString: Encodable, Identifiable{
    var id: UUID?
    var string = ""
    var fullLine = ""
    var boundingBoxX = 0.0
    var boundingBoxY = 0.0
    var boundingBoxWidth = 0.0
    var boundingBoxHeight = 0.0
    var nutritionLabel: NutritionLabel?
    
    var normalizedRect: NormalizedRect{
        return NormalizedRect(x: boundingBoxX, y: boundingBoxY, width: boundingBoxWidth, height: boundingBoxHeight)
    }
    
    var isInCalorieString: Bool {
        return fullLine.contains(caseInsensitiveRegex(matchString: "calories"))
    }
    
    var isInFatString: Bool {
        return fullLine.contains(caseInsensitiveRegex(matchString: "total fat"))
    }
    
    var isInCarbsString: Bool {
        return fullLine.contains(caseInsensitiveRegex(matchString: "total carb"))
    }
    
    var isInProteinString: Bool {
        return fullLine.contains(caseInsensitiveRegex(matchString: "protein"))
    }
    
    var isGrams: Bool {
        string.contains(try! Regex("\\d+g"))
    }
    
    var isUnitless: Bool{
        string.contains(try! Regex("^\\d+$"))
    }
    
    var label: String = "none"
    
    var distanceToCalories: Float? {
        if let calorieRect = nutritionLabel?.getMacroTextForType("calories")?.normalizedRect?.cgRect {
            return calculateDistance(from: normalizedRect.cgRect, to: calorieRect)
        }
        
        return nil
    }
    var slopeToCalories: Float? {
        if let calorieRect = nutritionLabel?.getMacroTextForType("calories")?.normalizedRect?.cgRect {
            return calculateSlope(from: normalizedRect.cgRect, to: calorieRect)
        }
        
        return nil
    }
    
    var distanceToFat: Float? {
        if let fatRect = nutritionLabel?.getMacroTextForType("fat")?.normalizedRect?.cgRect {
            return calculateDistance(from: normalizedRect.cgRect, to: fatRect)
        }
        
        return nil
    }
    var slopeToFat: Float? {
        if let fatRect = nutritionLabel?.getMacroTextForType("fat")?.normalizedRect?.cgRect {
            return calculateSlope(from: normalizedRect.cgRect, to: fatRect)
        }
        
        return nil
    }
    
    var distanceToCarbs: Float? {
        if let carbsRect = nutritionLabel?.getMacroTextForType("carbs")?.normalizedRect?.cgRect {
            return calculateDistance(from: normalizedRect.cgRect, to: carbsRect)
        }
        
        return nil
    }
    var slopeToCarbs: Float? {
        if let carbsRect = nutritionLabel?.getMacroTextForType("carbs")?.normalizedRect?.cgRect {
            return calculateSlope(from: normalizedRect.cgRect, to: carbsRect)
        }
        
        return nil
    }
    
    var distanceToProtein: Float? {
        if let proteinRect = nutritionLabel?.getMacroTextForType("protein")?.normalizedRect?.cgRect {
            return calculateDistance(from: normalizedRect.cgRect, to: proteinRect)
        }
        
        return nil
    }
    var slopeToProtein: Float? {
        if let proteinRect = nutritionLabel?.getMacroTextForType("protein")?.normalizedRect?.cgRect {
            return calculateSlope(from: normalizedRect.cgRect, to: proteinRect)
        }
        
        return nil
    }
    
    init(id: UUID, string: String, fullLine: String, boundingBox: NormalizedRect) {
        self.id = id
        self.string = string
        self.fullLine = fullLine
        self.boundingBoxX = boundingBox.origin.x
        self.boundingBoxY = boundingBox.origin.y
        self.boundingBoxWidth = boundingBox.width
        self.boundingBoxHeight = boundingBox.height
    }
    
    func encode(to encoder: any Encoder) throws {
        
    }
    
    
    private func caseInsensitiveRegex(matchString: String) -> Regex<Substring>{
        return try! Regex("(?i)\(matchString)")
    }
    
    
    func calculateDistance(from: CGRect, to: CGRect) -> Float{
        let squaredDistance = (from.midX - to.midX) * (from.midX - to.midX) + (from.midY - to.midY) * (from.midY - to.midY)
        return Float(sqrt(squaredDistance))
    }
    
    func calculateSlope(from: CGRect, to:CGRect) -> Float{
        
        let slope = Double((from.midY - to.midY)/(from.midX - to.midX))
        
        let normalizedSlope = atan(slope)/(Double.pi/2)
        
        return Float(normalizedSlope)
    }
    
    
    
    
}

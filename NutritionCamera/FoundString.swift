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
class FoundString: Encodable, BoundingBoxProviding, Identifiable{
    var id: UUID
    var string: String
    var fullLine: String
    var boundingBox: NormalizedRect
    
    var isInCalorieString: Bool {
        return fullLine.contains(caseInsensitiveRegex(matchString: "calories"))
    }
    
    var isInFatString: Bool {
        return fullLine.contains(caseInsensitiveRegex(matchString: "total fat"))
    }
    
    var isInCarbsString: Bool {
        return fullLine.contains(caseInsensitiveRegex(matchString: "total carbs"))
    }
    
    var isInProteinString: Bool {
        return fullLine.contains(caseInsensitiveRegex(matchString: "protein"))
    }
    
    var label: String = "none"
    
    var distanceToCalories: Float?
    var slopeToCalories: Float?
    
    var distanceToFat: Float?
    var slopeToFat: Float?
    
    var distanceToCarbs: Float?
    var slopeToCarbs: Float?
    
    var distanceToProtein: Float?
    var slopeToProtein: Float?
    
    init(id: UUID, string: String, fullLine: String, boundingBox: NormalizedRect, distanceToCalories: Float? = nil, slopeToCalories: Float? = nil, distanceToFat: Float? = nil, slopeToFat: Float? = nil, distanceToCarbs: Float? = nil, slopeToCarbs: Float? = nil, distanceToProtein: Float? = nil, slopeToProtein: Float? = nil) {
        self.id = id
        self.string = string
        self.fullLine = fullLine
        self.boundingBox = boundingBox
        self.distanceToCalories = distanceToCalories
        self.slopeToCalories = slopeToCalories
        self.distanceToFat = distanceToFat
        self.slopeToFat = slopeToFat
        self.distanceToCarbs = distanceToCarbs
        self.slopeToCarbs = slopeToCarbs
        self.distanceToProtein = distanceToProtein
        self.slopeToProtein = slopeToProtein
    }
    
    func encode(to encoder: any Encoder) throws {
        
    }
    
    
    private func caseInsensitiveRegex(matchString: String) -> Regex<Substring>{
        return try! Regex("(?i)\(matchString)")
    }
    
    
    
    
}

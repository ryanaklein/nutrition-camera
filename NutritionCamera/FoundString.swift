//
//  FoundString.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 11/24/24.
//

import Foundation
import Vision

struct FoundString: Codable{
    let string: String
    let fullLine: String
    let boundingBox: NormalizedRect
    
    var distanceToCalories: Float?
    var slopeToCalories: Float?
    
    var distanceToFat: Float?
    var slopeToFat: Float?
    
    var distanceToCarbs: Float?
    var slopeToCarbs: Float?
    
    var distanceToProtein: Float?
    var slopeToProtein: Float?
    
    
}

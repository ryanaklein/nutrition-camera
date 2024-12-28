//
//  FlatFoundString.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/21/24.
//

import Foundation
import SwiftData


@Model
class FlatFoundString {
    
    var label: String
    var string: String
    
    var containsG: Bool {
        return self.string.contains("g")
    }
    
    var isInCaloriesString = false
    var isInFatString = false
    var isInCarbsString = false
    var isInProteinString = false
    
    var distanceToCalories: Float?
    var slopeToCalories: Float?
    
    var distanceToFat: Float?
    var slopeToFat: Float?
    
    var distanceToCarbs: Float?
    var slopeToCarbs: Float?
    
    var distanceToProtein: Float?
    var slopeToProtein: Float?
    
    init(foundString: FoundString) {
        self.label = foundString.label
        self.string = foundString.string
        
        self.isInCaloriesString = foundString.isInCalorieString
        self.isInFatString = foundString.isInFatString
        self.isInCarbsString = foundString.isInCarbsString
        self.isInProteinString = foundString.isInProteinString
        
        self.distanceToCalories = foundString.distanceToCalories
        self.slopeToCalories = foundString.slopeToCalories
        
        self.distanceToFat = foundString.distanceToFat
        self.slopeToFat = foundString.slopeToFat
        
        self.distanceToCarbs = foundString.distanceToCarbs
        self.slopeToCarbs = foundString.slopeToCarbs
        
        self.distanceToProtein = foundString.distanceToCalories
        self.slopeToProtein = foundString.slopeToProtein
    }
    
    init(label: String, string: String, isInCaloriesString: Bool, isInFatString: Bool, isInCarbsString: Bool,isInProteinString: Bool, distanceToCalories: Float, slopeToCalories: Float, distanceToFat: Float, slopeToFat: Float, distanceToCarbs: Float, slopeToCarbs: Float, distanceToProtein: Float, slopeToProtein: Float) {
        self.label = label
        self.string = string
        
        self.isInCaloriesString = isInCaloriesString
        self.isInFatString = isInFatString
        self.isInCarbsString = isInCarbsString
        self.isInProteinString = isInProteinString
        
        self.distanceToCalories = distanceToCalories
        self.slopeToCalories = slopeToCalories
        
        self.distanceToFat = distanceToFat
        self.slopeToFat = slopeToFat
        
        self.distanceToCarbs = distanceToCarbs
        self.slopeToCarbs = slopeToCarbs
        
        self.distanceToProtein = distanceToCalories
        self.slopeToProtein = slopeToProtein
    }
    
    
}

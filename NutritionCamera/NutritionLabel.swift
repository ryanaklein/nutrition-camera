//
//  NutritionLabel.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/27/24.
//

import Foundation
import SwiftData

@Model
class NutritionLabel{
    
    var image: Data
    @Relationship(deleteRule: .cascade) var foundStringList: [FoundString]
    
    init(image: Data, foundStringList: [FoundString]) {
        self.image = image
        self.foundStringList = foundStringList
    }
}

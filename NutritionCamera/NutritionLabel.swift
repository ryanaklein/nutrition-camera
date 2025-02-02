//
//  NutritionLabel.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/27/24.
//

import Foundation
import SwiftData
import Vision

@Model
class NutritionLabel{
    var image: Data?
    @Relationship(deleteRule: .cascade, inverse: \MacroText.nutritionLabel) var macroTextList: [MacroText]? = []
    @Relationship(deleteRule: .cascade, inverse: \FoundString.nutritionLabel) var foundStringList: [FoundString]? = []
    
    init(image: Data, foundStringList: [FoundString]) {
        self.image = image
        self.foundStringList = foundStringList
    }
    
    func getMacroTextForType(_ type: String) -> MacroText? {
        return macroTextList?.first { $0.macro == type }
    }
}

@Model
class MacroText {
    var macro: String?
    var x: CGFloat?
    var y: CGFloat?
    var width: CGFloat?
    var height: CGFloat?
    var nutritionLabel: NutritionLabel?
    
    var normalizedRect: NormalizedRect? {
        if let x = x, let y = y, let width = width, let height = height {
            return NormalizedRect(x: x, y: y, width: width, height: height)
        }
        
        return nil
    }
    
    init(macro: String?, x: CGFloat?, y: CGFloat?, width: CGFloat?, height: CGFloat?) {
        self.macro = macro
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

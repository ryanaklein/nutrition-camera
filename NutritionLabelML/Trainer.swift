//
//  Trainer.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 1/19/25.
//

import SwiftData


struct Trainer {
    
    
    @MainActor func train() {
        let container = try! ModelContainer(for: NutritionLabel.self)
        
        let context = container.mainContext
        
        let nutritionLabels = FetchDescriptor<NutritionLabel>()
        
        let results = try! context.fetch(nutritionLabels)
        
        for foundString in results[0].foundStringList! {
            print(foundString.label)
        }
        
    }
    
}


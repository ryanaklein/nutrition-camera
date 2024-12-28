//
//  PreviewSampleData.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/28/24.
//

import SwiftUI
import SwiftData
import Vision


@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: NutritionLabel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let image = UIImage(named: "label")!.heicData()
        
        let label = NutritionLabel(image: image!, foundStringList: [FoundString(id: UUID(), string: "Calories", fullLine: "Calories", boundingBox: NormalizedRect(x: 1.0, y: 1.0, width: 0.5, height: 0.5))])
        
        container.mainContext.insert(label)
        
        
        return container
    } catch {
        fatalError("Failed to create preview container")
    }
}()




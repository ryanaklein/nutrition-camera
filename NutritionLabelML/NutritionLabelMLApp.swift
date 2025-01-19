//
//  NutritionLabelMLApp.swift
//  NutritionLabelML
//
//  Created by Ryan Klein on 1/18/25.
//

import SwiftUI

@main
struct NutritionLabelMLApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [NutritionLabel.self])
        }
    }
}

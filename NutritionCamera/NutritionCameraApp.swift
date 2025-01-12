//
//  NutritionCameraApp.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 11/16/24.
//

import SwiftUI
import SwiftData

@main
struct NutritionCameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [NutritionLabel.self])
        }
    }
}

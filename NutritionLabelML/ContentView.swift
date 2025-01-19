//
//  ContentView.swift
//  NutritionLabelML
//
//  Created by Ryan Klein on 1/18/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            NutritionLabelListView()
                .task {
                    let trainer = Trainer()
                    trainer.train()
                }
        }
    }
}

#Preview {
    ContentView()
}

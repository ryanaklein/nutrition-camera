//
//  NutritionLabelListView.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/27/24.
//

import SwiftUI
import SwiftData

struct NutritionLabelListView: View {
    
    @Query var nutritionLabelList: [NutritionLabel]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List{
            ForEach(nutritionLabelList) { nutritionLabel in
                NavigationLink(value: nutritionLabel){
                    Image(nsImage: NSImage(data: nutritionLabel.image!)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 133, alignment: .topLeading)
                }
            }
            .onDelete(perform: removeNutritionLabel)
        }
        .navigationDestination(for: NutritionLabel.self){ nutritionLabel in
            FoundStringListView(foundStringList: nutritionLabel.foundStringList!)
            
        }
    }
    
    private func removeNutritionLabel(at indexSet: IndexSet){
        for index in indexSet {
            modelContext.delete(nutritionLabelList[index])
        }
    }
}

#Preview {
    NutritionLabelListView()
}


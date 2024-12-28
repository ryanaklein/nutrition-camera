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
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(nutritionLabelList) { nutritionLabel in
                    NavigationLink(value: nutritionLabel){
                        Image(uiImage: UIImage(data: nutritionLabel.image)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 133, alignment: .topLeading)
                    }
                }
            }
            .navigationDestination(for: NutritionLabel.self){ nutritionLabel in
                FoundStringListView(foundStringList: nutritionLabel.foundStringList)
                
            }
        }
    }
}

#Preview {
    NutritionLabelListView()
        .modelContainer(previewContainer)
}

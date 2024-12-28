//
//  FoundStringListView.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/28/24.
//

import SwiftUI
import Vision

struct FoundStringListView: View {
    
    let foundStringList: [FoundString]
    
    var body: some View {
        List{
            ForEach(foundStringList) { foundString in
                Text(foundString.string)
            }
        }
    }
}

#Preview {
    FoundStringListView(foundStringList: [FoundString(id: UUID(), string: "Calories", fullLine: "Calories", boundingBox: NormalizedRect(x: 1.0, y: 1.0, width: 0.5, height: 0.5))])
}

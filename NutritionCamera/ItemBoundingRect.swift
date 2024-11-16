//
//  ItemBoundingRect.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 11/16/24.
//

import SwiftUI
import VisionKit

struct ItemBoundingRect: View {
    
    var body: some View {
        Rectangle()
            .stroke()
            .foregroundStyle(.pink)
    }
}

#Preview {
    ItemBoundingRect()
}

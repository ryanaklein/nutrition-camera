//
//  ContentView.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 11/16/24.
//

import SwiftUI

struct ContentView: View {
    @State var calories: String = ""
    var body: some View {
        DataScannerSwiftUIAdapter(calories: $calories)
    }
}

#Preview {
    ContentView()
}

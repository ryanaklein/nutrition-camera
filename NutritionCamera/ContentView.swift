//
//  ContentView.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 11/16/24.
//  Originally taken from https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        ZStack{
            NavigationStack(path: $path) {
                NutritionLabelListView()
                    .toolbar{
                        NavigationLink(value: "camera") {
                            Image(systemName: "plus")
                        }
                    }
                    .navigationTitle("Captured Labels")
                    .navigationDestination(for: String.self){
                        value in
                        if value == "error"{
                            VStack {
                                Image(systemName: "lock.trianglebadge.exclamationmark.fill")
                                    .resizable()
                                    .frame(width: 200, height: 200)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.gray)
                                
                                Text("This app needs access to the camera for it to function properly. You can update this at:")
                                Text("Settings > Privacy and Security > Camera")
                            }
                        }
                        else if value == "camera"{
                            CameraUI(path: $path)
                        }
                        else {
                            EmptyView()
                        }
                    }
                    .navigationDestination(for: ImageDataContainer.self){
                        imageDataContainer in
                        ImageView(imageData: imageDataContainer.imageData, path: $path)
                    }
            }
        }
        
        
        
    }
}



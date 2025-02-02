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
                VStack{
                    NutritionLabelListView()
                    NavigationLink(value: "predict"){
                        Text("Predict")
                    }
                    .padding(20)
                }
                    .toolbar{
                        NavigationLink(value: "camera") {
                            Image(systemName: "plus")
                        }
                    }
                    .navigationTitle("Training Data")
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
                        else if value == "camera" || value == "predict"{
                            CameraUI(path: $path, mode: value)
                        }
                        else {
                            EmptyView()
                        }
                    }
                    .navigationDestination(for: ImageDataContainer.self){
                        imageDataContainer in
                        if imageDataContainer.mode == "camera"{
                            ImageView(imageData: imageDataContainer.imageData, path: $path)
                        } else{
                            PredictionView(imageData: imageDataContainer.imageData, path: $path)
                        }
                    }
            }
        }
        
        
        
    }
}



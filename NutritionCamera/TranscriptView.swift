//
//  TranscriptView.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/1/24.
//  Originally taken from https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
//

import SwiftUI
import Vision

struct TranscriptView: View {
    @Binding var imageOCR: OCR

    var body: some View {
        VStack {
            NavigationStack {
                if imageOCR.observations.isEmpty {
                    Text("No text found")
                        .foregroundStyle(.gray)
                } else {
                    Text("Text extracted from the image:")
                        .font(.title2)

                    ScrollView {
                        /// Display the text from the captured image.
                        ForEach(imageOCR.observations, id: \.self) { observation in
                            Text(observation.topCandidates(1).first?.string ?? "No text recognized")
                                .textSelection(.enabled)
                        }
                        .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

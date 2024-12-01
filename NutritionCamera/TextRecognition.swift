//
//  TextRecognition.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/1/24.
//  Originally taken from https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
//

import SwiftUI
import Vision

@Observable
class OCR {
    /// The array of `RecognizedTextObservation` objects to hold the request's results.
    var observations = [RecognizedTextObservation]()

    /// The Vision request.
    var request = RecognizeTextRequest()

    func performOCR(imageData: Data) async throws {
        /// Clear the `observations` array for photo recapture.
        observations.removeAll()

        /// Perform the request on the image data and return the results.
        let results = try await request.perform(on: imageData)

        /// Add each observation to the `observations` array.
        for observation in results {
            observations.append(observation)
        }
    }
}

/// Create and dynamically size a bounding box.
struct Box: Shape {
    private let normalizedRect: NormalizedRect

    init(observation: any BoundingBoxProviding) {
        normalizedRect = observation.boundingBox
    }

    func path(in rect: CGRect) -> Path {
        let rect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(rect)
    }
}

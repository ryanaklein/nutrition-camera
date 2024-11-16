//
//  DataScannerSwiftUIAdapter.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 11/16/24.
//

import SwiftUI
@preconcurrency import VisionKit


struct DataScannerSwiftUIAdapter: UIViewControllerRepresentable {
    
    @Binding var calories: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
 
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(recognizedDataTypes: [.text()], qualityLevel: .fast, recognizesMultipleItems: true, isHighlightingEnabled: true)
        context.coordinator.scanner = viewController

        do {
            try viewController.startScanning()
            Task {
                await context.coordinator.updateViaAsyncStream()
            }
        } catch {
            print(error.localizedDescription)
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {

    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        var parent: DataScannerSwiftUIAdapter
        var scanner: DataScannerViewController?
        var itemHighlightViews: [RecognizedItem.ID: UIHostingController<ItemBoundingRect>] = [:]
        var currentItems: [RecognizedItem] = []
        var task: Task<Void, Never>?
        let digits = try! Regex("^\\d+$")
        let calories = try! Regex("(?i)^calories$")
        
        init(_ parent: DataScannerSwiftUIAdapter){
            self.parent = parent
        }
        
        
        func updateViaAsyncStream() async {
            guard let scanner = scanner else {return}
            
            let stream = scanner.recognizedItems
            
            
            for await newItems: [RecognizedItem] in stream {
                let diff = newItems.difference(from: currentItems) { a, b in
                    return a.id == b.id
                }
                
                if !diff.isEmpty {
                    currentItems = newItems
                    
                    var calorieDigitsFound = false
                    
                    for item in currentItems {
                        switch item {
                        case .text(let text):
                            if text.transcript.firstMatch(of: calories) != nil{
                                // "Calories" was found alone on a line. It's likely the next independent number is the actual calorie count. So, just continue.
                                continue
                            }
                            if !calorieDigitsFound {
                                if text.transcript.firstMatch(of: digits) != nil {
                                    calorieDigitsFound = true
                                }
                            }
                        default:
                            continue
                        }
                    }
                    if !calorieDigitsFound {
                        parent.calories = "0"
                    }
                    
                }
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let scanner = self.scanner else {return}
            for item in addItems {
                
                switch item {
                case .text(let text):
                    
                    if(text.transcript.firstMatch(of: digits) != nil && text.transcript.contains("Total Fat")){
                        
                        print(text.transcript)
                        
                        guard let totalFatTextRange = text.transcript.range(of: "Total") else {continue}
                        
                        print(totalFatTextRange.lowerBound)
                        print(totalFatTextRange.upperBound)
                        
                        let topCandidate = text.observation.topCandidates(1)[0]
                        
                        print(topCandidate.string)
                        
                        guard let boundingBox = try? topCandidate.boundingBox(for: totalFatTextRange) else {continue}
                        
                        let itemBoundingRect = ItemBoundingRect()
                        let hostingController = UIHostingController(rootView: itemBoundingRect)
                        scanner.addChild(hostingController)
                        scanner.overlayContainerView.addSubview(hostingController.view)
                        hostingController.didMove(toParent: scanner)
                        hostingController.view.backgroundColor = .clear
                        hostingController.view.frame = CGRect(origin: item.bounds.topLeft, size: CGSize(width: abs(boundingBox.topLeft.x - boundingBox.topRight.x), height: abs(boundingBox.topLeft.y - boundingBox.bottomRight.y)))
                        itemHighlightViews[item.id] = hostingController
                    }
                    
                default:
                    return
                }
                
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in updatedItems {
                
                switch item {
                case .text(let text):
                    if(text.transcript.firstMatch(of: digits) != nil && text.transcript.contains("Total Fat 22g")){
                        
                        print(text.transcript)
                        
                        guard let totalFatTextRange = text.transcript.range(of: "Total Fat 22g") else {continue}
                        guard let totalSugarsTextRange = text.transcript.range(of: "Total Sugars 1g") else {continue}
                        guard let totalCarbsTextRange = text.transcript.range(of: "Total Carbohydrate 4g") else {continue}
                        
                        
                        print(text.transcript[totalFatTextRange])
                        
                        print("\(totalFatTextRange.lowerBound)")
                        print(totalFatTextRange.upperBound)
                        
                        
                        let topCandidate = text.observation.topCandidates(1)[0]
                        
                        print(topCandidate.string)
                        
                        guard let boundingBox = try? topCandidate.boundingBox(for: String.Index(utf16Offset: 0, in: topCandidate.string)..<String.Index(utf16Offset: 100, in: topCandidate.string)) else {continue}
                        guard let totalSugarsBoundingBox = try? topCandidate.boundingBox(for: totalSugarsTextRange) else {continue}
                        guard let totalCarbsBoundingBox = try? topCandidate.boundingBox(for: totalCarbsTextRange) else {continue}
                        
                        print(boundingBox.topRight)
                        print(totalSugarsBoundingBox.topRight)
                        print(totalCarbsBoundingBox.topLeft)
                        
                        if let hostingController = itemHighlightViews[item.id] {
                            hostingController.view.frame = CGRect(origin: item.bounds.topLeft, size: CGSize(width: abs(boundingBox.topLeft.x - boundingBox.topRight.x), height: abs(boundingBox.topLeft.y - boundingBox.bottomRight.y)))
                        }
                    }
                default:
                    return
                    
                }
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in removedItems {
                if let hostingController = itemHighlightViews[item.id] {
                    itemHighlightViews.removeValue(forKey: item.id)
                    hostingController.view.removeFromSuperview()
                    hostingController.removeFromParent()
                }
            }
        }

        
    }
    
}

//
//  DataScannerSwiftUIAdapter.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 11/16/24.
//

import Foundation
import SwiftUI
@preconcurrency import VisionKit


struct DataScannerSwiftUIAdapter: UIViewControllerRepresentable {
    
    @Binding var calories: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
 
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(recognizedDataTypes: [.text()], qualityLevel: .fast, recognizesMultipleItems: true, isHighlightingEnabled: false)
        context.coordinator.scanner = viewController
        viewController.delegate = context.coordinator

        do {
            try viewController.startScanning()

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
        let encoder = JSONEncoder()
        
        
        init(_ parent: DataScannerSwiftUIAdapter){
            self.parent = parent
            encoder.outputFormatting = .prettyPrinted
            
        }
        
        
//        func updateViaAsyncStream() async {
//            guard let scanner = scanner else {return}
//            
//            let stream = scanner.recognizedItems
//            
//            
//            for await newItems: [RecognizedItem] in stream {
//
//                if(newItems.count > 4){
//                    scanner.stopScanning()
//                    var foundTextList: [FoundText] = []
//                    
//                    for item in newItems {
//                        switch item {
//                        case .text(let text):
//                            
//                            for string in text.transcript.split(separator: " "){
//                                foundTextList.append(FoundText(text: String(string), line: text.transcript, lineTop: Float(text.bounds.topLeft.x), lineBottom: Float(text.bounds.bottomLeft.x)))
//                            }
//                            
//                            
//                        default:
//                            continue
//                        }
//                    }
//                }
//            }
//        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let scanner = self.scanner else {return}
            for item in addItems {
                
                switch item {
                case .text(let text):
                    
                    if(text.transcript.contains("Total Fat")){
                        
                        scanner.stopScanning()
                        
                        
                        Task {
                            let image = try! await scanner.capturePhoto().cgImage
                            
                            
                            
                        }
                        
                        
                        guard let totalFatTextRange = text.transcript.range(of: "Total") else {continue}
                        
                        let topCandidate = text.observation.topCandidates(1)[0]
                        
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
                    if(text.transcript.contains("Total Fat") && text.transcript.contains("Cholesterol")){
                        
                        
                        guard let totalFatTextRange = text.transcript.range(of: "Total Fat") else {continue}
                        
                        
                        let topCandidate = text.observation.topCandidates(1)[0]
                        
                        print(topCandidate.string)
                        
                        guard let boundingBox = try? topCandidate.boundingBox(for: topCandidate.string.range(of: "Total Fat")!) else {continue}
                        guard let cholesterolBoundingBox = try? topCandidate.boundingBox(for: topCandidate.string.range(of: "Cholesterol")!) else {continue}
                        
                        print("FAT")
                        print(boundingBox.boundingBox)
                        print(topCandidate.string.range(of: "Total Fat")!.lowerBound)
                        print("Top left: \(boundingBox.topLeft.x), \(boundingBox.topLeft.y)")
                        print("Bottom right: \(boundingBox.bottomRight.x), \(boundingBox.bottomRight.y)")
                        print()
                        print("CHOLESTEROL")
                        print(cholesterolBoundingBox.boundingBox)
                        print(topCandidate.string.range(of: "Cholesterol")!.lowerBound)
                        print("Top left: \(cholesterolBoundingBox.topLeft.x), \(cholesterolBoundingBox.topLeft.y)")
                        print("Bottom right: \(cholesterolBoundingBox.bottomRight.x), \(cholesterolBoundingBox.bottomRight.y)")
                        print()
                        print()
                        
                        
                        if let hostingController = itemHighlightViews[item.id] {
                            hostingController.view.frame = CGRect(origin: item.bounds.topLeft, size: CGSize(width: abs(item.bounds.topLeft.x - item.bounds.topRight.x), height: abs(item.bounds.topLeft.y - item.bounds.bottomRight.y)))
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

        
        func saveToFile(foundTextList: [String]){
            // Define the file name and path
            let fileName = "example.txt"
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(fileName)
                
                do{
                    try? FileManager.default.removeItem(at: fileURL)
                }
                
                do{
                    
                    FileManager.default.createFile(atPath: fileURL.path(), contents: nil)
                    let fileHandle = try FileHandle(forWritingTo: fileURL)
                    for foundText in foundTextList {
                        let data = try encoder.encode(foundText)
                        try fileHandle.seekToEnd()
                        try fileHandle.write(contentsOf: data)
                        print("Text written successfully!")
                    }
                    try fileHandle.close()
                    
                } catch {
                    print("Error writing to file: \(error)")
                }


                
            }
        }
        
        func sendToServer(){
            let url = URL(string: "http://192.168.1.230:3000/")!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                    print(response)
                    return
                }
                if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                    let data = data,
                    let string = String(data: data, encoding: .utf8) {
                    print(string)
                }
            }
            task.resume()
        }

        
    }
    
}

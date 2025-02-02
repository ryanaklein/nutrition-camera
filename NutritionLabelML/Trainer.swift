//
//  Trainer.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 1/19/25.
//

import Foundation
import SwiftData
import CreateML
import TabularData


struct Trainer {
    
    
    @MainActor func train() {
        let container = try! ModelContainer(for: NutritionLabel.self)
        
        let context = container.mainContext
        
        let nutritionLabels = FetchDescriptor<NutritionLabel>()
        
        let results = try! context.fetch(nutritionLabels)
        
        var labelList: [String] = []
        
        var isInCalorieStringList: [Int] = []
        var isInFatStringList: [Int] = []
        var isInCarbsStringList: [Int] = []
        var isInProteinStringList: [Int] = []
        var isGramsList: [Int] = []
        var isUnitlessList: [Int] = []
        
        var distanceToCaloriesList: [Double] = []
        var slopeToCaloriesList: [Double] = []
        
        var distanceToFatList: [Double] = []
        var slopeToFatList: [Double] = []
        
        var distanceToCarbsList: [Double] = []
        var slopeToCarbsList: [Double] = []
        
        var distanceToProteinList: [Double] = []
        var slopeToProteinList: [Double] = []
        
        for nutritionLabel in results {
            var tempLabelList: [String] = []
            
            var tempIsInCalorieStringList: [Int] = []
            var tempIsInFatStringList: [Int] = []
            var tempIsInCarbsStringList: [Int] = []
            var tempIsInProteinStringList: [Int] = []
            var tempIsGramsList: [Int] = []
            var tempIsUnitlessList: [Int] = []
            
            var tempDistanceToCaloriesList: [Double] = []
            var tempSlopeToCaloriesList: [Double] = []
            
            var tempDistanceToFatList: [Double] = []
            var tempSlopeToFatList: [Double] = []
            
            var tempDistanceToCarbsList: [Double] = []
            var tempSlopeToCarbsList: [Double] = []
            
            var tempDistanceToProteinList: [Double] = []
            var tempSlopeToProteinList: [Double] = []
            
            var noneCount = 0
            for foundString in nutritionLabel.foundStringList! {
                
                
                if noneCount > 2 && foundString.label == "none" {
                    continue
                }
                
                if foundString.label == "none"{
                    noneCount += 1
                }
            
                
                
                tempLabelList.append(foundString.label)
                tempIsInCalorieStringList.append(foundString.isInCalorieString ? 1 : 0)
                tempIsInFatStringList.append(foundString.isInFatString ? 1 : 0)
                tempIsInCarbsStringList.append(foundString.isInCarbsString ? 1 : 0)
                tempIsInProteinStringList.append(foundString.isInProteinString ? 1 : 0)
                tempIsGramsList.append(foundString.isGrams ? 1 : 0)
                tempIsUnitlessList.append(foundString.isUnitless ? 1 : 0)
                
                guard let distanceToCalories = foundString.distanceToCalories, let slopeToCalories = foundString.slopeToCalories, let distanceToFat = foundString.distanceToFat, let slopeToFat = foundString.slopeToFat, let distanceToCarbs = foundString.distanceToCarbs, let slopeToCarbs = foundString.slopeToCarbs, let distanceToProtein = foundString.distanceToProtein, let slopeToProtein = foundString.slopeToProtein else {
                    tempLabelList.removeAll()
                    tempIsInCalorieStringList.removeAll()
                    tempIsInFatStringList.removeAll()
                    tempIsInCarbsStringList.removeAll()
                    tempIsInProteinStringList.removeAll()
                    tempIsGramsList.removeAll()
                    tempIsUnitlessList.removeAll()
                    tempDistanceToCaloriesList.removeAll()
                    tempSlopeToCaloriesList.removeAll()
                    tempDistanceToFatList.removeAll()
                    tempSlopeToFatList.removeAll()
                    tempDistanceToCarbsList.removeAll()
                    tempSlopeToCarbsList.removeAll()
                    tempDistanceToProteinList.removeAll()
                    tempSlopeToProteinList.removeAll()
                    break
                }
                
                // Calories
                tempDistanceToCaloriesList.append(Double(distanceToCalories))
                tempSlopeToCaloriesList.append(Double(tan(slopeToCalories)))


                // Fat
                tempDistanceToFatList.append(Double(distanceToFat))
                tempSlopeToFatList.append(Double(slopeToFat))
                
                // Carbs
                tempDistanceToCarbsList.append(Double(distanceToCarbs))
                tempSlopeToCarbsList.append(Double(slopeToCarbs))
                
                // Protein
                tempDistanceToProteinList.append(Double(distanceToProtein))
                tempSlopeToProteinList.append(Double(slopeToProtein))
                
                
            }
            
            labelList.append(contentsOf: tempLabelList)
            isInCalorieStringList.append(contentsOf: tempIsInCalorieStringList)
            isInFatStringList.append(contentsOf: tempIsInFatStringList)
            isInCarbsStringList.append(contentsOf: tempIsInCarbsStringList)
            isInProteinStringList.append(contentsOf: tempIsInProteinStringList)
            isGramsList.append(contentsOf: tempIsGramsList)
            isUnitlessList.append(contentsOf: tempIsUnitlessList)
            
            distanceToCaloriesList.append(contentsOf: tempDistanceToCaloriesList)
            slopeToCaloriesList.append(contentsOf: tempSlopeToCaloriesList)
            
            distanceToFatList.append(contentsOf: tempDistanceToFatList)
            slopeToFatList.append(contentsOf: tempSlopeToFatList)
            
            distanceToCarbsList.append(contentsOf: tempDistanceToCarbsList)
            slopeToCarbsList.append(contentsOf: tempSlopeToCarbsList)
            
            distanceToProteinList.append(contentsOf: tempDistanceToProteinList)
            slopeToProteinList.append(contentsOf: tempSlopeToProteinList)
        }
        
        
        print(labelList.count)
        
        var dataFrame: DataFrame = [
            "label": labelList,
            "isInCalorieString": isInCalorieStringList,
            "isInFatString": isInFatStringList,
            "isInCarbsString": isInCarbsStringList,
            "isInProteinString": isInProteinStringList,
            "isGrams": isGramsList,
            "isUnitless": isUnitlessList,
            "distanceToCalories": distanceToCaloriesList,
            "slopeToCalories": slopeToCaloriesList,
            "distanceToFat": distanceToFatList,
            "slopeToFat": slopeToFatList,
            "distanceToCarbs": distanceToCarbsList,
            "slopeToCarbs": slopeToCarbsList,
            "distanceToProtein": distanceToProteinList,
            "slopeToProtein": slopeToProteinList
        ]
        
        dataFrame.sort(on: "slopeToCalories", order: .ascending)
        
        print(dataFrame.description(options: FormattingOptions(maximumLineWidth: 225, maximumRowCount: 100)))
                
        let classifier = try! MLClassifier(trainingData: dataFrame, targetColumn: "label")
        
        let classifierMetadata = MLModelMetadata(author: "Ryan Klein",
                                                shortDescription: "Predicts calories or macors",
                                                version: "1.0")
        
        try! classifier.write(toFile: "./NutritionLabelClassifier.mlmodel", metadata: classifierMetadata)
        
    }
    
}


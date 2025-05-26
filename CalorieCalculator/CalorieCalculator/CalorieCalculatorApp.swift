// CalorieTrackerApp.swift
import SwiftUI

@main
struct CalorieTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CalorieTrackerView()
            }
        }
    }
}

// NutritionData.swift
struct NutritionData {
    var calories: Double
    var fat: Double
    var fiber: Double
    var carbs: Double
    var protein: Double

    var calorieFillProgress: CGFloat {
        min(CGFloat(calories / 1500), 1.0)
    }
}






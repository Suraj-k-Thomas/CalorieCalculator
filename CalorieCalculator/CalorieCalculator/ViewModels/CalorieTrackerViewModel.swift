import Foundation
import SwiftUI

class CalorieTrackerViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var showDatePicker: Bool = false
    @Published var selectedTab: Tab = .calorie
    @Published var showFillView: Bool = false
    @Published var showActionSheet: Bool = false
    @Published var showFoodSearch: Bool = false
    @Published var trackedFoods: [Food] = []
    @Published var nutritionData: NutritionData = NutritionData(calories: 0, fat: 0, fiber: 0, carbs: 0, protein: 0)

    enum Tab {
        case calorie
        case recipe
    }

    func addFood(_ food: Food) {
        trackedFoods.append(food)
        updateNutritionData()
        showFillView = true
    }

    func updateNutritionData() {
        let totalCalories = trackedFoods.reduce(0) { $0 + ($1.nf_calories ?? 0) }
        let totalFat = trackedFoods.reduce(0) { $0 + ($1.nf_total_fat ?? 0) }
        let totalCarbs = trackedFoods.reduce(0) { $0 + ($1.nf_total_carbohydrate ?? 0) }
        let totalProtein = trackedFoods.reduce(0) { $0 + ($1.nf_protein ?? 0) }
        nutritionData = NutritionData(calories: totalCalories, fat: totalFat, fiber: 0, carbs: totalCarbs, protein: totalProtein)
    }

    func logSugar() {
        print("Log sugar")
    }

    func logExercise() {
        print("Log exercise")
    }

    func logWeight() {
        print("Log weight")
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }

    func getProgressPercentage(for nutrient: String) -> Double {
        switch nutrient.lowercased() {
        case "calorie":
            return min(nutritionData.calories / 1500, 1.0)
        case "protein":
            return min(nutritionData.protein / 100, 1.0)
        case "carbs":
            return min(nutritionData.carbs / 100, 1.0)
        default:
            return 0
        }
    }

    func toggleTab(_ tab: Tab) {
        selectedTab = tab
    }
}

//
//  NutritionViewModel.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation
import SwiftUI

class NutritionViewModel: ObservableObject {
    @Published var dailyNutrition: [DailyNutrition] = []
    @Published var commonFoods: [Food] = []
    @Published var nutritionTips: [NutritionTip] = []
    @Published var todayNutrition: DailyNutrition = DailyNutrition()
    @Published var selectedFood: Food?
    @Published var showingFoodDetail = false
    @Published var waterGoal: Double = 2000 // ml
    
    private let dataService = DataService.shared
    
    init() {
        loadData()
        setupTodayNutrition()
    }
    
    private func loadData() {
        dailyNutrition = dataService.dailyNutrition
        commonFoods = dataService.commonFoods
        nutritionTips = dataService.nutritionTips
    }
    
    private func setupTodayNutrition() {
        todayNutrition = dataService.getTodayNutrition()
    }
    
    // MARK: - Nutrition Entry Management
    
    func addNutritionEntry(food: Food, quantity: Double, unit: NutritionUnit, mealType: MealType) {
        let entry = NutritionEntry(food: food, quantity: quantity, unit: unit, mealType: mealType)
        dataService.addNutritionEntry(entry)
        setupTodayNutrition()
    }
    
    func removeNutritionEntry(_ entry: NutritionEntry) {
        if let index = todayNutrition.entries.firstIndex(where: { $0.id == entry.id }) {
            todayNutrition.entries.remove(at: index)
            updateTodayNutrition()
        }
    }
    
    func updateNutritionEntry(_ entry: NutritionEntry) {
        if let index = todayNutrition.entries.firstIndex(where: { $0.id == entry.id }) {
            todayNutrition.entries[index] = entry
            updateTodayNutrition()
        }
    }
    
    private func updateTodayNutrition() {
        if let index = dataService.dailyNutrition.firstIndex(where: { $0.id == todayNutrition.id }) {
            dataService.dailyNutrition[index] = todayNutrition
            dataService.saveAllData()
        }
    }
    
    // MARK: - Water Intake
    
    func addWaterIntake(_ amount: Double) {
        dataService.updateWaterIntake(amount)
        setupTodayNutrition()
    }
    
    func getWaterProgress() -> Double {
        return min(todayNutrition.waterIntake / waterGoal * 100, 100)
    }
    
    // MARK: - Meal Management
    
    func getEntriesForMeal(_ mealType: MealType) -> [NutritionEntry] {
        return todayNutrition.entries.filter { $0.mealType == mealType }
    }
    
    func getCaloriesForMeal(_ mealType: MealType) -> Double {
        return getEntriesForMeal(mealType).reduce(0) { $0 + $1.totalCalories }
    }
    
    func getMacrosForMeal(_ mealType: MealType) -> (protein: Double, carbs: Double, fat: Double) {
        let entries = getEntriesForMeal(mealType)
        let protein = entries.reduce(0) { $0 + $1.totalProtein }
        let carbs = entries.reduce(0) { $0 + $1.totalCarbs }
        let fat = entries.reduce(0) { $0 + $1.totalFat }
        return (protein, carbs, fat)
    }
    
    // MARK: - Food Search and Management
    
    func searchFoods(_ searchText: String) -> [Food] {
        if searchText.isEmpty {
            return commonFoods
        }
        
        return commonFoods.filter { food in
            food.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func getFoodsByCategory(_ category: FoodCategory) -> [Food] {
        return commonFoods.filter { $0.category == category }
    }
    
    func addCustomFood(_ food: Food) {
        commonFoods.append(food)
        dataService.commonFoods.append(food)
        dataService.saveAllData()
    }
    
    // MARK: - Nutrition Goals
    
    func updateNutritionGoals(calories: Double, protein: Double, carbs: Double, fat: Double) {
        todayNutrition.targetCalories = calories
        todayNutrition.targetProtein = protein
        todayNutrition.targetCarbs = carbs
        todayNutrition.targetFat = fat
        updateTodayNutrition()
    }
    
    func calculateRecommendedGoals(weight: Double, activityLevel: ActivityLevel, goal: NutritionGoal) -> NutritionGoals {
        let baseCalories = calculateBMR(weight: weight) * activityLevel.multiplier
        
        let adjustedCalories: Double
        switch goal {
        case .weightLoss:
            adjustedCalories = baseCalories - 500 // 500 calorie deficit
        case .muscleGain:
            adjustedCalories = baseCalories + 300 // 300 calorie surplus
        case .maintenance:
            adjustedCalories = baseCalories
        }
        
        let protein = weight * 2.2 // 2.2g per kg for active individuals
        let fat = adjustedCalories * 0.25 / 9 // 25% of calories from fat
        let carbs = (adjustedCalories - (protein * 4) - (fat * 9)) / 4 // Remaining calories from carbs
        
        return NutritionGoals(
            calories: adjustedCalories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }
    
    private func calculateBMR(weight: Double) -> Double {
        // Simplified BMR calculation (Mifflin-St Jeor equation for average adult)
        return 10 * weight + 6.25 * 170 - 5 * 30 + 5 // Assuming average height and age
    }
    
    // MARK: - Nutrition Analysis
    
    func getNutritionSummary() -> NutritionSummary {
        let totalCalories = todayNutrition.totalCalories
        let totalProtein = todayNutrition.totalProtein
        let totalCarbs = todayNutrition.totalCarbs
        let totalFat = todayNutrition.totalFat
        
        let calorieProgress = todayNutrition.calorieProgress
        let proteinProgress = todayNutrition.proteinProgress
        let carbsProgress = todayNutrition.carbsProgress
        let fatProgress = todayNutrition.fatProgress
        
        let remainingCalories = max(todayNutrition.targetCalories - totalCalories, 0)
        
        return NutritionSummary(
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            calorieProgress: calorieProgress,
            proteinProgress: proteinProgress,
            carbsProgress: carbsProgress,
            fatProgress: fatProgress,
            remainingCalories: remainingCalories,
            waterProgress: getWaterProgress()
        )
    }
    
    // MARK: - Nutrition Tips
    
    func getPersonalizedTips() -> [NutritionTip] {
        var personalizedTips: [NutritionTip] = []
        
        // Add tips based on current nutrition status
        if todayNutrition.calorieProgress < 80 {
            personalizedTips.append(NutritionTip(
                title: "Calorie Intake Low",
                content: "You're below your calorie target. Consider adding a healthy snack to meet your energy needs.",
                category: .general,
                isPersonalized: true
            ))
        }
        
        if todayNutrition.proteinProgress < 70 {
            personalizedTips.append(NutritionTip(
                title: "Boost Your Protein",
                content: "Your protein intake is low. Add lean meats, eggs, or protein shakes to support muscle recovery.",
                category: .muscleGain,
                isPersonalized: true
            ))
        }
        
        if getWaterProgress() < 60 {
            personalizedTips.append(NutritionTip(
                title: "Stay Hydrated",
                content: "You're behind on your water intake. Drink a glass of water now to stay properly hydrated.",
                category: .hydration,
                isPersonalized: true
            ))
        }
        
        // Add general tips
        personalizedTips.append(contentsOf: nutritionTips.shuffled().prefix(3))
        
        return personalizedTips
    }
    
    func getTipsByCategory(_ category: NutritionTipCategory) -> [NutritionTip] {
        return nutritionTips.filter { $0.category == category }
    }
    
    // MARK: - Historical Data
    
    func getWeeklyNutrition() -> [DailyNutrition] {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return dailyNutrition.filter { nutrition in
            nutrition.date >= oneWeekAgo
        }.sorted { $0.date < $1.date }
    }
    
    func getAverageCaloriesThisWeek() -> Double {
        let weeklyData = getWeeklyNutrition()
        guard !weeklyData.isEmpty else { return 0 }
        
        let totalCalories = weeklyData.reduce(0) { $0 + $1.totalCalories }
        return totalCalories / Double(weeklyData.count)
    }
    
    // MARK: - Formatting Helpers
    
    func formatCalories(_ calories: Double) -> String {
        return String(format: "%.0f cal", calories)
    }
    
    func formatMacro(_ grams: Double) -> String {
        return String(format: "%.1f g", grams)
    }
    
    func formatWater(_ ml: Double) -> String {
        if ml >= 1000 {
            return String(format: "%.1f L", ml / 1000)
        } else {
            return String(format: "%.0f ml", ml)
        }
    }
}

// MARK: - Supporting Types

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extremelyActive = "Extremely Active"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }
}

enum NutritionGoal: String, CaseIterable {
    case weightLoss = "Weight Loss"
    case maintenance = "Maintenance"
    case muscleGain = "Muscle Gain"
}

struct NutritionGoals {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}

struct NutritionSummary {
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let calorieProgress: Double
    let proteinProgress: Double
    let carbsProgress: Double
    let fatProgress: Double
    let remainingCalories: Double
    let waterProgress: Double
}

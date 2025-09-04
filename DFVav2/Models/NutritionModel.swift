//
//  NutritionModel.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation

struct NutritionEntry: Identifiable, Codable {
    let id = UUID()
    var food: Food
    var quantity: Double
    var unit: NutritionUnit
    var date: Date
    var mealType: MealType
    
    init(food: Food, quantity: Double, unit: NutritionUnit, mealType: MealType) {
        self.food = food
        self.quantity = quantity
        self.unit = unit
        self.date = Date()
        self.mealType = mealType
    }
    
    var totalCalories: Double {
        return food.caloriesPerUnit * quantity
    }
    
    var totalProtein: Double {
        return food.proteinPerUnit * quantity
    }
    
    var totalCarbs: Double {
        return food.carbsPerUnit * quantity
    }
    
    var totalFat: Double {
        return food.fatPerUnit * quantity
    }
}

struct Food: Identifiable, Codable {
    let id = UUID()
    var name: String
    var caloriesPerUnit: Double
    var proteinPerUnit: Double // in grams
    var carbsPerUnit: Double // in grams
    var fatPerUnit: Double // in grams
    var category: FoodCategory
    var defaultUnit: NutritionUnit
    
    init(name: String, caloriesPerUnit: Double, proteinPerUnit: Double, carbsPerUnit: Double, fatPerUnit: Double, category: FoodCategory, defaultUnit: NutritionUnit = .grams) {
        self.name = name
        self.caloriesPerUnit = caloriesPerUnit
        self.proteinPerUnit = proteinPerUnit
        self.carbsPerUnit = carbsPerUnit
        self.fatPerUnit = fatPerUnit
        self.category = category
        self.defaultUnit = defaultUnit
    }
}

enum FoodCategory: String, CaseIterable, Codable {
    case protein = "Protein"
    case carbs = "Carbohydrates"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case grains = "Grains"
    case nuts = "Nuts & Seeds"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .protein: return "fish.fill"
        case .carbs: return "leaf.fill"
        case .vegetables: return "carrot.fill"
        case .fruits: return "apple.logo"
        case .dairy: return "drop.fill"
        case .grains: return "circle.grid.2x2.fill"
        case .nuts: return "circle.fill"
        case .beverages: return "cup.and.saucer.fill"
        case .snacks: return "bag.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .protein: return "#E74C3C"
        case .carbs: return "#F39C12"
        case .vegetables: return "#27AE60"
        case .fruits: return "#E67E22"
        case .dairy: return "#3498DB"
        case .grains: return "#D35400"
        case .nuts: return "#8E44AD"
        case .beverages: return "#16A085"
        case .snacks: return "#F1C40F"
        case .other: return "#95A5A6"
        }
    }
}

enum NutritionUnit: String, CaseIterable, Codable {
    case grams = "g"
    case cups = "cups"
    case pieces = "pieces"
    case tablespoons = "tbsp"
    case teaspoons = "tsp"
    case ounces = "oz"
    case milliliters = "ml"
    case liters = "L"
    
    var displayName: String {
        switch self {
        case .grams: return "Grams"
        case .cups: return "Cups"
        case .pieces: return "Pieces"
        case .tablespoons: return "Tablespoons"
        case .teaspoons: return "Teaspoons"
        case .ounces: return "Ounces"
        case .milliliters: return "Milliliters"
        case .liters: return "Liters"
        }
    }
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var icon: String {
        switch self {
        case .breakfast: return "sun.max.fill"
        case .lunch: return "sun.haze.fill"
        case .dinner: return "moon.fill"
        case .snack: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .breakfast: return "#F39C12"
        case .lunch: return "#E74C3C"
        case .dinner: return "#8E44AD"
        case .snack: return "#27AE60"
        }
    }
}

struct DailyNutrition: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var entries: [NutritionEntry]
    var waterIntake: Double // in milliliters
    var targetCalories: Double
    var targetProtein: Double
    var targetCarbs: Double
    var targetFat: Double
    
    init(date: Date = Date(), targetCalories: Double = 2000, targetProtein: Double = 150, targetCarbs: Double = 250, targetFat: Double = 65) {
        self.date = date
        self.entries = []
        self.waterIntake = 0
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFat = targetFat
    }
    
    var totalCalories: Double {
        return entries.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalProtein: Double {
        return entries.reduce(0) { $0 + $1.totalProtein }
    }
    
    var totalCarbs: Double {
        return entries.reduce(0) { $0 + $1.totalCarbs }
    }
    
    var totalFat: Double {
        return entries.reduce(0) { $0 + $1.totalFat }
    }
    
    var calorieProgress: Double {
        return min(totalCalories / targetCalories * 100, 100)
    }
    
    var proteinProgress: Double {
        return min(totalProtein / targetProtein * 100, 100)
    }
    
    var carbsProgress: Double {
        return min(totalCarbs / targetCarbs * 100, 100)
    }
    
    var fatProgress: Double {
        return min(totalFat / targetFat * 100, 100)
    }
}

struct NutritionTip: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var category: NutritionTipCategory
    var isPersonalized: Bool
    
    init(title: String, content: String, category: NutritionTipCategory, isPersonalized: Bool = false) {
        self.title = title
        self.content = content
        self.category = category
        self.isPersonalized = isPersonalized
    }
}

enum NutritionTipCategory: String, CaseIterable, Codable {
    case hydration = "Hydration"
    case preWorkout = "Pre-Workout"
    case postWorkout = "Post-Workout"
    case general = "General Health"
    case weightLoss = "Weight Loss"
    case muscleGain = "Muscle Gain"
    
    var icon: String {
        switch self {
        case .hydration: return "drop.fill"
        case .preWorkout: return "clock.fill"
        case .postWorkout: return "checkmark.circle.fill"
        case .general: return "heart.fill"
        case .weightLoss: return "minus.circle.fill"
        case .muscleGain: return "plus.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .hydration: return "#3498DB"
        case .preWorkout: return "#E67E22"
        case .postWorkout: return "#27AE60"
        case .general: return "#E74C3C"
        case .weightLoss: return "#8E44AD"
        case .muscleGain: return "#F39C12"
        }
    }
}

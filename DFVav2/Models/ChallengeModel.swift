//
//  ChallengeModel.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation

struct Challenge: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var type: ChallengeType
    var targetValue: Double
    var currentProgress: Double
    var unit: String
    var startDate: Date
    var endDate: Date
    var reward: ChallengeReward
    var participants: Int
    var isCompleted: Bool
    var isGlobal: Bool
    
    init(title: String, description: String, type: ChallengeType, targetValue: Double, unit: String, duration: TimeInterval, reward: ChallengeReward, isGlobal: Bool = false) {
        self.title = title
        self.description = description
        self.type = type
        self.targetValue = targetValue
        self.currentProgress = 0
        self.unit = unit
        self.startDate = Date()
        self.endDate = Date().addingTimeInterval(duration)
        self.reward = reward
        self.participants = isGlobal ? Int.random(in: 100...5000) : 1
        self.isCompleted = false
        self.isGlobal = isGlobal
    }
    
    var progressPercentage: Double {
        return min(currentProgress / targetValue * 100, 100)
    }
    
    var remainingDays: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(days, 0)
    }
    
    var isExpired: Bool {
        return Date() > endDate
    }
}

enum ChallengeType: String, CaseIterable, Codable {
    case workout = "Workout Count"
    case calories = "Calories Burned"
    case duration = "Exercise Duration"
    case steps = "Steps"
    case distance = "Distance"
    case consistency = "Workout Streak"
    
    var icon: String {
        switch self {
        case .workout: return "figure.strengthtraining.traditional"
        case .calories: return "flame.fill"
        case .duration: return "clock.fill"
        case .steps: return "figure.walk"
        case .distance: return "location.fill"
        case .consistency: return "calendar.badge.checkmark"
        }
    }
    
    var color: String {
        switch self {
        case .workout: return "#4ECDC4"
        case .calories: return "#FF6B6B"
        case .duration: return "#45B7D1"
        case .steps: return "#96CEB4"
        case .distance: return "#FFEAA7"
        case .consistency: return "#DDA0DD"
        }
    }
}

struct ChallengeReward: Codable {
    var points: Int
    var badge: Badge?
    var title: String?
    
    init(points: Int, badge: Badge? = nil, title: String? = nil) {
        self.points = points
        self.badge = badge
        self.title = title
    }
}

struct Badge: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var icon: String
    var color: String
    var rarity: BadgeRarity
    var dateEarned: Date?
    
    init(name: String, description: String, icon: String, color: String, rarity: BadgeRarity) {
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.rarity = rarity
        self.dateEarned = nil
    }
}

enum BadgeRarity: String, CaseIterable, Codable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: String {
        switch self {
        case .common: return "#95A5A6"
        case .rare: return "#3498DB"
        case .epic: return "#9B59B6"
        case .legendary: return "#F39C12"
        }
    }
}

struct UserProgress: Codable {
    var totalPoints: Int
    var level: Int
    var badges: [Badge]
    var completedChallenges: [Challenge]
    var currentStreak: Int
    var longestStreak: Int
    var totalWorkouts: Int
    var totalCaloriesBurned: Int
    var totalExerciseTime: TimeInterval
    
    init() {
        self.totalPoints = 0
        self.level = 1
        self.badges = []
        self.completedChallenges = []
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalWorkouts = 0
        self.totalCaloriesBurned = 0
        self.totalExerciseTime = 0
    }
    
    var pointsToNextLevel: Int {
        let pointsForNextLevel = level * 1000
        return pointsForNextLevel - (totalPoints % 1000)
    }
    
    var levelProgress: Double {
        let pointsInCurrentLevel = totalPoints % 1000
        return Double(pointsInCurrentLevel) / 1000.0 * 100
    }
}

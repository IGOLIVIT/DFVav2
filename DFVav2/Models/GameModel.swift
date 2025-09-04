//
//  GameModel.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation

struct FitnessChallenge: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
    var targetValue: Double
    var currentProgress: Double
    var xpReward: Int
    var isCompleted: Bool
    var date: Date
    
    init(title: String, description: String, icon: String, targetValue: Double, xpReward: Int) {
        self.title = title
        self.description = description
        self.icon = icon
        self.targetValue = targetValue
        self.currentProgress = 0
        self.xpReward = xpReward
        self.isCompleted = false
        self.date = Date()
    }
    
    var progressPercentage: Double {
        return min(currentProgress / targetValue * 100, 100)
    }
}

struct GameAchievement: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
    var color: String
    var xpReward: Int
    var dateEarned: Date?
    var isUnlocked: Bool
    
    init(title: String, description: String, icon: String, color: String, xpReward: Int) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.xpReward = xpReward
        self.dateEarned = nil
        self.isUnlocked = false
    }
}

struct LeaderboardPlayer: Identifiable, Codable {
    var id = UUID()
    var name: String
    var score: Int
    var level: Int
    var isCurrentUser: Bool
    
    init(name: String, score: Int, level: Int, isCurrentUser: Bool = false) {
        self.name = name
        self.score = score
        self.level = level
        self.isCurrentUser = isCurrentUser
    }
}

enum QuickGameType: String, CaseIterable {
    case pushups = "Push-ups"
    case plank = "Plank Hold"
    case jumpingJacks = "Jumping Jacks"
    case squats = "Squats"
    
    var icon: String {
        switch self {
        case .pushups: return "figure.strengthtraining.traditional"
        case .plank: return "timer"
        case .jumpingJacks: return "figure.jumprope"
        case .squats: return "figure.flexibility"
        }
    }
    
    var baseXP: Int {
        switch self {
        case .pushups: return 10
        case .plank: return 15
        case .jumpingJacks: return 8
        case .squats: return 12
        }
    }
}

struct GameProgress: Codable {
    var playerLevel: Int
    var totalScore: Int
    var currentXP: Int
    var currentStreak: Int
    var longestStreak: Int
    var gamesPlayed: Int
    var lastPlayDate: Date?
    
    init() {
        self.playerLevel = 1
        self.totalScore = 0
        self.currentXP = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.gamesPlayed = 0
        self.lastPlayDate = nil
    }
    
    var xpToNextLevel: Int {
        return playerLevel * 100
    }
    
    var xpProgress: Double {
        return Double(currentXP) / Double(xpToNextLevel)
    }
}

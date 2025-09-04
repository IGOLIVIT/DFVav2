//
//  ChallengeViewModel.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation
import SwiftUI

class ChallengeViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []
    @Published var userProgress: UserProgress = UserProgress()
    @Published var selectedChallenge: Challenge?
    @Published var showingChallengeDetail = false
    
    private let dataService = DataService.shared
    
    init() {
        loadData()
        updateChallengeProgress()
    }
    
    private func loadData() {
        challenges = dataService.challenges
        userProgress = dataService.userProgress
    }
    
    // MARK: - Challenge Management
    
    func refreshChallenges() {
        loadData()
        updateChallengeProgress()
    }
    
    func completeChallenge(_ challenge: Challenge) {
        dataService.completeChallenge(challenge)
        loadData()
    }
    
    func updateChallengeProgress() {
        for i in 0..<challenges.count {
            updateProgressForChallenge(&challenges[i])
        }
        dataService.challenges = challenges
        dataService.saveAllData()
    }
    
    private func updateProgressForChallenge(_ challenge: inout Challenge) {
        switch challenge.type {
        case .workout:
            challenge.currentProgress = Double(getWorkoutCount(for: challenge))
        case .calories:
            challenge.currentProgress = Double(getCaloriesBurned(for: challenge))
        case .duration:
            challenge.currentProgress = getExerciseDuration(for: challenge)
        case .consistency:
            challenge.currentProgress = Double(getCurrentStreak())
        case .steps, .distance:
            // These would typically come from HealthKit integration
            // For now, we'll use placeholder values
            challenge.currentProgress = Double.random(in: 0...challenge.targetValue)
        }
        
        // Check if challenge is completed
        if challenge.currentProgress >= challenge.targetValue && !challenge.isCompleted {
            challenge.isCompleted = true
        }
    }
    
    private func getWorkoutCount(for challenge: Challenge) -> Int {
        let calendar = Calendar.current
        let workouts = dataService.workouts.filter { workout in
            workout.date >= challenge.startDate && workout.date <= challenge.endDate
        }
        return workouts.count
    }
    
    private func getCaloriesBurned(for challenge: Challenge) -> Int {
        let calendar = Calendar.current
        let workouts = dataService.workouts.filter { workout in
            workout.date >= challenge.startDate && workout.date <= challenge.endDate
        }
        return workouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    private func getExerciseDuration(for challenge: Challenge) -> Double {
        let calendar = Calendar.current
        let workouts = dataService.workouts.filter { workout in
            workout.date >= challenge.startDate && workout.date <= challenge.endDate
        }
        return workouts.reduce(0) { $0 + $1.duration } / 60 // Convert to minutes
    }
    
    private func getCurrentStreak() -> Int {
        return userProgress.currentStreak
    }
    
    // MARK: - Challenge Filtering
    
    var activeChallenges: [Challenge] {
        return challenges.filter { !$0.isCompleted && !$0.isExpired }
    }
    
    var completedChallenges: [Challenge] {
        return challenges.filter { $0.isCompleted }
    }
    
    var globalChallenges: [Challenge] {
        return challenges.filter { $0.isGlobal }
    }
    
    var personalChallenges: [Challenge] {
        return challenges.filter { !$0.isGlobal }
    }
    
    // MARK: - Badge Management
    
    func getRecentBadges() -> [Badge] {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return userProgress.badges.filter { badge in
            if let dateEarned = badge.dateEarned {
                return dateEarned >= oneWeekAgo
            }
            return false
        }
    }
    
    func getBadgesByRarity() -> [BadgeRarity: [Badge]] {
        return Dictionary(grouping: userProgress.badges, by: { $0.rarity })
    }
    
    // MARK: - Progress Statistics
    
    func getProgressStats() -> ProgressStats {
        let totalChallenges = challenges.count
        let completedCount = completedChallenges.count
        let activeCount = activeChallenges.count
        let completionRate = totalChallenges > 0 ? Double(completedCount) / Double(totalChallenges) * 100 : 0
        
        return ProgressStats(
            totalChallenges: totalChallenges,
            completedChallenges: completedCount,
            activeChallenges: activeCount,
            completionRate: completionRate,
            totalPoints: userProgress.totalPoints,
            currentLevel: userProgress.level,
            totalBadges: userProgress.badges.count,
            currentStreak: userProgress.currentStreak,
            longestStreak: userProgress.longestStreak
        )
    }
    
    // MARK: - Level Progress
    
    func getLevelProgress() -> (current: Int, progress: Double, pointsToNext: Int) {
        let currentLevel = userProgress.level
        let pointsInCurrentLevel = userProgress.totalPoints % 1000
        let progress = Double(pointsInCurrentLevel) / 1000.0 * 100
        let pointsToNext = 1000 - pointsInCurrentLevel
        
        return (currentLevel, progress, pointsToNext)
    }
    
    // MARK: - Challenge Creation
    
    func createCustomChallenge(title: String, description: String, type: ChallengeType, targetValue: Double, duration: TimeInterval) {
        let reward = ChallengeReward(points: Int(targetValue * 10)) // Simple point calculation
        let challenge = Challenge(
            title: title,
            description: description,
            type: type,
            targetValue: targetValue,
            unit: getUnitForChallengeType(type),
            duration: duration,
            reward: reward,
            isGlobal: false
        )
        
        challenges.append(challenge)
        dataService.addChallenge(challenge)
    }
    
    private func getUnitForChallengeType(_ type: ChallengeType) -> String {
        switch type {
        case .workout:
            return "workouts"
        case .calories:
            return "calories"
        case .duration:
            return "minutes"
        case .steps:
            return "steps"
        case .distance:
            return "km"
        case .consistency:
            return "days"
        }
    }
    
    // MARK: - Formatting Helpers
    
    func formatProgress(_ challenge: Challenge) -> String {
        let current = Int(challenge.currentProgress)
        let target = Int(challenge.targetValue)
        return "\(current) / \(target) \(challenge.unit)"
    }
    
    func formatTimeRemaining(_ challenge: Challenge) -> String {
        let days = challenge.remainingDays
        if days == 0 {
            return "Expires today"
        } else if days == 1 {
            return "1 day left"
        } else {
            return "\(days) days left"
        }
    }
}

struct ProgressStats {
    let totalChallenges: Int
    let completedChallenges: Int
    let activeChallenges: Int
    let completionRate: Double
    let totalPoints: Int
    let currentLevel: Int
    let totalBadges: Int
    let currentStreak: Int
    let longestStreak: Int
}

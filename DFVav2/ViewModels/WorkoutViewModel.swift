//
//  WorkoutViewModel.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation
import SwiftUI

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var workoutTemplates: [WorkoutTemplate] = []
    @Published var currentWorkout: Workout?
    @Published var isWorkoutActive = false
    @Published var workoutTimer: Timer?
    @Published var elapsedTime: TimeInterval = 0
    @Published var selectedTemplate: WorkoutTemplate?
    
    private let dataService = DataService.shared
    
    init() {
        loadData()
    }
    
    private func loadData() {
        workouts = dataService.workouts
        workoutTemplates = dataService.workoutTemplates
    }
    
    // MARK: - Workout Management
    
    func startWorkout(from template: WorkoutTemplate? = nil) {
        if let template = template {
            currentWorkout = Workout(
                name: template.name,
                type: template.type,
                exercises: template.exercises
            )
        } else {
            currentWorkout = Workout(name: "Custom Workout", type: .strength)
        }
        
        isWorkoutActive = true
        elapsedTime = 0
        startTimer()
    }
    
    func pauseWorkout() {
        stopTimer()
    }
    
    func resumeWorkout() {
        startTimer()
    }
    
    func finishWorkout(caloriesBurned: Int = 0) {
        guard var workout = currentWorkout else { return }
        
        stopTimer()
        workout.duration = elapsedTime
        workout.caloriesBurned = caloriesBurned > 0 ? caloriesBurned : estimateCaloriesBurned()
        
        dataService.addWorkout(workout)
        workouts = dataService.workouts
        
        // Reset workout state
        currentWorkout = nil
        isWorkoutActive = false
        elapsedTime = 0
    }
    
    func cancelWorkout() {
        stopTimer()
        currentWorkout = nil
        isWorkoutActive = false
        elapsedTime = 0
    }
    
    private func startTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    private func estimateCaloriesBurned() -> Int {
        // Simple calorie estimation based on workout type and duration
        let minutes = elapsedTime / 60
        let baseCaloriesPerMinute: Double
        
        switch currentWorkout?.type {
        case .cardio, .running, .cycling:
            baseCaloriesPerMinute = 10
        case .hiit, .crossfit:
            baseCaloriesPerMinute = 12
        case .strength:
            baseCaloriesPerMinute = 6
        case .yoga, .flexibility:
            baseCaloriesPerMinute = 3
        case .swimming:
            baseCaloriesPerMinute = 11
        case .sports:
            baseCaloriesPerMinute = 8
        default:
            baseCaloriesPerMinute = 7
        }
        
        return Int(minutes * baseCaloriesPerMinute)
    }
    
    // MARK: - Exercise Management
    
    func addExerciseToCurrentWorkout(_ exercise: Exercise) {
        currentWorkout?.exercises.append(exercise)
    }
    
    func updateExerciseInCurrentWorkout(_ exercise: Exercise) {
        guard let index = currentWorkout?.exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        currentWorkout?.exercises[index] = exercise
    }
    
    func removeExerciseFromCurrentWorkout(_ exercise: Exercise) {
        currentWorkout?.exercises.removeAll { $0.id == exercise.id }
    }
    
    // MARK: - Template Management
    
    func createTemplate(from workout: Workout) {
        let template = WorkoutTemplate(
            name: workout.name + " Template",
            type: workout.type,
            exercises: workout.exercises,
            estimatedDuration: workout.duration,
            difficulty: .intermediate
        )
        
        workoutTemplates.append(template)
        dataService.workoutTemplates.append(template)
        dataService.saveAllData()
    }
    
    // MARK: - Statistics
    
    func getWorkoutStats() -> WorkoutStats {
        let totalWorkouts = workouts.count
        let totalDuration = workouts.reduce(0) { $0 + $1.duration }
        let totalCalories = workouts.reduce(0) { $0 + $1.caloriesBurned }
        let averageDuration = totalWorkouts > 0 ? totalDuration / Double(totalWorkouts) : 0
        
        let workoutsByType = Dictionary(grouping: workouts, by: { $0.type })
        let favoriteType = workoutsByType.max(by: { $0.value.count < $1.value.count })?.key ?? .strength
        
        return WorkoutStats(
            totalWorkouts: totalWorkouts,
            totalDuration: totalDuration,
            totalCalories: totalCalories,
            averageDuration: averageDuration,
            favoriteWorkoutType: favoriteType
        )
    }
    
    func getWeeklyWorkouts() -> [Workout] {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return workouts.filter { workout in
            workout.date >= oneWeekAgo
        }
    }
    
    func getMonthlyWorkouts() -> [Workout] {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        return workouts.filter { workout in
            workout.date >= oneMonthAgo
        }
    }
    
    // MARK: - Formatted Time
    
    func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct WorkoutStats {
    let totalWorkouts: Int
    let totalDuration: TimeInterval
    let totalCalories: Int
    let averageDuration: TimeInterval
    let favoriteWorkoutType: WorkoutType
}

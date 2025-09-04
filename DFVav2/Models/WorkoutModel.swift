//
//  WorkoutModel.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation

struct Workout: Identifiable, Codable {
    let id = UUID()
    var name: String
    var type: WorkoutType
    var duration: TimeInterval // in seconds
    var caloriesBurned: Int
    var date: Date
    var exercises: [Exercise]
    var notes: String
    
    init(name: String, type: WorkoutType, duration: TimeInterval = 0, caloriesBurned: Int = 0, exercises: [Exercise] = [], notes: String = "") {
        self.name = name
        self.type = type
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.date = Date()
        self.exercises = exercises
        self.notes = notes
    }
}

enum WorkoutType: String, CaseIterable, Codable {
    case cardio = "Cardio"
    case strength = "Strength Training"
    case flexibility = "Flexibility"
    case sports = "Sports"
    case yoga = "Yoga"
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case hiit = "HIIT"
    case crossfit = "CrossFit"
    
    var icon: String {
        switch self {
        case .cardio: return "heart.fill"
        case .strength: return "dumbbell.fill"
        case .flexibility: return "figure.flexibility"
        case .sports: return "sportscourt.fill"
        case .yoga: return "figure.yoga"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .hiit: return "timer"
        case .crossfit: return "figure.strengthtraining.traditional"
        }
    }
    
    var color: String {
        switch self {
        case .cardio: return "#FF6B6B"
        case .strength: return "#4ECDC4"
        case .flexibility: return "#45B7D1"
        case .sports: return "#96CEB4"
        case .yoga: return "#FFEAA7"
        case .running: return "#DDA0DD"
        case .cycling: return "#98D8C8"
        case .swimming: return "#74B9FF"
        case .hiit: return "#FD79A8"
        case .crossfit: return "#FDCB6E"
        }
    }
}

struct Exercise: Identifiable, Codable {
    let id = UUID()
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double // in kg
    var restTime: TimeInterval // in seconds
    var notes: String
    
    init(name: String, sets: Int = 1, reps: Int = 1, weight: Double = 0, restTime: TimeInterval = 60, notes: String = "") {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.restTime = restTime
        self.notes = notes
    }
}

struct WorkoutTemplate: Identifiable, Codable {
    let id = UUID()
    var name: String
    var type: WorkoutType
    var exercises: [Exercise]
    var estimatedDuration: TimeInterval
    var difficulty: DifficultyLevel
    
    init(name: String, type: WorkoutType, exercises: [Exercise] = [], estimatedDuration: TimeInterval = 0, difficulty: DifficultyLevel = .beginner) {
        self.name = name
        self.type = type
        self.exercises = exercises
        self.estimatedDuration = estimatedDuration
        self.difficulty = difficulty
    }
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .beginner: return "#4CAF50"
        case .intermediate: return "#FF9800"
        case .advanced: return "#F44336"
        case .expert: return "#9C27B0"
        }
    }
}

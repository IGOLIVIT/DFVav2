//
//  FitnessTapGameViewModel.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation
import SwiftUI

// MARK: - Game Models

struct FitnessIcon: Identifiable {
    let id = UUID()
    var position: CGPoint
    var systemName: String
    var color: String
    var size: CGFloat
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
    var lifespan: TimeInterval
    var createdAt: Date
    
    init(position: CGPoint, systemName: String, color: String, size: CGFloat = 60, lifespan: TimeInterval = 2.0) {
        self.position = position
        self.systemName = systemName
        self.color = color
        self.size = size
        self.lifespan = lifespan
        self.createdAt = Date()
    }
    
    var isExpired: Bool {
        Date().timeIntervalSince(createdAt) > lifespan
    }
}

enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}

// MARK: - Game ViewModel

class FitnessTapGameViewModel: ObservableObject {
    // Game State
    @Published var gameState: GameState = .menu
    @Published var activeIcons: [FitnessIcon] = []
    @Published var currentScore: Int = 0
    @Published var lives: Int = 3
    @Published var timeRemaining: TimeInterval = 30.0
    @Published var sessionTaps: Int = 0
    
    // Game Stats
    @Published var bestScore: Int = 0
    @Published var gamesPlayed: Int = 0
    @Published var totalTaps: Int = 0
    @Published var playerLevel: Int = 1
    
    // Game Mechanics
    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    private let maxIcons = 5
    private var spawnRate: TimeInterval = 1.5
    private var gameSpeed: Double = 1.0
    
    // Fitness Icons Data
    private let fitnessIcons = [
        ("dumbbell.fill", "#E74C3C"),
        ("figure.run", "#3498DB"),
        ("heart.fill", "#E91E63"),
        ("flame.fill", "#FF5722"),
        ("figure.strengthtraining.traditional", "#9C27B0"),
        ("timer", "#FF9800"),
        ("figure.flexibility", "#4CAF50"),
        ("sportscourt.fill", "#2196F3")
    ]
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadGameStats()
    }
    
    // MARK: - Game Controls
    
    func startGame() {
        gameState = .playing
        currentScore = 0
        lives = 3
        timeRemaining = 30.0
        sessionTaps = 0
        activeIcons.removeAll()
        gameSpeed = 1.0
        spawnRate = 1.5
        
        startGameTimer()
        startSpawnTimer()
    }
    
    func pauseGame() {
        gameState = .paused
        stopTimers()
    }
    
    func resumeGame() {
        gameState = .playing
        startGameTimer()
        startSpawnTimer()
    }
    
    func endGame() {
        gameState = .gameOver
        stopTimers()
        
        // Update stats
        gamesPlayed += 1
        totalTaps += sessionTaps
        
        if currentScore > bestScore {
            bestScore = currentScore
        }
        
        // Calculate level based on total taps
        playerLevel = (totalTaps / 100) + 1
        
        saveGameStats()
    }
    
    func backToMenu() {
        gameState = .menu
        stopTimers()
        activeIcons.removeAll()
    }
    
    // MARK: - Game Logic
    
    func tapIcon(_ icon: FitnessIcon) {
        // Remove tapped icon
        activeIcons.removeAll { $0.id == icon.id }
        
        // Add score
        currentScore += 10
        sessionTaps += 1
        
        // Add tap animation effect
        withAnimation(.easeOut(duration: 0.2)) {
            // Icon tap feedback handled in view
        }
    }
    
    private func spawnIcon() {
        guard activeIcons.count < maxIcons else { return }
        
        let randomIcon = fitnessIcons.randomElement()!
        let randomX = Double.random(in: 0.1...0.9)
        let randomY = Double.random(in: 0.1...0.8)
        let position = CGPoint(x: randomX, y: randomY)
        
        let icon = FitnessIcon(
            position: position,
            systemName: randomIcon.0,
            color: randomIcon.1,
            size: CGFloat.random(in: 50...80),
            lifespan: TimeInterval.random(in: 1.5...3.0)
        )
        
        activeIcons.append(icon)
    }
    
    private func updateGame() {
        // Remove expired icons and lose life
        let expiredIcons = activeIcons.filter { $0.isExpired }
        if !expiredIcons.isEmpty {
            activeIcons.removeAll { $0.isExpired }
            lives -= expiredIcons.count
            
            if lives <= 0 {
                endGame()
                return
            }
        }
        
        // Update time
        timeRemaining -= 0.1
        if timeRemaining <= 0 {
            endGame()
            return
        }
        
        // Increase difficulty over time
        if Int(timeRemaining) % 10 == 0 && gameSpeed < 2.0 {
            gameSpeed += 0.1
            spawnRate = max(0.5, spawnRate - 0.1)
        }
    }
    
    // MARK: - Timers
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateGame()
        }
    }
    
    private func startSpawnTimer() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnRate, repeats: true) { _ in
            self.spawnIcon()
        }
    }
    
    private func stopTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    // MARK: - Data Persistence
    
    private func loadGameStats() {
        bestScore = userDefaults.integer(forKey: "bestScore")
        gamesPlayed = userDefaults.integer(forKey: "gamesPlayed")
        totalTaps = userDefaults.integer(forKey: "totalTaps")
        playerLevel = max(1, userDefaults.integer(forKey: "playerLevel"))
        
        if playerLevel == 0 {
            playerLevel = 1
        }
    }
    
    private func saveGameStats() {
        userDefaults.set(bestScore, forKey: "bestScore")
        userDefaults.set(gamesPlayed, forKey: "gamesPlayed")
        userDefaults.set(totalTaps, forKey: "totalTaps")
        userDefaults.set(playerLevel, forKey: "playerLevel")
    }
}

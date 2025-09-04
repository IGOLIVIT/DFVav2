//
//  NutritionView.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import SwiftUI

struct NutritionView: View {
    @StateObject private var viewModel = NutritionViewModel()
    @State private var selectedTab = 0
    @State private var showingAddFood = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Daily Summary Card
                    DailySummaryCard(viewModel: viewModel)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Tab Bar
                    HStack {
                        TabButton(title: "Today", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "Tips", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        TabButton(title: "History", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        TodayNutritionTab(viewModel: viewModel)
                            .tag(0)
                        
                        NutritionTipsTab(viewModel: viewModel)
                            .tag(1)
                        
                        NutritionHistoryTab(viewModel: viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFood = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#FE284A"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(viewModel: viewModel)
        }
    }
}

struct DailySummaryCard: View {
    @ObservedObject var viewModel: NutritionViewModel
    
    var body: some View {
        let summary = viewModel.getNutritionSummary()
        
        VStack(spacing: 16) {
            // Calories section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(Int(summary.totalCalories)) / \(Int(viewModel.todayNutrition.targetCalories))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#FE284A"))
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: summary.calorieProgress / 100,
                    color: Color(hex: "#FE284A")
                )
                .frame(width: 60, height: 60)
            }
            
            // Macros section
            HStack(spacing: 20) {
                MacroProgressView(
                    title: "Protein",
                    current: summary.totalProtein,
                    target: viewModel.todayNutrition.targetProtein,
                    progress: summary.proteinProgress,
                    color: "#E74C3C"
                )
                
                MacroProgressView(
                    title: "Carbs",
                    current: summary.totalCarbs,
                    target: viewModel.todayNutrition.targetCarbs,
                    progress: summary.carbsProgress,
                    color: "#F39C12"
                )
                
                MacroProgressView(
                    title: "Fat",
                    current: summary.totalFat,
                    target: viewModel.todayNutrition.targetFat,
                    progress: summary.fatProgress,
                    color: "#27AE60"
                )
            }
            
            // Water intake
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                
                Text("Water: \(viewModel.formatWater(viewModel.todayNutrition.waterIntake)) / \(viewModel.formatWater(viewModel.waterGoal))")
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(summary.waterProgress))%")
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 6)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct MacroProgressView: View {
    let title: String
    let current: Double
    let target: Double
    let progress: Double
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text("\(Int(current))g")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color(hex: color))
                        .frame(width: geometry.size.width * min(progress / 100, 1.0), height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 4)
            
            Text("\(Int(target))g")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

struct TodayNutritionTab: View {
    @ObservedObject var viewModel: NutritionViewModel
    @State private var showingWaterInput = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Water intake section
                WaterIntakeCard(viewModel: viewModel)
                
                // Meals sections
                ForEach(MealType.allCases, id: \.self) { mealType in
                    MealSection(mealType: mealType, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
}

struct WaterIntakeCard: View {
    @ObservedObject var viewModel: NutritionViewModel
    @State private var showingWaterInput = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                
                Text("Water Intake")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("+250ml") {
                    viewModel.addWaterIntake(250)
                }
                .buttonStyle(SmallButtonStyle())
            }
            
            HStack {
                Text(viewModel.formatWater(viewModel.todayNutrition.waterIntake))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("/ \(viewModel.formatWater(viewModel.waterGoal))")
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Button("Custom") {
                    showingWaterInput = true
                }
                .buttonStyle(SmallButtonStyle())
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * min(viewModel.getWaterProgress() / 100, 1.0), height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut, value: viewModel.getWaterProgress())
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .alert("Add Water", isPresented: $showingWaterInput) {
            // This would need a custom alert implementation for iOS 15.6
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct MealSection: View {
    let mealType: MealType
    @ObservedObject var viewModel: NutritionViewModel
    @State private var showingAddFood = false
    
    var body: some View {
        let entries = viewModel.getEntriesForMeal(mealType)
        let calories = viewModel.getCaloriesForMeal(mealType)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: mealType.icon)
                    .foregroundColor(Color(hex: mealType.color))
                
                Text(mealType.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(calories)) cal")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#FE284A"))
                
                Button(action: {
                    showingAddFood = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "#FE284A"))
                }
            }
            
            if entries.isEmpty {
                Text("No food logged for \(mealType.rawValue.lowercased())")
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                ForEach(entries, id: \.id) { entry in
                    FoodEntryRow(entry: entry, viewModel: viewModel)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(viewModel: viewModel, selectedMealType: mealType)
        }
    }
}

struct FoodEntryRow: View {
    let entry: NutritionEntry
    @ObservedObject var viewModel: NutritionViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.food.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(Int(entry.quantity)) \(entry.unit.rawValue)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(entry.totalCalories)) cal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#FE284A"))
                
                Text("P: \(Int(entry.totalProtein))g")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button("Delete") {
                viewModel.removeNutritionEntry(entry)
            }
            .tint(.red)
        }
    }
}

struct NutritionTipsTab: View {
    @ObservedObject var viewModel: NutritionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Personalized tips section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Personalized for You")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.getPersonalizedTips().prefix(3), id: \.id) { tip in
                        NutritionTipCard(tip: tip, isPersonalized: true)
                            .padding(.horizontal)
                    }
                }
                
                // General tips by category
                ForEach(NutritionTipCategory.allCases, id: \.self) { category in
                    let tips = viewModel.getTipsByCategory(category)
                    if !tips.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(tips.prefix(2), id: \.id) { tip in
                                NutritionTipCard(tip: tip)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct NutritionTipCard: View {
    let tip: NutritionTip
    var isPersonalized: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tip.category.icon)
                    .foregroundColor(Color(hex: tip.category.color))
                
                Text(tip.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isPersonalized {
                    Text("For You")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#FE284A").opacity(0.3))
                        .foregroundColor(Color(hex: "#FE284A"))
                        .cornerRadius(8)
                }
            }
            
            Text(tip.content)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.white.opacity(isPersonalized ? 0.15 : 0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPersonalized ? Color(hex: "#FE284A") : Color.clear, lineWidth: 1)
        )
    }
}

struct NutritionHistoryTab: View {
    @ObservedObject var viewModel: NutritionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Weekly average
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Week")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Average Daily Calories")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.getAverageCaloriesThisWeek())) cal")
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "#FE284A"))
                        }
                        
                        HStack {
                            Text("Days Logged")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("\(viewModel.getWeeklyNutrition().count) / 7")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Daily history
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Days")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.getWeeklyNutrition().reversed(), id: \.id) { dailyNutrition in
                        DailyNutritionRow(dailyNutrition: dailyNutrition)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct DailyNutritionRow: View {
    let dailyNutrition: DailyNutrition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(dailyNutrition.date))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(dailyNutrition.totalCalories)) cal")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#FE284A"))
            }
            
            HStack {
                MacroLabel(title: "P", value: Int(dailyNutrition.totalProtein), color: "#E74C3C")
                MacroLabel(title: "C", value: Int(dailyNutrition.totalCarbs), color: "#F39C12")
                MacroLabel(title: "F", value: Int(dailyNutrition.totalFat), color: "#27AE60")
                
                Spacer()
                
                Text("\(dailyNutrition.entries.count) items")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct MacroLabel: View {
    let title: String
    let value: Int
    let color: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color(hex: color))
            
            Text("\(value)g")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Supporting Views

struct AddFoodView: View {
    @ObservedObject var viewModel: NutritionViewModel
    var selectedMealType: MealType = .breakfast
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var selectedFood: Food?
    @State private var quantity = ""
    @State private var selectedUnit: NutritionUnit = .grams
    @State private var mealType: MealType
    
    init(viewModel: NutritionViewModel, selectedMealType: MealType = .breakfast) {
        self.viewModel = viewModel
        self._mealType = State(initialValue: selectedMealType)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Search bar
                    TextField("Search foods...", text: $searchText)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    // Food list
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.searchFoods(searchText), id: \.id) { food in
                                FoodSearchRow(food: food) {
                                    selectedFood = food
                                    selectedUnit = food.defaultUnit
                                }
                            }
                        }
                    }
                    
                    if let food = selectedFood {
                        // Food details and quantity input
                        VStack(spacing: 16) {
                            Text("Adding: \(food.name)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                TextField("Quantity", text: $quantity)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .frame(width: 100)
                                
                                Picker("Unit", selection: $selectedUnit) {
                                    ForEach(NutritionUnit.allCases, id: \.self) { unit in
                                        Text(unit.displayName).tag(unit)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(Color(hex: "#FE284A"))
                            }
                            
                            Picker("Meal", selection: $mealType) {
                                ForEach(MealType.allCases, id: \.self) { meal in
                                    Text(meal.rawValue).tag(meal)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(Color(hex: "#FE284A"))
                            
                            Button("Add Food") {
                                if let qty = Double(quantity) {
                                    viewModel.addNutritionEntry(
                                        food: food,
                                        quantity: qty,
                                        unit: selectedUnit,
                                        mealType: mealType
                                    )
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(quantity.isEmpty)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#FE284A"))
            )
            .preferredColorScheme(.dark)
        }
    }
}

struct FoodSearchRow: View {
    let food: Food
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: food.category.icon)
                    .foregroundColor(Color(hex: food.category.color))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(food.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(Int(food.caloriesPerUnit)) cal/\(food.defaultUnit.rawValue)")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#FE284A"))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct SmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(Color(hex: "#FE284A"))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    NutritionView()
}

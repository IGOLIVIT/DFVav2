//
//  WorkoutView.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showingNewWorkout = false
    @State private var showingTemplates = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom tab bar
                    HStack {
                        TabButton(title: "Active", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "History", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        TabButton(title: "Templates", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        ActiveWorkoutTab(viewModel: viewModel)
                            .tag(0)
                        
                        WorkoutHistoryTab(viewModel: viewModel)
                            .tag(1)
                        
                        WorkoutTemplatesTab(viewModel: viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewWorkout = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#FE284A"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewWorkout) {
            NewWorkoutView(viewModel: viewModel)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "#FE284A") : .white.opacity(0.6))
                
                Rectangle()
                    .fill(isSelected ? Color(hex: "#FE284A") : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActiveWorkoutTab: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isWorkoutActive {
                    ActiveWorkoutCard(viewModel: viewModel)
                } else {
                    QuickStartCard(viewModel: viewModel)
                }
                
                WorkoutStatsCard(viewModel: viewModel)
                
                RecentWorkoutsCard(viewModel: viewModel)
            }
            .padding()
        }
    }
}

struct ActiveWorkoutCard: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var showingWorkoutDetail = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Active Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentWorkout?.name ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#FE284A"))
                }
                
                Spacer()
                
                VStack {
                    Text(viewModel.formattedTime(viewModel.elapsedTime))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Elapsed")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            HStack(spacing: 12) {
                Button("Pause") {
                    viewModel.pauseWorkout()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Finish") {
                    viewModel.finishWorkout()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Details") {
                    showingWorkoutDetail = true
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .sheet(isPresented: $showingWorkoutDetail) {
            WorkoutDetailView(workout: viewModel.currentWorkout ?? Workout(name: "Unknown", type: .strength))
        }
    }
}

struct QuickStartCard: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var showingTemplates = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Ready to workout?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Choose a template or start a custom workout")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button("Quick Start") {
                    viewModel.startWorkout()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Templates") {
                    showingTemplates = true
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .sheet(isPresented: $showingTemplates) {
            WorkoutTemplatesSheet(viewModel: viewModel)
        }
    }
}

struct WorkoutStatsCard: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        let _ = viewModel.getWorkoutStats()
        
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                StatItem(
                    title: "Workouts",
                    value: "\(viewModel.getWeeklyWorkouts().count)",
                    icon: "figure.strengthtraining.traditional"
                )
                
                StatItem(
                    title: "Duration",
                    value: viewModel.formattedTime(viewModel.getWeeklyWorkouts().reduce(0) { $0 + $1.duration }),
                    icon: "clock.fill"
                )
                
                StatItem(
                    title: "Calories",
                    value: "\(viewModel.getWeeklyWorkouts().reduce(0) { $0 + $1.caloriesBurned })",
                    icon: "flame.fill"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "#FE284A"))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecentWorkoutsCard: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Workouts")
                .font(.headline)
                .foregroundColor(.white)
            
            if viewModel.workouts.isEmpty {
                Text("No workouts yet. Start your first workout!")
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
            } else {
                ForEach(Array(viewModel.workouts.prefix(3)), id: \.id) { workout in
                    WorkoutRowView(workout: workout)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            Image(systemName: workout.type.icon)
                .font(.title2)
                .foregroundColor(Color(hex: workout.type.color))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(workout.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(workout.caloriesBurned) cal")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#FE284A"))
                
                Text(formatDuration(workout.duration))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct WorkoutHistoryTab: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.workouts.sorted { $0.date > $1.date }, id: \.id) { workout in
                    WorkoutHistoryRow(workout: workout)
                }
            }
            .padding()
        }
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: workout.type.icon)
                            .foregroundColor(Color(hex: workout.type.color))
                        
                        Text(workout.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(formatDate(workout.date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack {
                        Label("\(workout.caloriesBurned) cal", systemImage: "flame.fill")
                        Label(formatDuration(workout.duration), systemImage: "clock.fill")
                        Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingDetail) {
            WorkoutDetailView(workout: workout)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct WorkoutTemplatesTab: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.workoutTemplates, id: \.id) { template in
                    WorkoutTemplateRow(template: template, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
}

struct WorkoutTemplateRow: View {
    let template: WorkoutTemplate
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: template.type.icon)
                    .foregroundColor(Color(hex: template.type.color))
                
                VStack(alignment: .leading) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(template.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text(template.difficulty.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: template.difficulty.color).opacity(0.3))
                    .foregroundColor(Color(hex: template.difficulty.color))
                    .cornerRadius(8)
            }
            
            HStack {
                Label(formatDuration(template.estimatedDuration), systemImage: "clock.fill")
                Label("\(template.exercises.count) exercises", systemImage: "list.bullet")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
            
            Button("Start Workout") {
                viewModel.startWorkout(from: template)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

// MARK: - Supporting Views

struct NewWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var workoutName = ""
    @State private var selectedType: WorkoutType = .strength
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Name")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        TextField("Enter workout name", text: $workoutName)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Type")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Picker("Type", selection: $selectedType) {
                            ForEach(WorkoutType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(Color(hex: "#FE284A"))
                    }
                    
                    Spacer()
                    
                    Button("Create Workout") {
                        let _ = Workout(name: workoutName.isEmpty ? "Custom Workout" : workoutName, type: selectedType)
                        viewModel.startWorkout()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            }
            .navigationTitle("New Workout")
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

struct WorkoutTemplatesSheet: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.workoutTemplates, id: \.id) { template in
                            Button(action: {
                                viewModel.startWorkout(from: template)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                WorkoutTemplateRow(template: template, viewModel: viewModel)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#FE284A"))
            )
            .preferredColorScheme(.dark)
        }
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Workout info
                        VStack(alignment: .leading, spacing: 12) {
                            Text(workout.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Label(workout.type.rawValue, systemImage: workout.type.icon)
                                Spacer()
                                Label(formatDate(workout.date), systemImage: "calendar")
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Stats
                        HStack(spacing: 20) {
                            StatItem(
                                title: "Duration",
                                value: formatDuration(workout.duration),
                                icon: "clock.fill"
                            )
                            
                            StatItem(
                                title: "Calories",
                                value: "\(workout.caloriesBurned)",
                                icon: "flame.fill"
                            )
                            
                            StatItem(
                                title: "Exercises",
                                value: "\(workout.exercises.count)",
                                icon: "list.bullet"
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Exercises
                        if !workout.exercises.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Exercises")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ForEach(workout.exercises, id: \.id) { exercise in
                                    ExerciseRow(exercise: exercise)
                                }
                            }
                        }
                        
                        // Notes
                        if !workout.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(workout.notes)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#FE284A"))
            )
            .preferredColorScheme(.dark)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(exercise.sets) sets × \(exercise.reps) reps")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            if exercise.weight > 0 {
                Text("\(Int(exercise.weight)) kg")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#FE284A"))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(minHeight: 44)
            .background(Color(hex: "#FE284A"))
            .cornerRadius(22)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color(hex: "#FE284A"))
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(minHeight: 44)
            .background(Color.white.opacity(0.1))
            .cornerRadius(22)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    WorkoutView()
}

//
//  OnboardingView.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var userWeight = ""
    @State private var activityLevel: ActivityLevel = .moderatelyActive
    @State private var fitnessGoal: NutritionGoal = .maintenance
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1D1F30"),
                    Color(hex: "#2A2D47")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Progress indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentPage ? Color(hex: "#FE284A") : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        if index < pages.count - 1 {
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        } else {
                            // User setup page
                            UserSetupView(
                                userName: $userName,
                                userWeight: $userWeight,
                                activityLevel: $activityLevel,
                                fitnessGoal: $fitnessGoal
                            )
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    
                    Spacer()
                    
                    Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                        if currentPage == pages.count - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#FE284A"))
                    .cornerRadius(25)
                    .disabled(currentPage == pages.count - 1 && (userName.isEmpty || userWeight.isEmpty))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func completeOnboarding() {
        // Save user preferences
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userWeight, forKey: "userWeight")
        UserDefaults.standard.set(activityLevel.rawValue, forKey: "activityLevel")
        UserDefaults.standard.set(fitnessGoal.rawValue, forKey: "fitnessGoal")
        
        hasCompletedOnboarding = true
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#FE284A"))
                .padding(.top, 50)
            
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
        }
    }
}

struct UserSetupView: View {
    @Binding var userName: String
    @Binding var userWeight: String
    @Binding var activityLevel: ActivityLevel
    @Binding var fitnessGoal: NutritionGoal
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#FE284A"))
                .padding(.top, 20)
            
            Text("Let's personalize your experience")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                // Name input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Name")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter your name", text: $userName)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Weight input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weight (kg)")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter your weight", text: $userWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Activity level
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity Level")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(Color(hex: "#FE284A"))
                }
                
                // Fitness goal
                VStack(alignment: .leading, spacing: 12) {
                    Text("Fitness Goal")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Fitness Goal", selection: $fitnessGoal) {
                        ForEach(NutritionGoal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(Color(hex: "#FE284A"))
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 44)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    
    static let allPages = [
        OnboardingPage(
            title: "Welcome to SportsPulse",
            description: "Your ultimate fitness companion for tracking workouts, challenges, and nutrition. Let's start your journey to a healthier you!",
            icon: "heart.fill"
        ),
        OnboardingPage(
            title: "Track Your Workouts",
            description: "Create custom workout routines, track your progress, and monitor your fitness journey with detailed statistics and insights.",
            icon: "figure.strengthtraining.traditional"
        ),
        OnboardingPage(
            title: "Take on Challenges",
            description: "Join exciting fitness challenges, compete with friends, earn badges, and unlock achievements as you reach your goals.",
            icon: "trophy.fill"
        ),
        OnboardingPage(
            title: "Monitor Your Nutrition",
            description: "Log your meals, track macros, get personalized nutrition tips, and maintain a balanced diet for optimal performance.",
            icon: "leaf.fill"
        ),
        OnboardingPage(
            title: "Setup Your Profile",
            description: "Tell us a bit about yourself so we can personalize your experience and provide better recommendations.",
            icon: "person.circle.fill"
        )
    ]
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
}

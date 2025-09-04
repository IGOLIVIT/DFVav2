//
//  ChallengeView.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import SwiftUI

struct ChallengeView: View {
    @StateObject private var viewModel = ChallengeViewModel()
    @State private var selectedTab = 0
    @State private var showingNewChallenge = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // User Level Card
                    UserLevelCard(viewModel: viewModel)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Tab Bar
                    HStack {
                        TabButton(title: "Active", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "Completed", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        TabButton(title: "Badges", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        ActiveChallengesTab(viewModel: viewModel)
                            .tag(0)
                        
                        CompletedChallengesTab(viewModel: viewModel)
                            .tag(1)
                        
                        BadgesTab(viewModel: viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewChallenge = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#FE284A"))
                    }
                }
            }
            .onAppear {
                viewModel.refreshChallenges()
            }
        }
        .sheet(isPresented: $showingNewChallenge) {
            NewChallengeView(viewModel: viewModel)
        }
    }
}

struct UserLevelCard: View {
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        let levelInfo = viewModel.getLevelProgress()
        
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(levelInfo.current)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.userProgress.totalPoints) points")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(levelInfo.pointsToNext) to next level")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("🏆 \(viewModel.userProgress.badges.count) badges")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#FE284A"))
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color(hex: "#FE284A"))
                        .frame(width: geometry.size.width * (levelInfo.progress / 100), height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut, value: levelInfo.progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ActiveChallengesTab: View {
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Global challenges section
                if !viewModel.globalChallenges.filter({ !$0.isCompleted }).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Global Challenges")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.globalChallenges.filter { !$0.isCompleted }, id: \.id) { challenge in
                            ChallengeCard(challenge: challenge, viewModel: viewModel)
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Personal challenges section
                if !viewModel.personalChallenges.filter({ !$0.isCompleted }).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Challenges")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.personalChallenges.filter { !$0.isCompleted }, id: \.id) { challenge in
                            ChallengeCard(challenge: challenge, viewModel: viewModel)
                                .padding(.horizontal)
                        }
                    }
                }
                
                if viewModel.activeChallenges.isEmpty {
                    EmptyStateView(
                        icon: "trophy",
                        title: "No Active Challenges",
                        description: "Create a new challenge to get started!"
                    )
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    @ObservedObject var viewModel: ChallengeViewModel
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: challenge.type.color))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if challenge.isGlobal {
                    Image(systemName: "globe")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#FE284A"))
                }
            }
            
            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(viewModel.formatProgress(challenge))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(challenge.progressPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#FE284A"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color(hex: challenge.type.color))
                            .frame(width: geometry.size.width * (challenge.progressPercentage / 100), height: 6)
                            .cornerRadius(3)
                            .animation(.easeInOut, value: challenge.progressPercentage)
                    }
                }
                .frame(height: 6)
            }
            
            // Footer
            HStack {
                                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(viewModel.formatTimeRemaining(challenge))
                            .font(.caption2)
                    }
                    .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    if challenge.isGlobal {
                        Text("\(challenge.participants) participants")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Text("\(challenge.reward.points) pts")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#FE284A"))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            ChallengeDetailView(challenge: challenge, viewModel: viewModel)
        }
    }
}

struct CompletedChallengesTab: View {
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.completedChallenges, id: \.id) { challenge in
                    CompletedChallengeCard(challenge: challenge)
                        .padding(.horizontal)
                }
                
                if viewModel.completedChallenges.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "No Completed Challenges",
                        description: "Complete challenges to see them here!"
                    )
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
}

struct CompletedChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        HStack {
            Image(systemName: challenge.type.icon)
                .font(.title2)
                .foregroundColor(Color(hex: challenge.type.color))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Completed")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("+\(challenge.reward.points) pts")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#FE284A"))
                
                if challenge.reward.badge != nil {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct BadgesTab: View {
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Recent badges
                if !viewModel.getRecentBadges().isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recently Earned")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.getRecentBadges(), id: \.id) { badge in
                                    BadgeCard(badge: badge, isRecent: true)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // All badges by rarity
                ForEach(BadgeRarity.allCases.reversed(), id: \.self) { rarity in
                    let badges = viewModel.getBadgesByRarity()[rarity] ?? []
                    if !badges.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(rarity.rawValue) Badges")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(badges, id: \.id) { badge in
                                    BadgeCard(badge: badge)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                if viewModel.userProgress.badges.isEmpty {
                    EmptyStateView(
                        icon: "star",
                        title: "No Badges Yet",
                        description: "Complete challenges to earn badges!"
                    )
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    var isRecent: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: badge.color).opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: badge.icon)
                    .font(.title)
                    .foregroundColor(Color(hex: badge.color))
            }
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if let dateEarned = badge.dateEarned {
                    Text(formatDate(dateEarned))
                        .font(.caption)
                        .foregroundColor(Color(hex: badge.rarity.color))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(isRecent ? 0.15 : 0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isRecent ? Color(hex: "#FE284A") : Color.clear, lineWidth: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}

// MARK: - Supporting Views

struct NewChallengeView: View {
    @ObservedObject var viewModel: ChallengeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: ChallengeType = .workout
    @State private var targetValue = ""
    @State private var selectedDuration = 7 // days
    
    private let durations = [1, 3, 7, 14, 30]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Challenge Title")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextField("Enter challenge title", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextField("Enter description", text: $description)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Challenge Type")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Picker("Type", selection: $selectedType) {
                                ForEach(ChallengeType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(Color(hex: "#FE284A"))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Value")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextField("Enter target value", text: $targetValue)
                                .keyboardType(.numberPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Picker("Duration", selection: $selectedDuration) {
                                ForEach(durations, id: \.self) { days in
                                    Text("\(days) day\(days == 1 ? "" : "s")").tag(days)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(Color(hex: "#FE284A"))
                        }
                        
                        Spacer()
                        
                        Button("Create Challenge") {
                            if let target = Double(targetValue) {
                                let duration = TimeInterval(selectedDuration * 24 * 60 * 60)
                                viewModel.createCustomChallenge(
                                    title: title,
                                    description: description,
                                    type: selectedType,
                                    targetValue: target,
                                    duration: duration
                                )
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(title.isEmpty || description.isEmpty || targetValue.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Challenge")
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

struct ChallengeDetailView: View {
    let challenge: Challenge
    @ObservedObject var viewModel: ChallengeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1D1F30")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: challenge.type.icon)
                                    .font(.title)
                                    .foregroundColor(Color(hex: challenge.type.color))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(challenge.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(challenge.type.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            
                            Text(challenge.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Progress Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text(viewModel.formatProgress(challenge))
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(challenge.progressPercentage))%")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#FE284A"))
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(height: 10)
                                            .cornerRadius(5)
                                        
                                        Rectangle()
                                            .fill(Color(hex: challenge.type.color))
                                            .frame(width: geometry.size.width * (challenge.progressPercentage / 100), height: 10)
                                            .cornerRadius(5)
                                            .animation(.easeInOut, value: challenge.progressPercentage)
                                    }
                                }
                                .frame(height: 10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Details Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Details")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                DetailRow(title: "Time Remaining", value: viewModel.formatTimeRemaining(challenge))
                                DetailRow(title: "Reward Points", value: "\(challenge.reward.points) pts")
                                
                                if challenge.isGlobal {
                                    DetailRow(title: "Participants", value: "\(challenge.participants)")
                                    DetailRow(title: "Type", value: "Global Challenge")
                                } else {
                                    DetailRow(title: "Type", value: "Personal Challenge")
                                }
                                
                                if let badge = challenge.reward.badge {
                                    DetailRow(title: "Badge Reward", value: badge.name)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        if challenge.progressPercentage >= 100 && !challenge.isCompleted {
                            Button("Complete Challenge") {
                                viewModel.completeChallenge(challenge)
                                presentationMode.wrappedValue.dismiss()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Challenge Details")
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
}

struct DetailRow: View {
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
    ChallengeView()
}

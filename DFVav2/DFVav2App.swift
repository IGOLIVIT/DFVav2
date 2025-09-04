//
//  SportsPulseApp.swift
//  SportsPulse
//
//  Created by IGOR on 04/09/2025.
//

import SwiftUI

@main
struct SportsPulseApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(DataService.shared)
            } else {
                OnboardingView()
            }
        }
    }
}

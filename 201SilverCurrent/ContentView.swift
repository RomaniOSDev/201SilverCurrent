//
//  ContentView.swift
//  201SilverCurrent
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.light)
        .onAppear {
            store.evaluateAchievements()
        }
    }
}

#Preview {
    ContentView()
}

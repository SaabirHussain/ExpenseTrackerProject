//
//  RootView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//

import SwiftUI

struct RootView: View {
    @State private var showOnboarding = false
    @State private var enteredApp = false

    var body: some View {
        ZStack {
            if enteredApp {
                MainAppView()
            } else if showOnboarding {
                OnboardingView(onGetStarted: {
                    enteredApp = true
                })
            } else {
                SplashView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { showOnboarding = true }
            }
        }
    }
}


#Preview {
    RootView()
}

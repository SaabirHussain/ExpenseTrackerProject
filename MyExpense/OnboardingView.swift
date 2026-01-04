//
//  OnboardingView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//

import SwiftUI

struct OnboardingView: View {
    var onGetStarted: () -> Void = {}

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 18) {

                Spacer().frame(height: 30)

                IllustrationView()
                    .padding(.top, 40)


                Spacer().frame(height: 18)

                Text("Spend Smarter\nSave More")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primary)

                Spacer().frame(height: 14)

                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.33, green: 0.58, blue: 0.56))
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .shadow(radius: 10)
                }
                .padding(.horizontal, 28)

                Button(action: {
                    // later: navigate to login
                }) {
                    Text("Already Have Account? **Log In**")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 6)

                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView()
}

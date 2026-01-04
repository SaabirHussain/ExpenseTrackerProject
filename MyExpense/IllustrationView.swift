//
//  IllustrationView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//

import SwiftUI

struct IllustrationView: View {
    @State private var appear = false
    @State private var floatUp = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.teal.opacity(0.12))
                .frame(width: 260, height: 260)
                .scaleEffect(appear ? 1 : 0.92)
                .opacity(appear ? 1 : 0)

            Image("piggy_bank")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .scaleEffect(appear ? 1 : 0.85)
                .opacity(appear ? 1 : 0)
                .offset(y: floatUp ? -6 : 6)
        }
        .onAppear {
            // pop-in
            withAnimation(.easeOut(duration: 0.55)) {
                appear = true
            }
            // floating loop
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    floatUp.toggle()
                }
            }
        }
    }
}

#Preview {
    IllustrationView()
}


//
//  SplashView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(red: 0.33, green: 0.58, blue: 0.56) // teal-ish
                .ignoresSafeArea()

            Text("MyExpense")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SplashView()
}

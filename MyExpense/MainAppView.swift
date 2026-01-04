//
//  MainAppView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//
import SwiftUI

struct MainAppView: View {
    enum Tab {
        case home, stats, add
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(Tab.stats)

            AddExpenseView(onDone: { selectedTab = .home })
                .tabItem { Label("Add", systemImage: "plus") }
                .tag(Tab.add)
        }
    }
}



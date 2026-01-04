//
//  StatsView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//
import SwiftUI

struct StatsView: View {
    @State private var range: RangeOption = .month

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("", selection: $range) {
                        ForEach(RangeOption.allCases, id: \.self) { opt in
                            Text(opt.title).tag(opt)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    ChartPlaceholderView()
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Top Spending")
                            .font(.headline)

                        TopSpendingRow(name: "Starbucks", date: "Jan 12, 2026", amount: "- $150.00")
                        TopSpendingRow(name: "Transfer", date: "Yesterday", amount: "- $85.00")
                        TopSpendingRow(name: "YouTube", date: "Jan 16, 2026", amount: "- $11.99")
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(18)
                    .padding(.horizontal)
                }
                .padding(.top, 10)
            }
            .navigationTitle("Statistics")
        }
    }

    enum RangeOption: CaseIterable {
        case day, week, month, year
        var title: String {
            switch self {
            case .day: return "Day"
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            }
        }
    }
}

private struct ChartPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Expense")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Simple “curve” placeholder using a rounded rectangle
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.teal.opacity(0.15))
                .frame(height: 180)
                .overlay(
                    VStack {
                        Spacer()
                        Text("Chart placeholder (we’ll plug real data + chart later)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                )
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
    }
}

private struct TopSpendingRow: View {
    let name: String
    let date: String
    let amount: String

    var body: some View {
        HStack {
            Circle().fill(Color.gray.opacity(0.2)).frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.headline)
                Text(date).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text(amount).font(.headline).foregroundColor(.red)
        }
        .padding()
        .background(Color.white.opacity(0.001))
    }
}


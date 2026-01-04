//
//  Components.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-03.
//
import SwiftUI
import CoreData

// MARK: - Row model (maps Core Data Expense → UI)
struct TransactionRowModel: Identifiable {
    let id: UUID
    let name: String
    let dateText: String
    let amountText: String
    let isIncome: Bool

    init(expense: Expense) {
        self.id = expense.id ?? UUID()
        self.name = expense.name ?? "Untitled"

        let d = expense.date ?? Date()
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        self.dateText = df.string(from: d)

        let income = (expense.type ?? "Expense") == "Income"
        self.isIncome = income

        let sign = income ? "+ " : "- "
        self.amountText = sign + String(format: "$%.2f", abs(expense.amount))
    }
}

// MARK: - Transaction row UI
struct TransactionRowView: View {
    let model: TransactionRowModel

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: model.isIncome ? "arrow.down" : "arrow.up")
                        .font(.headline)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(model.name).font(.headline)
                Text(model.dateText).font(.caption).foregroundColor(.secondary)
            }

            Spacer()

            Text(model.amountText)
                .font(.headline)
                .foregroundColor(model.isIncome ? .green : .red)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Summary card
struct SummaryCardView: View {
    let balance: Double
    let income: Double
    let expenses: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))

                    Text(money(balance))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Income").font(.caption).foregroundColor(.white.opacity(0.85))
                    Text(money(income)).font(.headline).foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expenses").font(.caption).foregroundColor(.white.opacity(0.85))
                    Text(money(expenses)).font(.headline).foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.teal)
        .cornerRadius(22)
        .padding(.horizontal)
    }

    private func money(_ value: Double) -> String {
        let absValue = abs(value)
        let formatted = String(format: "$%.2f", absValue)
        return value < 0 ? "-\(formatted)" : formatted
    }
}

// MARK: - Empty state
struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No transactions yet")
                .font(.headline)

            Text("Add your first expense to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}


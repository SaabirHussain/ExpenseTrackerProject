//
//  HomeView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default
    )
    private var expenses: FetchedResults<Expense>

    private let recentLimit = 6

    private var recentExpenses: [Expense] {
        Array(expenses.prefix(recentLimit))
    }

    private var totalIncome: Double {
        expenses.filter { ($0.type ?? "Expense") == "Income" }.reduce(0) { $0 + $1.amount }
    }

    private var totalExpenses: Double {
        expenses.filter { ($0.type ?? "Expense") == "Expense" }.reduce(0) { $0 + $1.amount }
    }

    private var totalBalance: Double {
        totalIncome - totalExpenses
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    SummaryCardView(balance: totalBalance, income: totalIncome, expenses: totalExpenses)

                    HStack {
                        Text("Recent Transactions")
                            .font(.headline)
                        Spacer()
                        NavigationLink {
                            SeeAllTransactionsView()
                        } label: {
                            Text("See all")
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)

                    if expenses.isEmpty {
                        EmptyTransactionsView()
                            .padding(.top, 30)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(recentExpenses) { e in
                                TransactionRowView(model: .init(expense: e))
                                    .padding(.horizontal)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteExpense(e)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }

                    Spacer().frame(height: 10)
                }
                .padding(.top, 10)
            }
            .navigationTitle("Homepage")
        }
    }

    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            viewContext.delete(expense)
            do { try viewContext.save() }
            catch { print("❌ Delete failed:", error.localizedDescription) }
        }
    }
}

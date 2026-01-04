//
//  SeeAllTransactionsView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-03.
//

import SwiftUI
import CoreData

struct SeeAllTransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default
    )
    private var expenses: FetchedResults<Expense>

    @State private var searchText = ""
    @State private var typeFilter: TypeFilter = .all
    @State private var categoryFilter: String = ""

    enum TypeFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
        var id: String { rawValue }
    }

    var body: some View {
        List {
            Section {
                Picker("Type", selection: $typeFilter) {
                    ForEach(TypeFilter.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Filter by category (optional)", text: $categoryFilter)
                    .textInputAutocapitalization(.words)
            }

            Section {
                if filtered.isEmpty {
                    Text("No matching transactions")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(filtered) { e in
                        TransactionRowView(model: .init(expense: e))
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) { deleteExpense(e) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("All Transactions")
        .searchable(text: $searchText, prompt: "Search name or category")
    }

    private var filtered: [Expense] {
        expenses.filter { e in
            matchesSearch(e) && matchesType(e) && matchesCategory(e)
        }
    }

    private func matchesSearch(_ e: Expense) -> Bool {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return true }
        let query = q.lowercased()
        return (e.name ?? "").lowercased().contains(query) ||
               (e.category ?? "").lowercased().contains(query)
    }

    private func matchesType(_ e: Expense) -> Bool {
        let type = (e.type ?? "Expense")
        switch typeFilter {
        case .all: return true
        case .income: return type == "Income"
        case .expense: return type == "Expense"
        }
    }

    private func matchesCategory(_ e: Expense) -> Bool {
        let q = categoryFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return true }
        return (e.category ?? "").localizedCaseInsensitiveContains(q)
    }

    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            viewContext.delete(expense)
            do { try viewContext.save() }
            catch { print("❌ Delete failed:", error.localizedDescription) }
        }
    }
}

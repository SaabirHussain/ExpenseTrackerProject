//
//  ContentView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-01.
//

import SwiftUI
import CoreData

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default
    )
    private var expenses: FetchedResults<Expense>

    var body: some View {
        NavigationView {
            List {
                if expenses.isEmpty {
                    Text("No expenses yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(expenses) { e in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(e.name ?? "Untitled")
                                .font(.headline)

                            Text(e.date ?? Date(), style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(formattedAmount(for: e))
                                .font(.headline)
                                .foregroundColor(isIncome(e) ? .green : .red)
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteExpenses)
                }
            }
            .navigationTitle("MyExpense")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addExpense) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addExpense() {
        withAnimation {
            let e = Expense(context: viewContext)
            e.id = UUID()
            e.name = "Test Expense"
            e.amount = 10.50
            e.date = Date()
            e.type = "Expense"
            e.category = "General"

            do {
                try viewContext.save()
            } catch {
                print("Save failed:", error.localizedDescription)
            }
        }
    }

    private func deleteExpenses(offsets: IndexSet) {
        withAnimation {
            offsets.map { expenses[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Delete save failed:", error.localizedDescription)
            }
        }
    }

    private func isIncome(_ e: Expense) -> Bool {
        (e.type ?? "Expense") == "Income"
    }

    private func formattedAmount(for e: Expense) -> String {
        let sign = isIncome(e) ? "+ " : "- "
        return sign + String(format: "$%.2f", e.amount)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}

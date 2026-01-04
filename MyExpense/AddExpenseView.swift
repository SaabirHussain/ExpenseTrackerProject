//
//  AddExpenseView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//
import SwiftUI
import CoreData

struct AddExpenseView: View {
    var onDone: () -> Void = {}
    
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var amountText = ""
    @State private var date = Date()
    @State private var type = "Expense"
    @State private var category = ""

    var body: some View {
        NavigationView {
            Form {
                Section("NAME") {
                    TextField("e.g., Netflix", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("AMOUNT") {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section("DATE") {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                }

                Section("TYPE") {
                    Picker("", selection: $type) {
                        Text("Expense").tag("Expense")
                        Text("Income").tag("Income")
                    }
                    .pickerStyle(.segmented)
                }

                Section("CATEGORY (optional)") {
                    TextField("e.g., Food", text: $category)
                }

                Button("Save") {
                    saveExpense()
                }
                .disabled(!canSave)
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onDone() }
                }
            }
        }
    }

    private var canSave: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && Double(amountText) != nil
    }

    private func saveExpense() {
        guard let amount = Double(amountText) else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)

        let expense = Expense(context: viewContext)
        expense.id = UUID()
        expense.name = trimmedName
        expense.amount = amount
        expense.date = date
        expense.type = type
        expense.category = trimmedCategory.isEmpty ? nil : trimmedCategory

        do {
            try viewContext.save()
            onDone()
        } catch {
            print("❌ Core Data save error:", error.localizedDescription)
        }
    }
}

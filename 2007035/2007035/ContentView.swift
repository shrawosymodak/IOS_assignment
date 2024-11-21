import SwiftUI

struct Expense: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let date: Date
}

struct ContentView: View {
    @State private var expenses: [Expense] = []
    @State private var showAddExpenseView: Bool = false

    // Group expenses by date
    private var groupedExpenses: [String: [Expense]] {
        Dictionary(grouping: expenses) { expense in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: expense.date)
        }
    }

    // Calculate total expense for each date
    private var dailyTotals: [(date: String, total: Double)] {
        groupedExpenses.map { (date, expenses) in
            (date, expenses.reduce(0) { $0 + $1.amount })
        }.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Scrollable container for daily totals and detailed expenses
                ScrollView {
                    VStack {
                        // Daily Totals Section
                        if !dailyTotals.isEmpty {
                            Section(header: Text("Daily Totals").font(.headline)) {
                                ForEach(dailyTotals, id: \.date) { total in
                                    HStack {
                                        Text(total.date)
                                        Spacer()
                                        Text(total.total, format: .currency(code: "USD"))
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            .padding()
                        }

                        // Detailed Expense List
                        if expenses.isEmpty {
                            Spacer()
                            Text("No expenses yet!")
                                .foregroundColor(.gray)
                                .italic()
                            Spacer()
                        } else {
                            ForEach(groupedExpenses.keys.sorted(), id: \.self) { date in
                                Section(header: Text(date).font(.headline)) {
                                    ForEach(groupedExpenses[date]!) { expense in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(expense.title)
                                                    .font(.headline)
                                                Text(expense.amount, format: .currency(code: "USD"))
                                                    .foregroundColor(.green)
                                            }
                                            Spacer()
                                            Text(expense.date, style: .time)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .onDelete { offsets in
                                        deleteExpense(in: date, at: offsets)
                                    }
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                }
                .navigationTitle("Expense Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAddExpenseView.toggle() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $showAddExpenseView) {
                    AddExpenseView(expenses: $expenses)
                }
            }
        }
    }

    // Delete an expense from a specific date group
    private func deleteExpense(in date: String, at offsets: IndexSet) {
        if let expensesForDate = groupedExpenses[date] {
            let idsToDelete = offsets.map { expensesForDate[$0].id }
            expenses.removeAll { idsToDelete.contains($0.id) }
        }
    }
}

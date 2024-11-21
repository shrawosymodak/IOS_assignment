import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var expenses: [Expense]
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text("Please enter a valid amount."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func addExpense() {
        guard let amountValue = Double(amount) else {
            showAlert = true
            return
        }
        
        let newExpense = Expense(title: title, amount: amountValue, date: selectedDate)
        expenses.append(newExpense)
        dismiss()
    }
}

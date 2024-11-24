//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Mac on 24/11/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isShowingItemSheet = false
//    from var expense: [Expense] =[] to query property wrapper to fetch all our expenses
    @Query(sort: \Expense.date) var expenses: [Expense]
    @Environment(\.modelContext) var context
    
//    Key for updating expense
    @State private var expenseToEdit: Expense?
    var body: some View {
        NavigationStack{
            List {
                ForEach(expenses) { expense in
                    ExpenseCell(expense: expense)
                        .onTapGesture {
                            expenseToEdit = expense
                        }
                }
                .onDelete { IndexSet in
                    for index in IndexSet{
                        context.delete(expenses[index])
                    }
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingItemSheet){ AddExpenseSheet() }
            .sheet(item: $expenseToEdit){ expense in
                UpdateExpenseSheet(expense: expense)
            }
            .toolbar{
                if !expenses.isEmpty{
                    Button("Add Expense", systemImage: "plus"){
                        isShowingItemSheet = true
                    }
                }
            }
            .overlay{
                if expenses.isEmpty{
                    ContentUnavailableView(label: {
                        Label("No Expenses", systemImage: "list.bullet.rectangle.portrait")
                    }, description: {
                        Text("Start Adding Expense to see your list")
                    }, actions: {
                        Button("Add Expense"){isShowingItemSheet = true}
                    })
                    .offset(y : -60)
                }
            }
        }
    }
}

struct ExpenseCell: View{
    var expense : Expense
    
    var body: some View{
        HStack {
            Text(expense.date, format: .dateTime.month(.abbreviated).day())
                .frame(width: 70, alignment: .leading)
            Text(expense.name)
            Spacer()
            Text(String(format: "%.2f", expense.value))
//            Text(expense.name,format: .number)
        }
    }
}
#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}


struct AddExpenseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var date: Date = .now
    @State private var value: Double = 0
    
    var body: some View {
        NavigationStack{
            Form{
                TextField("Expense Name", text: $name)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Value", value: $value, format: .number)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading){
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing){
                    Button("Save"){
                let expense = Expense(name: name, date: date, value: value)
                        context.insert(expense)
                        
                        try! context.save()
                        dismiss()
                    }
                }
            }
        }
    }
}


struct UpdateExpenseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
//    We we pass in our expense this generate a binding tp whatever expense we pass into it
    @Bindable var expense: Expense
    var body: some View {
        NavigationStack{
            Form{
                TextField("Expense Name", text: $expense.name)
                DatePicker("Date", selection: $expense.date, displayedComponents: .date)
                TextField("Value", value: $expense.value, format: .number)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Update Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing){
                    Button("Done"){
                    dismiss()
                    }
                }
            }
        }
    }
}

import SwiftUI

struct AddView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var expenses: Expenses
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    
    let types = ["Buisnes", "Personal"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $name)
                Picker("Тип", selection: $type) {
                    ForEach(self.types, id: \.self) {
                        Text($0)
                    }
                }
                
                TextField("Стоимость", text: $amount)
            }
            .navigationBarTitle("Добавить")
            .navigationBarItems(trailing: Button("Зберегти") {
                if let actual = Int(self.amount) {
                    let item = ExpenseItem(name: self.name, type: self.type, amount: actual)
                    self.expenses.items.append(item)
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}

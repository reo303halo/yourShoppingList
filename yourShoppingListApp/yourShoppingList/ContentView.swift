//
//  ContentView.swift
//  yourShoppingList
//
//  Created by Roy Espen Olsen on 25/04/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var newItem = ""
    @State private var items: Array<Item> = []
    
    private let itemsKey = "itemsKey"

    var body: some View {
        HStack {
            Button(action: clearItems) {
                Label("Clear", systemImage: "trash")
                    .padding()
            }
            Spacer()
        }
        
        Text("Your Shopping List")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.blue)
        
        VStack {
            HStack {
                TextField("Add Item", text: $newItem).padding()
                    .background(Color(.link).opacity(0.25).clipShape(RoundedRectangle(cornerRadius:20)))
                    
                Button(action: {
                    addItem()
                }) {
                    amountButton(imageName: "plus.circle", color: .blue, buttonSize: 25)
                }
            }.padding()
            
            
            List {
                ForEach(items) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Button(action: { }) {
                            Button(action: {
                                self.substractOne(item)
                            }) {
                                amountButton(imageName: "minus.circle", color: .red, buttonSize: 20)
                            }
                        }
                        Text(String(item.amount))
                        Button(action: { }) {
                            Button(action: {
                                self.addOne(item)
                            }) {
                                amountButton(imageName: "plus.circle", color: .blue, buttonSize: 20)
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            self.deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let savedItems = try? JSONDecoder().decode([Item].self, from: data) {
            self.items = savedItems
        }
    }
    
    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: itemsKey)
        }
    }
    
    private var bindingItems: Binding<Array<Item>> {
        Binding<Array<Item>>(
            get: { items },
            set: {
                items = $0
                saveItems()
            })
    }
    
    func addItem() {
        let existingIndex = items.firstIndex(where: { $0.name.lowercased() == newItem.lowercased() })
        if let index = existingIndex {
            items[index].amount += 1
        } else {
            let item = Item(name: newItem.capitalized, amount: 1)
            items.append(item)
        }
        newItem = ""
    }
    
    func deleteItem(_ index: Item) {
        if let index = items.firstIndex(where: { $0.id == index.id }) {
            items.remove(at: index)
        }
    }
    
    func addOne(_ index: Item) {
            if let index = items.firstIndex(where: { $0.id == index.id }) {
                items[index].amount += 1
        }
    }
    
    func substractOne(_ index: Item) {
        if let index = items.firstIndex(where: { $0.id == index.id }) {
            items[index].amount -= 1
            if items[index].amount == 0 {
                deleteItem(items[index])
            }
        }
    }
    
    func clearItems() {
        items.removeAll()
    }
}


struct Item: Identifiable, Codable {
    let id: UUID
    let name: String
    var amount: Int
    
    init(id: UUID = UUID(), name: String, amount: Int) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}


struct amountButton: View {
    let imageName: String
    let color: Color
    let buttonSize: CGFloat
    
    var body: some View {
        Image(systemName: imageName)
            .foregroundColor(color)
            .font(.system(size: buttonSize))
            .padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

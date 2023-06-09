//
//  ContentView.swift
//  yourShoppingList
//
//  Created by Roy Espen Olsen on 24/04/2023.
//  Start code created in Swift Playgrounds some days before.
//
//  Missing app icons and load screen.
//
//  Using UserDefault as storage -> Ok for this type of small list.
//  CoreData or other database if further developement.
//  Other idea could be to use iCloud or database to share shopping list.
//

import SwiftUI

struct ShoppingListView: View {
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
                    }.swipeActions {
                        Button(role: .destructive) {
                            self.deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }.onAppear {
                do {
                    self.items = try getList()
                } catch {
                    print(error)
                }
            }
            
            HStack {
                TextField("Add Item", text: $newItem)
                    .padding()
                    .background(Color(.link).opacity(0.25).clipShape(RoundedRectangle(cornerRadius:20)))
                    .submitLabel(.done)
                    .onSubmit(addItem)
                    .disableAutocorrection(true)
                    
                Button(action: {
                    addItem()
                }) {
                    amountButton(imageName: "plus.circle", color: .blue, buttonSize: 25)
                }
            }.padding()
        }
    }
    
    func saveList(value: Array<Item>) {
        do {
            let shoppingItemData = try JSONEncoder().encode(value)
            UserDefaults.standard.set(shoppingItemData, forKey: "shoppingItems")
        } catch {
            print("Error encoding shopping items: \(error)")
        }
    }

    func getList() throws -> Array<Item> {
            guard let shoppingItemData = UserDefaults.standard.data(forKey: "shoppingItems") else { return [] }
            let items = try JSONDecoder().decode(Array<Item>.self, from: shoppingItemData)
            return items
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
        saveList(value: items)
    }
    
    func deleteItem(_ index: Item) {
        if let index = items.firstIndex(where: { $0.id == index.id }) {
            items.remove(at: index)
            saveList(value: items)
        }
    }
    
    func addOne(_ index: Item) {
            if let index = items.firstIndex(where: { $0.id == index.id }) {
                items[index].amount += 1
                saveList(value: items)
        }
    }
    
    func substractOne(_ index: Item) {
        if let index = items.firstIndex(where: { $0.id == index.id }) {
            items[index].amount -= 1
            if items[index].amount == 0 {
                deleteItem(items[index])
                saveList(value: items)
            }
        }
    }
    
    func clearItems() {
        items.removeAll()
        saveList(value: items)
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
        ShoppingListView()
    }
}

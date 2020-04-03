//
//  ContentView.swift
//  NCXProject
//
//  Created by Dario Mandarino on 27/03/2020.
//  Copyright © 2020 Dario Mandarino. All rights reserved.
//

import SwiftUI
// in scene delegate there are changes
struct ContentView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: ListItem.getListItemFetchRequest()) var listItems: FetchedResults<ListItem>
    @State var isCloudUsable : Bool = !isICloudContainerAvailable()
    @State private var newToDoItem = ""
    
    var body: some View {
        
        NavigationView{
            List{
                Section(header: Text("Type your Work")){
                    HStack{
//                        create the new item
                        TextField("New item", text: self.$newToDoItem){
                            
                            let newItem = ListItem(context: self.managedObjectContext)
                            newItem.title = self.newToDoItem
                            newItem.id = UUID()
                            newItem.createdAt = "\(Date())"
                            newItem.order = (self.listItems.last?.order ?? 0) + 1
                            newItem.isDone = false
                            
                            self.newToDoItem = ""
                            self.saveItems()
                        }
                    }
                }
                Section(header: Text("To Do's")){
//                    show all the item
                    
                       
                    ForEach(listItems,id: \.self) { item in
                        ToDoItemView(listItem: item)
                        
//                        delete the item by scrolling
                    }.onDelete(perform: deleteItem)
                    .onMove(perform: moveItem)
                }
            }.navigationBarTitle("My to do list")
            .navigationBarItems(trailing: EditButton())
        }.alert(isPresented: $isCloudUsable, content: {
            Alert(title: Text("iCloud account not found"),
            message: Text("Please log in to your iCloud account before using this app"),
            dismissButton: .default(Text("OK")) { print("do something") })
        })
    }
    
    func saveItems(){
        do {
            try managedObjectContext.save()
        } catch{
            print(error)
        }
    }
    
    func moveItem(indexSet : IndexSet,destination: Int)  {
        let source = indexSet.first!
        if(source < destination-1){
            var startPoint = source + 1
            while(startPoint < destination){
                listItems[startPoint].order = startPoint
                startPoint = startPoint + 1
            }
        }
        else{
            var startPoint = source - 1
            while(startPoint >= destination){
                listItems[startPoint].order = listItems[startPoint].order + 1
                startPoint = startPoint - 1
            }
        }
        listItems[source].order = destination
        saveItems()
    }
    
    func deleteItem(indexSet: IndexSet){
        let source = indexSet.first!
        let listItem = listItems[source]
        managedObjectContext.delete(listItem)
        saveItems()
    }
}

func isICloudContainerAvailable()->Bool {
    if FileManager.default.ubiquityIdentityToken != nil {
        return true
    }
    else {
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

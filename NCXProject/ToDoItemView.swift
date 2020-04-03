//
//  ToDoItemView.swift
//  NCXProject
//
//  Created by Dario Mandarino on 27/03/2020.
//  Copyright © 2020 Dario Mandarino. All rights reserved.
//

import SwiftUI
import CoreData

//how the list of items to do  will appear
struct ToDoItemView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var listItem : ListItem
    
    var body: some View {
//        hastack -> horizzontal
//        on the left side title and date of creation
        HStack{
//            the vstack is to have 2 lines
            VStack(alignment: .leading){
                Text(listItem.title)
                    .font(.headline)
                Text(listItem.createdAt)
                    .font(.caption)
            }
//            spacer to have the button far from the title
            Spacer()
//           on right side the rectangle with the check
            Button(action:{
//                toggle changes from true to false and viceversa when the user press the button
                self.listItem.isDone.toggle()
                do {
                    try self.managedObjectContext.save()
                } catch{
                    print(error)
                }
            }){
//                zstack to have the check on the rectangle
                ZStack{
                    Rectangle().frame(width: 30, height: 30).cornerRadius(7)
                        .foregroundColor(Color(#colorLiteral(red: 0.1176470588, green: 0.3333333333, blue: 0.4980392157, alpha: 1)))
                    if listItem.isDone{
//                        add the check when isDone is true
                        Image(systemName: "checkmark").foregroundColor((Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))).frame(width: 30, height: 30).cornerRadius(7)
                    }
                }
            }
        }
    }
}
 

class ListItem: NSManagedObject {
    
    @NSManaged var id : UUID
    @NSManaged var createdAt: String
    @NSManaged var isDone: Bool
    @NSManaged var title : String
    @NSManaged var order : Int
}

extension ListItem{
    static func getListItemFetchRequest() -> NSFetchRequest<ListItem>{
        let request = ListItem.fetchRequest() as! NSFetchRequest<ListItem>
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        return request
    }
}

struct ToDoItemView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoItemView(listItem: ListItem())
    }
}

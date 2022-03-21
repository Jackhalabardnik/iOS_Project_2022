import SwiftUI

extension String {
  var isBlank: Bool {
    return allSatisfy({ $0.isWhitespace })
  }
}

struct EventListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)],
        animation: .default)
    private var events: FetchedResults<Event>
    
    @State var show_popup = false
    @State var search_string = ""
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    if self.events.isEmpty {
                        Text("Add some new events!")
                    }
                    else {
                        
                        HStack {
                            Text("Search: ")
                            .frame(height: 36)
                            .padding([.leading, .trailing], 5)
                            
                            TextField("", text: $search_string)
                            .frame(height: 36)
                            .padding([.leading, .trailing], 10)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        if self.search_string.isBlank == false && (self.events.filter{$0.name!.lowercased().contains(self.search_string.lowercased())}).isEmpty {
                            Text("There is no events containing given string")
                        }
                        else {
                            List {
                                ForEach(self.events.filter
                                    { self.search_string.isBlank || $0.name!.lowercased().contains(self.search_string.lowercased()) }, id : \.name)
                                { event in
                                    NavigationLink(
                                        destination: EventView(event: event),
                                           label: {
                                            Text(event.name!)
                                       })
                                }.onDelete(perform: delete_event)
                            }
                        }
                        
                    }
                    
                    Spacer()
                    Button(action: {
                        self.show_popup = true
                    }, label: {
                        Text("Add new event")
                    })
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10.0)
                }
            }
            .popup(is_presented: $show_popup) {
                EventNameAddPopupView(is_presented: self.$show_popup)
            }
        }
    }
    
    private func delete_event(offsets: IndexSet) {
        withAnimation {
            offsets.map { events[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved \(nsError.userInfo)")
            }
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventListView()
            EventListView(show_popup: true)
        }
        
    }
}

import SwiftUI

struct EventListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)],
        animation: .default)
    private var events: FetchedResults<Event>
    
    @State var show_popup = false
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    if self.events.isEmpty {
                        Text("Add some new events!")
                    }
                    else {
                        
                        List {
                            ForEach(self.events, id : \.name) { event in
                                NavigationLink(
                                    destination: EventView(),
                                    label: {
                                        Text(event.name!).tag(event.name!)
                                })
                             }.onDelete(perform: delete_event)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 300)
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
                BottomPopupView {
                    EnterNamePopupView(is_presented: self.$show_popup)
                }
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

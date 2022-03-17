import SwiftUI

struct EventListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)],
        animation: .default)
    private var events: FetchedResults<Event>
    
    var body: some View {
        NavigationView {
            VStack {
                if self.events.isEmpty {
                    Text("Hello, event list view!")
                }
                else {
                    NavigationLink(
                        destination: EventView(),
                        label: {
                            Text("Wydarzenie")
                                .frame(width:200, height: 40)
                                .background(Color.green)
                    })
                }
                
            }
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}

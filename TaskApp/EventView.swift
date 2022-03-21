import SwiftUI

struct EventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)],
        animation: .default)
    private var events: FetchedResults<Event>
    
    @State var event: Event
    
    var body: some View {
            VStack {
                HStack {
                    Toggle("Is active:", isOn: $event.is_active)
                        .onReceive([self.event.is_active].publisher.first()) {value in
                            self.activate_event()
                    }
                    Toggle("Is highlighted:", isOn: $event.is_highlighted)
                        .onReceive([self.event.is_highlighted].publisher.first()) {value in
                            self.highlight_event()
                    }
                }
                Spacer()
                Text("Hello, event view for event \(event.name!)!")
                NavigationLink(
                    destination: TaskView(),
                    label: {
                        Text("Zadanie")
                            .frame(width:200, height: 40)
                            .background(Color.green)
                }
                )
                Spacer()
            }
    }
    
    private func activate_event() {
        do {
            try viewContext.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved \(nsError.userInfo)")
        }
    }
    
    private func highlight_event() {
        
        if event.is_highlighted {
            events.forEach({ if $0.name! != self.event.name! {
                $0.is_highlighted = false
                }})
        }
        
        do {
            try viewContext.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved \(nsError.userInfo)")
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: Event())
    }
}

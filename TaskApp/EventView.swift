import SwiftUI

struct EventView: View {
    @Environment(\.managedObjectContext) private var core_context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)],
        animation: .default)
    private var events: FetchedResults<Event>
    
    @FetchRequest var tasks: FetchedResults<Task>
    
    @ObservedObject var event: Event
    @State var search_string = ""
    @State var show_edit_popup = false
    @State var show_new_task_popup = false
    
    init(event: Event) {
        self.event = event
        
        _tasks = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Task.name, ascending: true)
            ],
            predicate: NSPredicate(format: "event == %@", event),
            animation: .default
        )
    }
    
    var body: some View {
            VStack {
                HStack(spacing: 16) {
                    Text(self.event.name!)
                    .font(.system(size: 25, weight: .bold, design: .default))
                    .padding([.leading, .trailing], 10)
                    Spacer()
                    VStack{
                    Button(action: {
                        self.show_edit_popup = true
                    }, label: {
                        Text("Edit")
                        .font(.system(size: 25, weight: .bold, design: .default))
                    })
                    .frame(maxWidth: 120, maxHeight: 40)
                    
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    }.padding([.leading, .trailing], 10)
                }
                
                HStack(spacing: 16) {
                    Toggle("Is active:", isOn: $event.is_active)
                        .onReceive([self.event.is_active].publisher.first()) {value in
                            self.activate_event()
                    }
                    Toggle("Is highlighted:", isOn: $event.is_highlighted)
                        .onReceive([self.event.is_highlighted].publisher.first()) {value in
                            self.highlight_event()
                    }
                }.padding([.leading, .trailing], 10)
                
                Spacer()
                
                if self.tasks.isEmpty {
                    Text("Add some new events!")
                }
                else {
                    
                    HStack {
                        Text("Search: ")
                        .frame(height: 36)
                        
                        TextField("", text: $search_string)
                        .frame(height: 36)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    }.padding([.leading, .trailing], 10)
                    
                    Spacer()
                    
                    if self.search_string.isBlank == false && (self.tasks.filter{ $0.name!.lowercased().contains(self.search_string.lowercased()) }).isEmpty {
                        Text("There is no tasks containing given string")
                    }
                    else {
                        List {
                            ForEach(self.tasks.filter
                                { self.search_string.isBlank || $0.name!.lowercased().contains(self.search_string.lowercased()) }, id: \.name)
                            { task in
                                NavigationLink(
                                 destination: TaskView(task: task),
                                    label: {
                                     Text(task.name!)
                                })
                            }.onDelete(perform: delete_task)
                        }
                    }
                    
                }
                        
                Spacer()
                Button(action: {
                    self.show_new_task_popup = true
                }, label: {
                    Text("Add new task")
                })
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10.0)
            }
            .popup(is_presented: $show_edit_popup) {
                TextInputPopup<Event>(prompt_text: "Enter new event name", error_text: "Event name has to be unique and not empty", ok_callback: self.edit_event_name, is_presented: self.$show_edit_popup)
            }
            .popup(is_presented: $show_new_task_popup) {
                TextInputPopup<Event>(prompt_text: "Enter task name", error_text: "Task name has to be unique and not empty", ok_callback: self.add_task, is_presented: self.$show_new_task_popup)
            }
    }
    
    private func activate_event() {
        do {
            try core_context.save()
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
            try core_context.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved \(nsError.userInfo)")
        }
    }
    
    private func edit_event_name(input_text: inout String, is_presented: inout Bool, show_alert: inout Bool){
        if events.contains(where: {$0.name! == input_text }) || input_text.isBlank {
            input_text = ""
            show_alert = true
        } else {
            event.name! = input_text
            
            do {
                try core_context.save()
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError),(nsError.userInfo)")
            }
            is_presented = false
        }
    }
    
    private func add_task(input_text: inout String, is_presented: inout Bool, show_alert: inout Bool){
        if tasks.contains(where: {$0.name! == input_text }) || input_text.isBlank {
            input_text = ""
            show_alert = true
        } else {
            let new_task = Task(context: core_context)
            new_task.name = input_text
            new_task.icon_name = ""
            new_task.is_done = false
            new_task.latitude = 0
            new_task.longitude = 0
            new_task.event = event
            
            do {
                try core_context.save()
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError),(nsError.userInfo)")
            }
            is_presented = false
        }
    }
    
    private func delete_task(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(core_context.delete)
            do {
                try core_context.save()
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved \(nsError.userInfo)")
            }
        }
    }
    
    
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: Event())
    }
}

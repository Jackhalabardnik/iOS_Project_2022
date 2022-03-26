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
    @State var force_deactivate = false
    
    @State var show_edit_popup = false
    @State var show_new_task_popup = false
    @State var show_highlight_alert = false
    @State var show_deactivate_alert = false
    
    
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
                    .padding([.leading, .trailing], 10)
                    .font(.system(size: 25, weight: .bold, design: .default))
                    Spacer()
                    VStack{
                    Button(action: {
                        self.show_edit_popup = true
                    }, label: {
                        Text("Edit")
                        .frame(maxWidth: 120, maxHeight: 40)
                        .font(.system(size: 20, weight: .bold, design: .default))
                    })
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    }.padding([.leading, .trailing], 10)
                }
                
                
                HStack(spacing: 16) {
                    Button(action: activate_event, label: {
                        HStack {
                            Text(event.is_active ? "Stop event" : "Start event")
                            Image(systemName: event.is_active ?  "stop.circle.fill" : "play.circle.fill")
                        }
                        
                    })
                
                    Spacer()
                    
                    Button(action: highlight_event, label: {
                        HStack {
                            Text(event.is_highlighted ? "Remove highlight" : "Highlight")
                            Image(systemName: event.is_highlighted ?  "star.fill" : "star")
                        }
                    })
                }
                    .padding([.leading, .trailing], 10)
                    .font(.system(size: 20, weight: .regular, design: .default))
                
                Spacer()
                
                if self.tasks.isEmpty {
                    Text("Add some new tasks!")
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
                                HStack {
                                    NavigationLink(
                                    destination: TaskView(display_task: task)) {
                                        Button(action: {
                                            self.checkbox_task(given_task: task)
                                        }, label: {
                                            Image(systemName: task.is_done ? "checkmark.square.fill" : "checkmark.square")
                                                .imageScale(.large)
                                        })
                                        
                                        Spacer()
                                        
                                        Text(task.name!)
                                    }
                                }
                                
                            }.onDelete(perform: delete_task)
                        }
                            .buttonStyle(PlainButtonStyle())
                            .listStyle(GroupedListStyle())
                    }
                    
                }
                        
                Spacer()
                Button(action: {
                    self.show_new_task_popup = true
                }, label: {
                    Text("Add new task")
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .font(.system(size: 20, weight: .bold, design: .default))
                })
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10.0)
            }
            .popup(is_presented: $show_edit_popup) {
                TextInputPopup<Event>(prompt_text: "Enter new event name", error_text: "Event name has to be unique and not empty", ok_callback: self.edit_event_name, is_presented: self.$show_edit_popup, input_text: self.event.name!)
            }
            .popup(is_presented: $show_new_task_popup) {
                TextInputPopup<Event>(prompt_text: "Enter task name", error_text: "Task name has to be unique and not empty", ok_callback: self.add_task, is_presented: self.$show_new_task_popup, input_text: "")
            }
            .alert(isPresented: $show_highlight_alert) {
                Alert( title: Text("Error"),
                       message: Text("Only active tasks can be highlighted"),
                       dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $show_deactivate_alert) {
                Alert(title: Text("Warning"), message: Text("Not all tasks are completed"), primaryButton: .default(Text("OK, deactivate anyway"), action: {
                    self.force_deactivate = true
                    self.activate_event()
                }), secondaryButton: .cancel())
        }
            
    }
    
    private func activate_event() {
        
        if !force_deactivate && event.is_active && !tasks.allSatisfy({$0.is_done}) {
            show_deactivate_alert = true
        }
        else {
            force_deactivate = false
            
            if event.is_active {
                event.is_highlighted = false
            } else {
                tasks.forEach {
                    $0.is_done = false
                }
            }
            
            event.is_active.toggle()
            
            do {
                try core_context.save()
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved \(nsError.userInfo)")
            }
        }
    }
    
    private func highlight_event() {
        
        if event.is_highlighted || event.is_active {
            event.is_highlighted.toggle()
            
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
        } else {
            show_highlight_alert = true
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
            new_task.task_description = ""
            new_task.is_map_set = false
            new_task.is_done = false
            new_task.latitude = 51.246452
            new_task.longitude = 22.568445
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
    
    private func checkbox_task(given_task: Task) {
        if  event.is_active {
            given_task.is_done.toggle()
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

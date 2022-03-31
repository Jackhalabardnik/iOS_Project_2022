import SwiftUI
import MapKit

struct TaskView: View {
    @Environment(\.managedObjectContext) private var core_context
    
    @FetchRequest private var tasks: FetchedResults<Task>
    
    @State private var search_string = ""
    @State private var map_scope = 0.005
    @State private var drag_amount = CGSize.zero
    
    @State private var show_edit_event_popup = false
    @State private var show_new_task_popup = false
    @State private var show_description_edit_popup = false
    @State private var show_edit_pin_popup = false
    
    @State private var choosen_task: Task
    
    init(display_task: Task) {
        self._choosen_task = State(initialValue: display_task)
        
        _tasks = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Task.name, ascending: true)
            ],
            predicate: NSPredicate(format: "event == %@", display_task.event!),
            animation: .default
        )
        
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Text(self.choosen_task.name!)
                    .font(.system(size: 25, weight: .bold, design: .default))
                Button(action: {
                    self.show_edit_event_popup = true
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.blue)
                })
                Spacer()
                
                Button(action: self.checkbox_task, label: {
                    HStack {
                        Text(choosen_task.is_done ? "Done" : "Not done")
                        Image(systemName: choosen_task.is_done ? "checkmark.square.fill" : "checkmark.square")
                            .imageScale(.large)
                            .foregroundColor(choosen_task.is_done ? .green : .black)
                    }
                    .offset(drag_amount)
                    .gesture(
                        DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                            .onChanged {
                                if $0.translation.width < 0 && $0.translation.width > -100 {
                                    self.drag_amount.width = $0.translation.width
                                }}
                            .onEnded { value in
                                if value.translation.width < 0 && value.translation.height > -30 && value.translation.height < 30 {
                                    withAnimation(.spring()) {
                                        self.drag_amount = .zero
                                    }
                                    self.checkbox_task()
                                }})
                })
                    .disabled(!self.choosen_task.event!.is_active)
                
                
            }
            .padding([.leading, .trailing], 10)
            
            VStack {
                if choosen_task.task_description!.isBlank {
                    Button(action: {
                        self.show_description_edit_popup = true
                    }){
                        Text("Add some description")
                            .font(.system(size: 15, weight: .bold, design: .default))
                            .frame(maxWidth: .infinity, maxHeight: 40)
                    }
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    VStack {
                        HStack {
                            Text("Description")
                                .fontWeight(.bold)
                            Button(action: {
                                self.show_description_edit_popup = true
                            }){
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                        HStack {
                            Text(choosen_task.task_description!)
                                .multilineTextAlignment(.center)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    }
                    
                }
            }.padding(10)
            
            Spacer()
            
            if choosen_task.is_map_set {
                
                HStack {
                    Text("Map")
                        .fontWeight(.bold)
                    Button(action: {
                        self.show_edit_pin_popup = true
                    }){
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    
                    Button(action: self.remove_map, label: {
                        Image(systemName: "trash.fill")
                            .imageScale(.medium)
                            .foregroundColor(.black)
                    })
                        .padding([.leading, .trailing], 10)
                }.padding([.leading, .trailing], 10)
                
                MapViewUI(latitude: $choosen_task.latitude, longitude: $choosen_task.longitude, scope: $map_scope)
                    .frame(maxHeight: 400)
                    .onTapGesture {
                        self.change_scope()
                }
                
            }
            else {
                Button(action: {
                    self.show_edit_pin_popup = true
                }){
                    Text("Add new task location")
                        .font(.system(size: 15, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 40)
                }
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding([.leading, .trailing], 10)
            }
            
            Spacer()
            
        }
        .popup(is_presented: $show_edit_event_popup) {
            TextInputPopup(prompt_text: "Enter new task name", error_text: "Task name has to be unique and not empty", ok_callback: self.edit_task_name, is_presented: self.$show_edit_event_popup, input_text: self.choosen_task.name!)
        }
        .popup(is_presented: $show_description_edit_popup) {
            TextInputPopup(prompt_text: "Enter description", error_text: "", ok_callback: self.edit_task_description, is_presented: self.$show_description_edit_popup, input_text: self.choosen_task.task_description!)
        }
        .popup(is_presented: $show_edit_pin_popup) {
            PinChoosePopup(is_presented: self.$show_edit_pin_popup, task: self.$choosen_task)
        }
        
    }
    
    
    private func edit_task_name(input_text: inout String, is_presented: inout Bool, show_alert: inout Bool){
        if tasks.contains(where: {$0.name! == input_text && $0.name! != choosen_task.name!}) || input_text.isBlank {
            input_text = ""
            show_alert = true
        } else {
            choosen_task.name! = input_text
            
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
    
    private func edit_task_description(input_text: inout String, is_presented: inout Bool, show_alert: inout Bool){
        choosen_task.task_description = input_text
        
        do {
            try core_context.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError),(nsError.userInfo)")
        }
        is_presented = false
    }
    
    private func checkbox_task() {
        choosen_task.is_done.toggle()
        
        do {
            try core_context.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError),(nsError.userInfo)")
        }
    }
    
    private func remove_map() {
        choosen_task.is_map_set = false
        
        do {
            try core_context.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError),(nsError.userInfo)")
        }
    }
    
    private func change_scope() {
        if map_scope < 0.02 {
            map_scope += 0.01
        } else if map_scope < 0.1 {
            map_scope += 0.05
        } else if map_scope < 0.4 {
            map_scope += 0.1
        } else {
            map_scope = 0.005
        }
    }
}

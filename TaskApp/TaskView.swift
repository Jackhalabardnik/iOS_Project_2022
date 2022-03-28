import SwiftUI
import MapKit

struct TaskView: View {
    @Environment(\.managedObjectContext) private var core_context
    
    @FetchRequest var tasks: FetchedResults<Task>
    
    @State var search_string = ""
    @State var show_edit_event_popup = false
    @State var show_new_task_popup = false
    @State var show_description_edit_popup = false
    @State var show_edit_pin_popup = false
    
    @State var choosen_task: Task
    
    init(display_task: Task) {
        self._choosen_task = State(initialValue: display_task)
        
        _tasks = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Task.name, ascending: true)
            ],
            predicate: NSPredicate(format: "name == %@", display_task.name!),
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
                })
                Spacer()
                Text(choosen_task.is_done ? "Done" : "Not done")
                Button(action: self.checkbox_task, label: {
                    Image(systemName: choosen_task.is_done ? "checkmark.square.fill" : "checkmark.square")
                        .imageScale(.large)
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
                    }
                    Spacer()
                }.padding([.leading, .trailing], 10)

                MapViewUI(latitude: $choosen_task.latitude, longitude: $choosen_task.longitude)
                    .frame(maxHeight: 400)

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
            TextInputPopup<Event>(prompt_text: "Enter new task name", error_text: "Task name has to be unique and not empty", ok_callback: self.edit_task_name, is_presented: self.$show_edit_event_popup, input_text: self.choosen_task.name!)
        }
        .popup(is_presented: $show_description_edit_popup) {
            TextInputPopup<Event>(prompt_text: "Enter description", error_text: "", ok_callback: self.edit_task_description, is_presented: self.$show_description_edit_popup, input_text: self.choosen_task.task_description!)
        }
        .popup(is_presented: $show_edit_pin_popup) {
            PinChoosePopup(is_presented: self.$show_edit_pin_popup, task: self.$choosen_task)
        }
        
    }
    
    
    private func edit_task_name(input_text: inout String, is_presented: inout Bool, show_alert: inout Bool){
        if tasks.contains(where: {$0.name! == input_text }) || input_text.isBlank {
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
}

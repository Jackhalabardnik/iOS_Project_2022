import SwiftUI

struct TaskView: View {
    @Environment(\.managedObjectContext) private var core_context
    
    @FetchRequest var tasks: FetchedResults<Task>
    
    @ObservedObject var task: Task
    @State var search_string = ""
    @State var show_edit_popup = false
    @State var show_new_task_popup = false
    
    init(task: Task) {
        self.task = task
        
        _tasks = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Task.name, ascending: true)
            ],
            predicate: NSPredicate(format: "event == %@", task.event!),
            animation: .default
        )
    }
    
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Text(self.task.name!)
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
            Spacer()
        }
        .popup(is_presented: $show_edit_popup) {
            TextInputPopup<Event>(prompt_text: "Enter new task name", error_text: "Task name has to be unique and not empty", ok_callback: self.edit_task_name, is_presented: self.$show_edit_popup)
        }
    }
    
        
    private func edit_task_name(input_text: inout String, is_presented: inout Bool, show_alert: inout Bool){
        if tasks.contains(where: {$0.name! == input_text }) || input_text.isBlank {
            input_text = ""
            show_alert = true
        } else {
            task.name! = input_text
            
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
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: Task())
    }
}

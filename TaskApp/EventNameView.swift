import SwiftUI

struct EnterNamePopupView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)],
        animation: .default)
    private var events: FetchedResults<Event>
    
    @Binding var is_presented: Bool
    @State var text = ""
    @State var show_name_alert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Enter event name")
                    .font(.system(size: 25, weight: .bold, design: .default))
                Button(action: {
                    self.is_presented = false
                }, label: {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .background(Color.black.opacity(0.06))
                        .cornerRadius(16)
                        .foregroundColor(.black)
                })
            }
            TextField("", text: $text)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
            HStack {
                Spacer()
                Button(action: self.addEvent,
                       label: {
                    Text("Done")
                })
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: self.$show_name_alert) {
            Alert(
                title: Text("Error"),
                message: Text("Event name has to be unique"),
                dismissButton: .default(Text("Got it!"))
            )
        }
    }
    
    
    private func addEvent(){
        if events.contains(where: {$0.name! == text }) {
            text = ""
            show_name_alert = true
        } else {
            let newEvent = Event(context: viewContext)
            newEvent.name = text
            newEvent.is_active = false
            newEvent.is_highlighted = false
            do {
                try viewContext.save()
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError),(nsError.userInfo)")
            }
            is_presented = false
        }
    }
}

struct EnterNamePopupView_Previews: PreviewProvider {
    static var previews: some View {
        EnterNamePopupView(is_presented: .constant(true))
            .previewLayout(.sizeThatFits)
    }
}

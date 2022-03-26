import SwiftUI
import CoreData

struct PinChoosePopup: View {
    @Environment(\.managedObjectContext) private var core_context
    
    @FetchRequest var tasks: FetchedResults<Task>
    
    @ObservedObject var choosen_task: Task
    
    @Binding var is_presented: Bool
    
    @State var show_bad_number_popup = false
    
    @State var latitude_text: String
    @State var longitude_text: String
    
    init(is_presented: Binding<Bool>, task: Task) {
        
        _tasks = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Task.name, ascending: true)
            ],
            predicate: NSPredicate(format: "name == %@", task.name!),
            animation: .default
        )
        
        self._is_presented = is_presented
        
        self.choosen_task = task
        
        self._latitude_text = State(initialValue: String(task.latitude))
        self._longitude_text = State(initialValue: String(task.longitude))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Enter pin")
                .font(.system(size: 25, weight: .bold, design: .default))

                Spacer()

                Button(action: {
                    self.is_presented = false
                }, label: {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .background(Color.black.opacity(0.06))
                        .cornerRadius(16)
                        .foregroundColor(.black)
                })
            }
                .padding([.leading, .trailing], 10)

            Button(action: getLocation,
                label: {
                Text("Get your location")
                .font(.system(size: 15, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, maxHeight: 30)
            })
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            TextField("Latitude", text: self.$latitude_text)
            TextField("Longitude", text: self.$longitude_text)

            Button(action: setPin,
                label: {
                Text("Set pin")
                .font(.system(size: 15, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, maxHeight: 30)
            })
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            MapViewUI(latitude: $choosen_task.latitude, longitude: $choosen_task.longitude)
                .frame(maxHeight: 300)

            HStack {
                Button(action: finish,
                    label: {
                    Text("Done")
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, maxHeight: 30)
                })
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: self.$show_bad_number_popup) {
            Alert(
                title: Text("Error"),
                message: Text("Latitude and longitude are numbers in range:\nlatitude: -90 to 90\nlongitude: -180 to 180"),
                dismissButton: .default(Text("Got it!"))
            )
        }
        .animation(.easeOut)
        .transition(.move(edge: .bottom))
        .background(Color.white)
    }
    
    private func finish() {
        is_presented = false
    }
    
    private func getLocation() {
        
    }
    
    private func setPin() {
        guard let latitude_double = Double(latitude_text) else {
            show_bad_number_popup = true
            return
        }
        guard let longitude_double = Double(longitude_text) else {
            show_bad_number_popup = true
            return
        }
        
        if latitude_double < -90 || latitude_double > 90 || longitude_double < -180 || longitude_double > 180 {
            show_bad_number_popup = true
            return
        }
        
        choosen_task.latitude = latitude_double
        choosen_task.longitude = longitude_double
        choosen_task.is_map_set = true
        
    }
    
}

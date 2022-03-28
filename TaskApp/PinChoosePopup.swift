import SwiftUI
import CoreData

struct PinChoosePopup: View{
    
    @Environment(\.managedObjectContext) private var core_context
    
    @Binding var choosen_task: Task
    
    @Binding var is_presented: Bool
    
    @State private var show_bad_number_popup = false
    
    @State private var latitude_number: Double
    @State private var longitude_number: Double
    
    @State private var latitude_text: String
    @State private var longitude_text: String
    
    @State private var current_map_set: Bool
    
    var location_fetcher = LocationFetcher()
    
    init(is_presented: Binding<Bool>, task: Binding<Task>) {
        self._is_presented = is_presented
        
        self._choosen_task = task
        
        self._latitude_number = State(initialValue: task.wrappedValue.latitude)
        self._longitude_number = State(initialValue: task.wrappedValue.longitude)
        
        self._latitude_text = State(initialValue: String(task.wrappedValue.latitude))
        self._longitude_text = State(initialValue: String(task.wrappedValue.longitude))
        
        self._current_map_set = State(initialValue: task.wrappedValue.is_map_set)
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

            MapViewUI(latitude: $latitude_number, longitude: $longitude_number)
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
        
        if current_map_set {
            choosen_task.latitude = latitude_number
            choosen_task.longitude = longitude_number
        }
        
        choosen_task.is_map_set = current_map_set
        
        do {
            try core_context.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved \(nsError.userInfo)")
        }
        
        is_presented = false
    }
    
    private func getLocation() {
        location_fetcher.start()
        
        if let location = location_fetcher.lastKnownLocation {
            latitude_text = String(location.latitude)
            longitude_text = String(location.longitude)
            setPin()
        }
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
        
        latitude_number = latitude_double
        longitude_number = longitude_double
        current_map_set = true
    }
    
    
}

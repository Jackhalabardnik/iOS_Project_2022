import SwiftUI

struct EventView: View {
    var body: some View {
            VStack {
                Text("Hello, event view!")
                NavigationLink(
                    destination: TaskView(),
                    label: {
                        Text("Zadanie")
                            .frame(width:200, height: 40)
                            .background(Color.green)
                }
                )
            }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView()
    }
}

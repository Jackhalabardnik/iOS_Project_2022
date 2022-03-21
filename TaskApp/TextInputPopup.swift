import SwiftUI

struct TextInputPopup: View {
    
    var prompt_text: String
    var error_text: String
    var ok_callback: () -> Bool
    
    @Binding var is_presented: Bool
    
    @State var text = ""
    @State var show_alert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(prompt_text)
            .font(.system(size: 25, weight: .bold, design: .default))
            HStack {
            TextField("", text: $text)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color.gray.opacity(0.3))
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
                .cornerRadius(10)
            HStack {
                Spacer()
                Button(action: {
                    self.show_alert = self.ok_callback()
                },
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
        .alert(isPresented: self.$show_alert) {
            Alert(
                title: Text("Error"),
                message: Text(error_text),
                dismissButton: .default(Text("Got it!"))
            )
        }
        .animation(.easeOut)
        .transition(.move(edge: .bottom))
    }
    
}

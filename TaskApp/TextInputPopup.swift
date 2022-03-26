import SwiftUI
import CoreData

struct TextInputPopup<T: NSFetchRequestResult>: View {
    
    var prompt_text: String
    var error_text: String
    var ok_callback: (inout String, inout Bool, inout Bool) -> Void
    
    @Binding var is_presented: Bool
    
    @State var input_text : String
    @State var show_alert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(prompt_text)
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
            
            HStack {
            TextField("", text: $input_text)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                Spacer()
                Button(action: {
                    self.input_text = ""
                }, label: {
                    Image(systemName: "trash.fill")
                        .imageScale(.medium)
                        .background(Color.black.opacity(0.06))
                        .foregroundColor(.black)
                })
                .padding([.leading, .trailing], 10)
            }
                .padding([.leading, .trailing], 10)
            
            HStack {
                Button(action: {
                    self.ok_callback(&self.input_text, &self.is_presented, &self.show_alert)
                },
                    label: {
                    Text("Done")
                        .font(.system(size: 15, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, maxHeight: 60)
                })
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
        .background(Color.white)
    }
    
}

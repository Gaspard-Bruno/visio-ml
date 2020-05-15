import SwiftUI

struct Toolbar: View {

  @EnvironmentObject var userData: UserData
  @State var showDocumentPicker = false
  
  var body: some View {
    HStack {
      Button("Load images") {
        self.userData.loadImages()
      }
      
      Button("Show picker") {
        self.showDocumentPicker.toggle()
      }
      DocumentPicker(
        isPresented: $showDocumentPicker,
        onCancel: {
          print("Was cancelled :(")
        }
      ) { urls in
        print("Picked URL: \(urls.first!)")
        self.userData.setWorkingDirectory(url: urls.first!)
      }
      Spacer()
    }
  }
}

struct Toolbar_Previews: PreviewProvider {
  static var previews: some View {
    Toolbar()
    .environmentObject(UserData())
    .previewLayout(.sizeThatFits)
  }
}

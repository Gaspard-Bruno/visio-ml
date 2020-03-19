import SwiftUI

struct ContentView: View {

  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    VStack(spacing: 0) {
      ToolBar()
      Divider()
      NavigationView {
        ImageList()
        Group {
          if dataStore.selectedImage == nil {
            Color("background")
            .overlay(
              Text("Please select an image from the side bar.")
            )
            .frame(minWidth: 500)
          } else {
            DetailView()
          }
        }
        .frame(minHeight: 500)
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

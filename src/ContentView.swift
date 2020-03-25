import SwiftUI

struct ContentView: View {

  @EnvironmentObject var store: DataStore

  var body: some View {
    VStack(spacing: 0) {
      ToolBar()
      Divider()
      NavigationView {
        ImageList()
        Group {
          if store.selectedImage == nil {
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
    .onPreferenceChange(ImageSizePrefKey.self) {
      guard let size = $0  else {
        return
      }
      self.store.viewportSize = size
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

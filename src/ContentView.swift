import SwiftUI

struct ContentView: View {

  @ObservedObject var dataStore = DataStore()

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Drag new images into the images area on the left.")
        .padding()
        Spacer()
        Button("Export JSON") {
          self.dataStore.saveJSON()
        }
        .padding()
      }
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
    .environmentObject(dataStore)
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

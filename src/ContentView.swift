import SwiftUI

struct ContentView: View {

  @ObservedObject var dataStore = DataStore()

  var body: some View {
    HStack {
      ImageViewer()
      .padding()
      SidePanel()
      .frame(maxWidth: 350)
      .padding()
    }
    .environmentObject(dataStore)
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

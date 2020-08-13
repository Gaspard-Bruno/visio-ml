import SwiftUI

struct Toolbar: View {
  
  @ObservedObject var appData = AppData.shared

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        
        
        HStack {
          Text("Input folder:")
          WorkingFolderIndicator()
          
        }
        if appData.workingFolder != nil {
          HStack {
            Text("Output folder:")
            OutputFolderIndicator()
          }
        }
//        Button(appData.navigation.isNavigatorVisible ? "Hide Sidebar" : "Show Sidebar") {
//          withAnimation {
//            self.appData.toggleNavigator()
//          }
//        }
//        .environment(\.isEnabled, appData.workingFolder != nil)
      }
      Spacer()
      VStack(alignment: .leading) {
          Button("Synthetics") {
            withAnimation {
              self.appData.navigation.currentModal = "synthetics"
            }
          }
          .environment(\.isEnabled, appData.workingFolder != nil && appData.pendingImages == 0)
          Button("Export") {
            self.appData.saveJSON()
          }
          .environment(\.isEnabled, appData.workingFolder != nil)
      }
    }
    .padding()
    .frame(height: 70)
    .frame(maxWidth: .infinity)
    .border(Color(NSColor.separatorColor), width: 1)
  }
}

struct Toolbar_Previews: PreviewProvider {
  static var previews: some View {
    Toolbar()
  }
}

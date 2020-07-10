import SwiftUI

struct ContentView: View {

  @ObservedObject var appData = AppData.shared

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        Toolbar()
        HStack(spacing: 0) {
          // Navigator
          if appData.workingFolder != nil && appData.navigation.isNavigatorVisible {
            ImageNavigator()
          }
          ViewerPanel()
          .layoutPriority(-1)
          if appData.workingFolder != nil {
            InspectorPanel()
          }
        }
        StatusBar()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      if appData.navigation.currentModal == "synthetics" {
        ZStack(alignment: .top) {
          Color(NSColor.textBackgroundColor).opacity(0.85)
          .onTapGesture {
            withAnimation {
              self.appData.navigation.currentModal = nil
            }
          }
          SyntheticsModal(settings: $appData.settings)
        }
        .transition(.opacity)
      }
    }
    .onPreferenceChange(ImageSizePrefKey.self) {
      if $0 != nil {
        self.appData.viewportSize = $0!
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

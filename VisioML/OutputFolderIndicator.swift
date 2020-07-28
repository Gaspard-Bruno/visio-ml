import SwiftUI

struct OutputFolderIndicator: View {

  @ObservedObject var appData = AppData.shared

  var body: some View {
    HStack {
      OpenButton {
        self.appData.setOutFolder($0)
      }
      if appData.outFolder == nil {
        Text("Same as working (input) folder")
      } else {
        Button("X") {
          self.appData.unsetOutFolder()
        }
        Text("\(appData.outFolder!.path)")
        .truncationMode(.middle)
      }
    }
  }
}

struct OutputFolderIndicator_Previews: PreviewProvider {
  static var previews: some View {
    OutputFolderIndicator()
  }
}

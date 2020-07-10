import SwiftUI

struct WorkingFolderIndicator: View {

  @ObservedObject var appData = AppData.shared

  var body: some View {
    HStack {
      OpenButton()
      if appData.workingFolder == nil {
        Text("No folder selected")
      } else {
        Button("X") {
          self.appData.unsetWorkingFolder()
        }
        Text("\(appData.workingFolder!.path)")
        .truncationMode(.middle)
      }
    }
  }
}

struct WorkingFolderIndicator_Previews: PreviewProvider {
  static var previews: some View {
    WorkingFolderIndicator()
  }
}

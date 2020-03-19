import SwiftUI

struct SelectFolderButton: View {

  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    Button("Select Folder…") {
      let panel = NSOpenPanel()
      panel.canChooseFiles = false
      panel.canChooseDirectories = true
      panel.resolvesAliases = true
      panel.allowsMultipleSelection = false
      panel.isAccessoryViewDisclosed = false
      let result = panel.runModal()
      guard result == .OK, let url = panel.url else {
        return
      }
      self.dataStore.setWorkingFolder(url)
    }
  }
}


struct SelectFolderButton_Previews: PreviewProvider {
  static var previews: some View {
    SelectFolderButton()
  }
}

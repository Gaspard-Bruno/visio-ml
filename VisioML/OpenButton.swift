import SwiftUI

struct OpenButton: View {

  let onSelect: (URL) -> ()

  var body: some View {
    Button("Select folder…") {
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
      self.onSelect(url)
    }
  }
}

struct OpenButton_Previews: PreviewProvider {
  static var previews: some View {
    OpenButton(onSelect: { _ in })
  }
}

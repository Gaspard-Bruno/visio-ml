import SwiftUI

struct WorkspaceSettings: View {

  @Binding var settingsHandle: Bool
  @EnvironmentObject var store: DataStore
  @State var selectionOnly = false

  var backgroundsFolder: String {
    guard let url = store.workspace.backgroundsFolder else {
      return "-"
    }
    return "\(url)"
  }

  var selectFolder: some View {
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
      self.store.workspace.backgroundsFolder = url
    }
  }

  var body: some View {
    ScrollView(.vertical) { Form {
      Section(
        footer: Text("Apply filter to the currently selected imaged only.")
      ) {
        Toggle("Current selection only", isOn: $selectionOnly)
      }
      Divider()
      Section(
        header: Text("Backgrounds folder"),
        footer: Text("Choose a folder containing all backgrounds")
      ) {
        HStack {
          selectFolder
          Text("\(backgroundsFolder)")
        }
      }
      Divider()
      Section(
        header: Text("Synthetic options"),
        footer: Text("Choose a folder containing all backgrounds")
      ) {
        Toggle("Include empty background", isOn: $store.workspace.noBackground)
        Toggle("Apply to every background", isOn: $store.workspace.everyBackground)
        Toggle("Randomize position", isOn: $store.workspace.randomPosition)
        Toggle("Randomize scale", isOn: $store.workspace.randomScale)
        Toggle("Keep aspect ratio", isOn: $store.workspace.keepAspectRatio).padding(.horizontal)
        Toggle("Flip horizontal", isOn: $store.workspace.flipHorizonal)
        Toggle("Flip vertical", isOn: $store.workspace.flipVertical)
        Toggle("Double flip", isOn: $store.workspace.doubleFlip)
          .padding(.horizontal)
        Toggle("Add random noise", isOn: $store.workspace.noiseLayer)
      }
      Spacer()
      Section { HStack {
        Spacer()
        Button(action: {
          self.store.applyFilters()
        }) {
          Text("􀍱 Generate")
        }
        Button(action: {
          self.settingsHandle.toggle()
        }) {
          // Image("symbols/info.circle")
          Text("􀆄 Close")
        }
        } }
    }.frame(maxWidth: .infinity) }
    .padding()
    .frame(maxWidth: .infinity)
  }
}


struct WorkspaceSettings_Previews: PreviewProvider {
  static var previews: some View {
    WorkspaceSettings(settingsHandle: .constant(false))
  }
}

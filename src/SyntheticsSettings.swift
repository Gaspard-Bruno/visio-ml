import SwiftUI

struct SyntheticsSettings: View {

  @EnvironmentObject var store: DataStore

  var workspace: WorkspaceModel {
    store.workspace
  }

  var body: some View {
    ScrollView(.vertical) {
      VStack {
        Toggle("Flip horizontal", isOn: $store.workspace.flipHorizonal)
        Toggle("Flip vertical", isOn: $store.workspace.flipVertical)
      }
      .frame(maxWidth: .infinity)
      .padding()
    }
  }
}


struct SyntheticsSettings_Previews: PreviewProvider {
  static var previews: some View {
    SyntheticsSettings()
    .environmentObject(DataStore())
  }
}

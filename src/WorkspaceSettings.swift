import SwiftUI

struct WorkspaceSettings: View {

  @Binding var settingsHandle: Bool
  @EnvironmentObject var store: DataStore

  var body: some View {
    VStack {
      TabView {
        SyntheticsSettings()
        .tag("syntheticssettings")
        .tabItem {
          Text("Synthetics")
        }
        BackgroundSettings()
        .tag("backgroundsettings")
        .tabItem {
          Text("Backgrounds")
        }
      }
      .padding()
      Spacer()
      HStack {
        Spacer()
        Button("􀍱 Generate") {
          self.store.applyFilters()
        }
        Button("􀆄 Close") {
          self.settingsHandle.toggle()
        }
      }
      .padding()
    }
    .frame(maxWidth: .infinity)
    .frame(minHeight: 400)
  }
}


struct WorkspaceSettings_Previews: PreviewProvider {
  static var previews: some View {
    WorkspaceSettings(settingsHandle: .constant(false))
  }
}

import SwiftUI

struct ToolBar: View {
  
  @Binding var settingsHandle: Bool
  @State var targetting = false

  @EnvironmentObject var store: DataStore

  var workingFolder: URL! {
    store.workingFolder
  }

  var normalContent: some View {
    Group {

      SelectFolderButton()
      if workingFolder == nil {
        Text("Please choose a working folder.")
      } else {
        Text("\(workingFolder.path)")
      }

      Spacer()
      HStack {
        Button("􀈄 Annotations") {
          self.store.saveJSON()
        }
        Button("􀅈") {
          self.store.loadJSON()
        }
        Button("􀍟 Settings…") {
          self.settingsHandle.toggle()
        }
      }
      .environment(\.isEnabled, store.workingFolder != nil)
    }
  }

  var targettingContent: some View {
    Group {
      Spacer()
      Text("Drop any folder here.")
      Spacer()
    }
  }

  var body: some View {
    HStack {
      if targetting {
        targettingContent
      } else {
        normalContent
      }
    }
    .padding()
    .onDrop(of: ["public.file-url"], isTargeted: $targetting) {
      guard $0.count == 1 else {
        return false
      }
      let itemProvider = $0[0]
      itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, error in
        DispatchQueue.main.async {
          guard let urlData = urlData as? Data else {
            return
          }
          let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
          self.store.setWorkingFolder(url)
        }
      }
      return true
    }
  }
}


struct ToolBar_Previews: PreviewProvider {
  static var previews: some View {
    ToolBar(settingsHandle: .constant(false))
  }
}
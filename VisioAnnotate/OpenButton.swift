//
//  OpenButton.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-01.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct OpenButton: View {

  @ObservedObject var appData = AppData.shared

  var body: some View {
    HStack {
      Button("Open…") {
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
        self.appData.setWorkingFolder(url)
      }
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

struct OpenButton_Previews: PreviewProvider {
  static var previews: some View {
    OpenButton()
  }
}

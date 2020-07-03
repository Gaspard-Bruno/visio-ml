//
//  Toolbar.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-01.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct Toolbar: View {
  
  @ObservedObject var appData = AppData.shared

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        OpenButton()
        Button("JSON Export") {
          self.appData.saveJSON()
        }
      }
      Spacer()
      Button("Synthetics…") {
        withAnimation {
          self.appData.currentModal = "synthetics"
        }
      }
      Button("Navigator") {
        withAnimation {
          self.appData.toggleNavigator()
        }
      }
    }
    .padding()
    .frame(height: 80)
    .frame(maxWidth: .infinity)
    .border(Color(NSColor.separatorColor), width: 1)

  }
}

struct Toolbar_Previews: PreviewProvider {
  static var previews: some View {
    Toolbar()
  }
}
